import Foundation
import PSOperations

public typealias SnapOperationIdentifier = String
public typealias SnapOperationGroupIdentifier = String

public enum SnapOperationQueuePriority : Int {
    case Highest
    case High
    case Normal
    case Low
    
    public var queuePriority : NSOperationQueuePriority {
        get {
            switch(self) {
            case .Highest:
                return .VeryHigh
            case .High:
                return .High
            case .Normal:
                return .Normal
            case .Low:
                return .VeryLow
            }
            
        }
    }
}

public protocol SnapOperationQueueProtocol : class {
    
    // If there already was an operation in the queue with this identifier, return that operation. Return the input operation for success
    func addOperation(operation: Operation, identifier: SnapOperationIdentifier, groupIdentifier: SnapOperationGroupIdentifier, priority: SnapOperationQueuePriority) -> Operation
    
    func operationWithIdentifier(identifier: SnapOperationIdentifier) -> Operation?
    func changePriorityForOperationsWithIdentifiers(identifiers: [SnapOperationIdentifier], toPriority: SnapOperationQueuePriority)
    
    func operationIsDoneOrCancelled(identifier: SnapOperationIdentifier)
    func setGroupPriorityTo(priority: SnapOperationQueuePriority, groupIdentifier: SnapOperationGroupIdentifier)
    func setGroupPriorityToHighRestToNormal(groupIdentifier: SnapOperationGroupIdentifier)
}
