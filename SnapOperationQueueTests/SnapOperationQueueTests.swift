import XCTest
import SnapOperationQueue
import PSOperations

class SnapOperationQueueTests: XCTestCase {

    var opQueue : (SnapOperationQueueProtocol & NSOperationQueueProtocol)?
    
    override func setUp() {
        super.setUp()
        
        opQueue = SnapOperationQueue()
        opQueue?.maxConcurrentOperationCount = 1
    }
    
    override func tearDown() {
        opQueue = nil
        super.tearDown()
    }
    
    func rest() {
//        NSThread.sleepForTimeInterval(0.05)
    }
    
    func testScenario() {

        let expectedResult = ["A", "C", "E", "G", "H",  "B", "F", "D"]
        var actualResult : [String] = []
        
        let theSpeedyGroupId = "theSpeedyGroup"
        let thePromptGroupId = "thePromptGroup"
        let theLazyGroupId = "theLazyGroup"
        let theSlooowGroupId = "theSlooowGroup"
        
        let operationA = PSOperations.BlockOperation { _ in actualResult.append("A"); self.rest() }
        let operationB = PSOperations.BlockOperation { _ in actualResult.append("B"); self.rest() }
        let operationC = PSOperations.BlockOperation { _ in actualResult.append("C"); self.rest() }
        let operationD = PSOperations.BlockOperation { _ in actualResult.append("D"); self.rest() }
        let operationE = PSOperations.BlockOperation { _ in actualResult.append("E"); self.rest() }
        let operationF = PSOperations.BlockOperation { _ in actualResult.append("F"); self.rest() }
        let operationG = PSOperations.BlockOperation { _ in actualResult.append("G"); self.rest() }
        let operationH = PSOperations.BlockOperation { _ in actualResult.append("H"); self.rest() }
        
        guard let opQueue = opQueue else {
            XCTFail()
            return
        }
        
        let _ = opQueue.addOperation(operationA, identifier: "A", groupIdentifier: theLazyGroupId, priority: .normal)
        let _ = opQueue.addOperation(operationB, identifier: "B", groupIdentifier: theLazyGroupId, priority: .high)
        let _ = opQueue.addOperation(operationC, identifier: "C", groupIdentifier: theSpeedyGroupId, priority: .normal)
        let _ = opQueue.addOperation(operationD, identifier: "D", groupIdentifier: theSlooowGroupId, priority: .high)
        let _ = opQueue.addOperation(operationE, identifier: "E", groupIdentifier: thePromptGroupId, priority: .normal)
        let _ = opQueue.addOperation(operationF, identifier: "F", groupIdentifier: theLazyGroupId, priority: .high)
        let _ = opQueue.addOperation(operationG, identifier: "G", groupIdentifier: thePromptGroupId, priority: .normal)
        let _ = opQueue.addOperation(operationH, identifier: "H", groupIdentifier: thePromptGroupId, priority: .high)
        
        opQueue.setGroupPriorityToHighRestToNormal(thePromptGroupId)
        opQueue.setGroupPriorityTo(.highest, groupIdentifier: theSpeedyGroupId)
        opQueue.setGroupPriorityTo(.low, groupIdentifier: theSlooowGroupId)

        let expectation = self.expectation(description: "block")
        let finalOp = PSOperations.BlockOperation { _ in
            expectation.fulfill()
        }
        for op in [operationA, operationB, operationC, operationD, operationE, operationF, operationG, operationH] {
            finalOp.addDependency(op)
        }
        let _ = opQueue.addOperation(finalOp, identifier: "Final", groupIdentifier: "Final", priority: .highest)
        
        waitForExpectations(timeout: 1.5, handler: nil)
        XCTAssertEqual(expectedResult, actualResult, "Two arrays should be identical")
        
    }
    
}




