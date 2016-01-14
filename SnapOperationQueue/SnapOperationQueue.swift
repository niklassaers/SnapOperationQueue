import Foundation
import PSOperations

class SnapOperationQueue : NSObject {
    
    internal var _backingOperationQueue = NSOperationQueue()
    internal let readyLock = NSLock()

    internal var _priorityQueues : [SnapOperationQueuePriority : [SnapOperationIdentifier]]
    internal var _groups = [SnapOperationGroupIdentifier: [SnapOperationIdentifier]]()
    internal var _operations = [SnapOperationIdentifier : Operation]()
    
    
    override init() {
        _priorityQueues = [
            .Highest: [SnapOperationIdentifier](),
            .High: [SnapOperationIdentifier](),
            .Normal: [SnapOperationIdentifier](),
            .Low: [SnapOperationIdentifier]()]
        
        super.init()
    }
}

extension SnapOperationQueue : SnapOperationQueueProtocol {
    
    func addOperation(operation: Operation, identifier: SnapOperationIdentifier, groupIdentifier: SnapOperationGroupIdentifier, priority: SnapOperationQueuePriority = .Normal) {
        
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
            
        }
    }
    
    func operationIsDoneOrCancelled(identifier: SnapOperationIdentifier) {
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
        }
    }

    
    func setGroupPriorityTo(priority: SnapOperationQueuePriority, groupIdentifier: SnapOperationGroupIdentifier) {
        
        lockedOperation {
            
            if let (_, operationIdentifiers) = self._groups.filter({ (groupIdentifier, operationIdentifiers) in
                return groupIdentifier == groupIdentifier
            }).first {
                for operationIdentifier in operationIdentifiers {
                    if let operation = self._operations[operationIdentifier] {
                        self.setPriority(priority, toOperation: operation)
                    }
                }
            }
        }
    }
    
    func setGroupPriorityToHighRestToLow(groupIdentifier: SnapOperationGroupIdentifier) {
        
        lockedOperation {

            var high = [SnapOperationIdentifier]()
            var normal = [SnapOperationIdentifier]()
            
            for (currentGroupId, operationIdentifiers) in self._groups {
                for operationIdentifier in operationIdentifiers {
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
        }
    }


}

