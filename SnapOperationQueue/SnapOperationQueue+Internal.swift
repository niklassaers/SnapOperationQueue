import Foundation

extension SnapOperationQueue {
    
    internal func setPriority(priority: SnapOperationQueuePriority, toOperation operation : NSOperation) {
        operation.queuePriority = priority.queuePriority
    }
    
    internal func lockedOperation(f: () -> ()) {
        readyLock.lock()
        f()
        readyLock.unlock()
    }
    
}