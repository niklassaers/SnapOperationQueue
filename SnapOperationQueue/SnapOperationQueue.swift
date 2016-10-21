import Foundation
import PSOperations

open class SnapOperationQueue : NSObject {
    
    open var _backingOperationQueue = PSOperations.OperationQueue()
    open let readyLock = NSLock()

    open var _priorityQueues : [SnapOperationQueuePriority : [SnapOperationIdentifier]]
    open var _groups = [SnapOperationGroupIdentifier: [SnapOperationIdentifier]]()
    open var _operations : [SnapOperationIdentifier : PSOperations.Operation] = [:]
    
    open var onStart : (() -> ())?
    open var onEnd : (() -> ())?
    
    override public init() {
        _priorityQueues = [
            .highest: [SnapOperationIdentifier](),
            .high: [SnapOperationIdentifier](),
            .normal: [SnapOperationIdentifier](),
            .low: [SnapOperationIdentifier]()]
        
        super.init()
        _backingOperationQueue.delegate = self
    }
    
    open func setMaxNumberOfConcurrentOperations(_ num: UInt) {
        _backingOperationQueue.maxConcurrentOperationCount = Int(num)
    }
}

extension SnapOperationQueue : SnapOperationQueueProtocol {
    
    public func addOperation(_ operation: PSOperations.Operation, identifier: SnapOperationIdentifier, groupIdentifier: SnapOperationGroupIdentifier, priority: SnapOperationQueuePriority = .normal)  -> PSOperations.Operation {
        
        if _operations.count == 0 {
            if let onStart = onStart {
                onStart()
            }
        }
        
        if let existingOperation = _operations[identifier] {
            if existingOperation.queuePriority.rawValue < priority.queuePriority.rawValue {
                changePriorityForOperationsWithIdentifiers([identifier], toPriority: priority)
            }
            return existingOperation
        }
        
        lockedOperation {

            
            // Update priority queue
            if var priorityQueue = self._priorityQueues[priority] {
                priorityQueue.append(identifier)
                self._priorityQueues[priority] = priorityQueue
            }
            
            // Update group list
            var group : [SnapOperationIdentifier]
            if let theGroup = self._groups[groupIdentifier] {
                group = theGroup
            } else {
                group = [SnapOperationIdentifier]()
            }
            group.append(identifier)
            self._groups[groupIdentifier] = group
            
            // Update operations
            self._operations[identifier] = operation
            
            // When operation is done, have it removed
            operation.addObserver(BlockObserver(startHandler: nil, produceHandler: nil, finishHandler: { [weak self] (_, _) -> Void in
                self?.operationIsDoneOrCancelled(identifier)
                }))

            // Then fire!
            if self._backingOperationQueue.operations.contains(operation) {
                print("Warning: tried to add existing operation")
            } else {
                self._backingOperationQueue.addOperation(operation)
            }
            
        }
        
        return operation
    }
    
    public func cancelOperationsInGroup(_ groupIdentifier: SnapOperationGroupIdentifier) {
        var operationsToCancel : [PSOperations.Operation] = []
        
        lockedOperation {
            if let group = self._groups[groupIdentifier] {
                for operationKey in group {
                    if let operation = self._operations[operationKey] {
                        operationsToCancel.append(operation)
                        // operationIsDoneOrCancelled will do the rest of the cleanup
                    }
                }
            }
        }
        
        for operation in operationsToCancel {
            operation.cancel() // This one is dependent on the lockedOperation above being available, and our NSLock here is not re-entrant yet
        }
    }
    
    public func operationWithIdentifier(_ identifier: SnapOperationIdentifier) -> PSOperations.Operation? {
        return _operations[identifier]
    }

    public func changePriorityForOperationsWithIdentifiers(_ identifiers : [SnapOperationIdentifier], toPriority priority: SnapOperationQueuePriority) {
        
        lockedOperation { 
            for operationIdentifier in identifiers {
                if let operation = self._operations[operationIdentifier] {
                    // Affect operation
                    self.setPriority(priority, toOperation: operation)
                    
                    // Update priority queue
                    if var priorityQueue = self._priorityQueues[priority] {
                        priorityQueue.append(operationIdentifier)
                        self._priorityQueues[priority] = priorityQueue
                    } else {
                        self._priorityQueues[priority] = [operationIdentifier]
                    }
                    
                    // Remove from other priority queues
                    for (thePriority, theOperationIdentifiers) in self._priorityQueues where thePriority != priority {
                        let newOperationIdentifiers = theOperationIdentifiers.filter({ (theOperationIdentifier) -> Bool in
                            return theOperationIdentifier != operationIdentifier
                        })
                        self._priorityQueues[thePriority] = newOperationIdentifiers
                    }
                }
            }

        }
    }

    
    public func operationIsDoneOrCancelled(_ identifier: SnapOperationIdentifier) {
        lockedOperation {

            // Update priority queue
            for (queuePriority, operationIdentifiers) in self._priorityQueues {
                for operationIdentifier in operationIdentifiers {
                    if operationIdentifier == identifier {
                        self._priorityQueues[queuePriority] = operationIdentifiers.filter({ (operationIdentifier) -> Bool in
                            return operationIdentifier != identifier
                        })
                        
                        break
                    }
                }
            }
            
            // Update group list
            for (currentGroupId, operationIdentifiers) in self._groups {
                for operationIdentifier in operationIdentifiers {
                    if operationIdentifier == identifier {
                        self._groups[currentGroupId] = operationIdentifiers.filter({ (operationIdentifier) -> Bool in
                            return operationIdentifier != identifier
                        })
                        
                        break
                    }
                }
            }
            
            // Update operations
            self._operations.removeValue(forKey: identifier)
            
            if self._operations.count == 0 {
                if let onEnd = self.onEnd {
                    onEnd()
                }
            }
        }
    }

    
    public func setGroupPriorityTo(_ priority: SnapOperationQueuePriority, groupIdentifier: SnapOperationGroupIdentifier) {
        
        lockedOperation {
            
            if let (_, operationIdentifiers) = self._groups.filter({ (theGroupIdentifier, operationIdentifiers) in
                return theGroupIdentifier == groupIdentifier
            }).first {
                for operationIdentifier in operationIdentifiers {
                    if let operation = self._operations[operationIdentifier] {
                        // Affect operation
                        self.setPriority(priority, toOperation: operation)

                        // Update priority queue
                        if var priorityQueue = self._priorityQueues[priority] {
                            priorityQueue.append(operationIdentifier)
                            self._priorityQueues[priority] = priorityQueue
                        } else {
                            self._priorityQueues[priority] = [operationIdentifier]
                        }
                        
                        // Remove from other priority queues
                        for (thePriority, theOperationIdentifiers) in self._priorityQueues {
                            if thePriority != priority {
                                let newOperationIdentifiers = theOperationIdentifiers.filter({ (theOperationIdentifier) -> Bool in
                                    return theOperationIdentifier != operationIdentifier
                                })
                                self._priorityQueues[thePriority] = newOperationIdentifiers
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func setGroupPriorityToHighRestToNormal(_ groupIdentifier: SnapOperationGroupIdentifier) {
        
        lockedOperation {

            let highest = self._priorityQueues[.highest]!
            var high = [SnapOperationIdentifier]()
            var normal = [SnapOperationIdentifier]()
            let low = self._priorityQueues[.low]!
            
            for (currentGroupId, operationIdentifiers) in self._groups {
                for operationIdentifier in operationIdentifiers {
                    if highest.contains(operationIdentifier) ||
                        low.contains(operationIdentifier) {
                            continue
                    }
                    
                    if let operation = self._operations[operationIdentifier] {
                        if currentGroupId == groupIdentifier {
                            operation.queuePriority = .high
                            high.append(operationIdentifier)
                        } else {
                            operation.queuePriority = .normal
                            normal.append(operationIdentifier)
                        }
                    }
                    
                }
            }
            
            self._priorityQueues[.high] = high
            self._priorityQueues[.normal] = normal
            
        }
    }
}

extension SnapOperationQueue : OperationQueueDelegate {
    @nonobjc public func operationQueue(_ operationQueue: PSOperations.OperationQueue, willAddOperation operation: PSOperations.Operation) {
        //print("Added operation \(operation)")
    }
    
    @nonobjc public func operationQueue(_ operationQueue: PSOperations.OperationQueue, operationDidFinish operation: PSOperations.Operation, withErrors errors: [NSError]) {
        //print("Finished operation \(operation) with errors \(errors) and dependencies \(operation.dependencies)")
    }

}
