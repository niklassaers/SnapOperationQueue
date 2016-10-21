import Foundation

extension SnapOperationQueue {
    
    internal func setPriority(_ priority: SnapOperationQueuePriority, toOperation operation : Operation) {
        operation.queuePriority = priority.queuePriority
    }
    
    internal func lockedOperation(_ f: () -> ()) {
        readyLock.lock()
        f()
        readyLock.unlock()
    }
    
}
