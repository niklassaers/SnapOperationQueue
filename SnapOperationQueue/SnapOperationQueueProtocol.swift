import Foundation
import PSOperations

typealias SnapOperationIdentifier = String
typealias SnapOperationGroupIdentifier = String

enum SnapOperationQueuePriority : Int {
    case Highest
    case High
    case Normal
    case Low
}

protocol SnapOperationQueueProtocol {
    
    func addOperation(operation: Operation, identifier: SnapOperationIdentifier, groupIdentifier: SnapOperationGroupIdentifier, priority: SnapOperationQueuePriority)
    func operationIsDoneOrCancelled(identifier: SnapOperationIdentifier)
    func setGroupPriorityTo(priority: SnapOperationQueuePriority, groupIdentifier: SnapOperationGroupIdentifier)
    func setGroupPriorityToHighRestToLow(groupIdentifier: SnapOperationGroupIdentifier)
}
