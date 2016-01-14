import Foundation

extension SnapOperationQueue {
    
    internal func setPriority(priority: SnapOperationQueuePriority, toOperation operation : NSOperation) {
        switch(priority) {
        case .Highest:
            operation.queuePriority = .VeryHigh
        case .High:
            operation.queuePriority = .High
        case .Normal:
            operation.queuePriority = .Normal
        case .Low:
            operation.queuePriority = .VeryLow
            
        }
    }
    
    internal func lockedOperation(f: () -> ()) {
        readyLock.lock()
        f()
        readyLock.unlock()
    }
    
}