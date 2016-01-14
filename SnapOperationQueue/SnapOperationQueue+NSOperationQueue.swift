import Foundation

public protocol NSOperationQueueProtocol : class {
    
    func addOperation(op: NSOperation)
    func addOperations(ops: [NSOperation], waitUntilFinished wait: Bool)
    func addOperationWithBlock(block: () -> Void)
    var operations: [NSOperation] { get }
    var operationCount: Int { get }
    var maxConcurrentOperationCount: Int { get set }
    var suspended: Bool { get set }
    var name: String? { get set }
    var qualityOfService: NSQualityOfService { get set }
    var underlyingQueue: dispatch_queue_t?  { get set }
    func cancelAllOperations()
    func waitUntilAllOperationsAreFinished()
}

extension SnapOperationQueue : NSOperationQueueProtocol {
    
    func addOperation(op: NSOperation) {
        assert(false, "Use 'addOperation(operation, identifier, groupIdentifier, priority)' instead")
    }
    
    func addOperations(ops: [NSOperation], waitUntilFinished wait: Bool) {
        assert(false, "Use 'addOperation(operation, identifier, groupIdentifier, priority)' instead")
    }
    
    func addOperationWithBlock(block: () -> Void) {
        assert(false, "Use 'addOperation(operation, identifier, groupIdentifier, priority)' instead")
    }
    
    var operations: [NSOperation] {
        get {
            return _backingOperationQueue.operations
        }
    }
    
    var operationCount: Int  {
        get {
            return _backingOperationQueue.operationCount
        }
    }
    
    var maxConcurrentOperationCount: Int {
        get {
            return _backingOperationQueue.maxConcurrentOperationCount
        }
        set(value) {
            _backingOperationQueue.maxConcurrentOperationCount = value
        }
    }
    
    var suspended: Bool {
        get {
            return _backingOperationQueue.suspended
        }
        set(value) {
            _backingOperationQueue.suspended = value
        }
    }
    

    var name: String? {
        get {
            return _backingOperationQueue.name
        }
        set(value) {
            _backingOperationQueue.name = value
        }
    }
    

    var qualityOfService: NSQualityOfService {
        get {
            return _backingOperationQueue.qualityOfService
        }
        set(value) {
            _backingOperationQueue.qualityOfService = value
        }
    }
    

    var underlyingQueue: dispatch_queue_t?  {
        get {
            return _backingOperationQueue.underlyingQueue
        }
        set(value) {
            _backingOperationQueue.underlyingQueue = value
        }
    }
    

    func cancelAllOperations() {
        _backingOperationQueue.cancelAllOperations()
    }
    
    func waitUntilAllOperationsAreFinished() {
        _backingOperationQueue.waitUntilAllOperationsAreFinished()
    }
}