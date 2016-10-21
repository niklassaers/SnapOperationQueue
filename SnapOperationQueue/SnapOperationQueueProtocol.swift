import Foundation
import PSOperations

public typealias SnapOperationIdentifier = String
public typealias SnapOperationGroupIdentifier = String

public enum SnapOperationQueuePriority : Int {
    case highest
    case high
    case normal
    case low
    
    public var queuePriority : PSOperations.Operation.QueuePriority {
        get {
            switch(self) {
            case .highest:
                return .veryHigh
            case .high:
                return .high
            case .normal:
                return .normal
            case .low:
                return .veryLow
            }
            
        }
    }
}

public protocol SnapOperationQueueProtocol : class {
    
    // If there already was an operation in the queue with this identifier, return that operation. Return the input operation for success
    func addOperation(_ operation: PSOperations.Operation, identifier: SnapOperationIdentifier, groupIdentifier: SnapOperationGroupIdentifier, priority: SnapOperationQueuePriority) -> PSOperations.Operation
    
    func operationWithIdentifier(_ identifier: SnapOperationIdentifier) -> PSOperations.Operation?
    func changePriorityForOperationsWithIdentifiers(_ identifiers: [SnapOperationIdentifier], toPriority: SnapOperationQueuePriority)
    
    func operationIsDoneOrCancelled(_ identifier: SnapOperationIdentifier)
    func setGroupPriorityTo(_ priority: SnapOperationQueuePriority, groupIdentifier: SnapOperationGroupIdentifier)
    func setGroupPriorityToHighRestToNormal(_ groupIdentifier: SnapOperationGroupIdentifier)
}
