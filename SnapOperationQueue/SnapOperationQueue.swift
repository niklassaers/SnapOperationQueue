import Foundation
import PSOperations

public class SnapOperationQueue : NSObject {
    
    internal var _backingOperationQueue = OperationQueue()
    internal let readyLock = NSLock()

    internal var _priorityQueues : [SnapOperationQueuePriority : [SnapOperationIdentifier]]
    internal var _groups = [SnapOperationGroupIdentifier: [SnapOperationIdentifier]]()
    internal var _operations = [SnapOperationIdentifier : Operation]()
    
    public var onStart : (() -> ())?
    public var onEnd : (() -> ())?
    
    override public init() {
        _priorityQueues = [
            .Highest: [SnapOperationIdentifier](),
            .High: [SnapOperationIdentifier](),
            .Normal: [SnapOperationIdentifier](),
            .Low: [SnapOperationIdentifier]()]
        
        super.init()
    }
    
    public func setMaxNumberOfConcurrentOperations(num: UInt) {
        _backingOperationQueue.maxConcurrentOperationCount = Int(num)
    }
}

extension SnapOperationQueue : SnapOperationQueueProtocol {
    
    public func addOperation(operation: Operation, identifier: SnapOperationIdentifier, groupIdentifier: SnapOperationGroupIdentifier, priority: SnapOperationQueuePriority = .Normal)  -> Operation {
        
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
            self._backingOperationQueue.addOperation(operation)
        }
        
        return operation
    }
    
    public func operationWithIdentifier(identifier: SnapOperationIdentifier) -> Operation? {
        return _operations[identifier]
    }

    public func changePriorityForOperationsWithIdentifiers(identifiers : [SnapOperationIdentifier], toPriority priority: SnapOperationQueuePriority) {
        
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

    
    public func operationIsDoneOrCancelled(identifier: SnapOperationIdentifier) {
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
            self._operations.removeValueForKey(identifier)
            
            if self._operations.count == 0 {
                if onEnd = self.onEnd {
                    onEnd()
                }
            }
        }
    }

    
    public func setGroupPriorityTo(priority: SnapOperationQueuePriority, groupIdentifier: SnapOperationGroupIdentifier) {
        
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
    
    public func setGroupPriorityToHighRestToNormal(groupIdentifier: SnapOperationGroupIdentifier) {
        
        lockedOperation {

            let highest = self._priorityQueues[.Highest]!
            var high = [SnapOperationIdentifier]()
            var normal = [SnapOperationIdentifier]()
            let low = self._priorityQueues[.Low]!
            
            for (currentGroupId, operationIdentifiers) in self._groups {
                for operationIdentifier in operationIdentifiers {
                    if highest.contains(operationIdentifier) ||
                        low.contains(operationIdentifier) {
                            continue
                    }
                    
                    if let operation = self._operations[operationIdentifier] {
                        if currentGroupId == groupIdentifier {
                            operation.queuePriority = .High
                            high.append(operationIdentifier)
                        } else {
                            operation.queuePriority = .Normal
                            normal.append(operationIdentifier)
                        }
                    }
                    
                }
            }
            
            self._priorityQueues[.High] = high
            self._priorityQueues[.Normal] = normal
            
        }
    }
}

