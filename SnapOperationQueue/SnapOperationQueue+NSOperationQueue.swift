import Foundation

public protocol NSOperationQueueProtocol : class {
    
    func addOperation(_ op: Operation)
    func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool)
    func addOperationWithBlock(_ block: () -> Void)
    var operations: [Operation] { get }
    var operationCount: Int { get }
    var maxConcurrentOperationCount: Int { get set }
    var suspended: Bool { get set }
    var name: String? { get set }
    var qualityOfService: QualityOfService { get set }
    var underlyingQueue: DispatchQueue?  { get set }
    func cancelAllOperations()
    func waitUntilAllOperationsAreFinished()
}

extension SnapOperationQueue : NSOperationQueueProtocol {
    
    public func addOperation(_ op: Operation) {
        assert(false, "Use 'addOperation(operation, identifier, groupIdentifier, priority)' instead")
    }
    
    public func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        assert(false, "Use 'addOperation(operation, identifier, groupIdentifier, priority)' instead")
    }
    
    public func addOperationWithBlock(_ block: () -> Void) {
        assert(false, "Use 'addOperation(operation, identifier, groupIdentifier, priority)' instead")
    }
    
    public var operations: [Operation] {
        get {
            return _backingOperationQueue.operations
        }
    }
    
    public var operationCount: Int  {
        get {
            return _backingOperationQueue.operationCount
        }
    }
    
    public var maxConcurrentOperationCount: Int {
        get {
            return _backingOperationQueue.maxConcurrentOperationCount
        }
        set(value) {
            _backingOperationQueue.maxConcurrentOperationCount = value
        }
    }
    
    public var suspended: Bool {
        get {
            return _backingOperationQueue.isSuspended
        }
        set(value) {
            _backingOperationQueue.isSuspended = value
        }
    }
    

    public var name: String? {
        get {
            return _backingOperationQueue.name
        }
        set(value) {
            _backingOperationQueue.name = value
        }
    }
    

    public var qualityOfService: QualityOfService {
        get {
            return _backingOperationQueue.qualityOfService
        }
        set(value) {
            _backingOperationQueue.qualityOfService = value
        }
    }
    

    public var underlyingQueue: DispatchQueue?  {
        get {
            return _backingOperationQueue.underlyingQueue
        }
        set(value) {
            _backingOperationQueue.underlyingQueue = value
        }
    }
    

    public func cancelAllOperations() {
        _backingOperationQueue.cancelAllOperations()
    }
    
    public func waitUntilAllOperationsAreFinished() {
        _backingOperationQueue.waitUntilAllOperationsAreFinished()
    }
}
