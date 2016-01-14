import Foundation
import PSOperations

public typealias SnapOperationIdentifier = String
public typealias SnapOperationGroupIdentifier = String

public enum SnapOperationQueuePriority : Int {
    case Highest
    case High
    case Normal
    case Low
}

public protocol SnapOperationQueueProtocol : class {
    
    func addOperation(operation: Operation, identifier: SnapOperationIdentifier, groupIdentifier: SnapOperationGroupIdentifier, priority: SnapOperationQueuePriority)
    func operationIsDoneOrCancelled(identifier: SnapOperationIdentifier)
    func setGroupPriorityTo(priority: SnapOperationQueuePriority, groupIdentifier: SnapOperationGroupIdentifier)
    func setGroupPriorityToHighRestToLow(groupIdentifier: SnapOperationGroupIdentifier)
}
