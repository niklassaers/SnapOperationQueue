import XCTest
import SnapOperationQueue
import PSOperations

class SnapOperationQueueTests: XCTestCase {

    var opQueue : protocol<SnapOperationQueueProtocol, NSOperationQueueProtocol>!
    
    override func setUp() {
        super.setUp()
        
        opQueue = SnapOperationQueue()
        opQueue.maxConcurrentOperationCount = 1
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
        
        let operationA = BlockOperation { _ in actualResult.append("A"); self.rest() }
        let operationB = BlockOperation { _ in actualResult.append("B"); self.rest() }
        let operationC = BlockOperation { _ in actualResult.append("C"); self.rest() }
        let operationD = BlockOperation { _ in actualResult.append("D"); self.rest() }
        let operationE = BlockOperation { _ in actualResult.append("E"); self.rest() }
        let operationF = BlockOperation { _ in actualResult.append("F"); self.rest() }
        let operationG = BlockOperation { _ in actualResult.append("G"); self.rest() }
        let operationH = BlockOperation { _ in actualResult.append("H"); self.rest() }
        
        opQueue.addOperation(operationA, identifier: "A", groupIdentifier: theLazyGroupId, priority: .Normal)
        opQueue.addOperation(operationB, identifier: "B", groupIdentifier: theLazyGroupId, priority: .High)
        opQueue.addOperation(operationC, identifier: "C", groupIdentifier: theSpeedyGroupId, priority: .Normal)
        opQueue.addOperation(operationD, identifier: "D", groupIdentifier: theSlooowGroupId, priority: .High)
        opQueue.addOperation(operationE, identifier: "E", groupIdentifier: thePromptGroupId, priority: .Normal)
        opQueue.addOperation(operationF, identifier: "F", groupIdentifier: theLazyGroupId, priority: .High)
        opQueue.addOperation(operationG, identifier: "G", groupIdentifier: thePromptGroupId, priority: .Normal)
        opQueue.addOperation(operationH, identifier: "H", groupIdentifier: thePromptGroupId, priority: .High)
        
        opQueue.setGroupPriorityToHighRestToNormal(thePromptGroupId)
        opQueue.setGroupPriorityTo(.Highest, groupIdentifier: theSpeedyGroupId)
        opQueue.setGroupPriorityTo(.Low, groupIdentifier: theSlooowGroupId)

        let expectation = self.expectationWithDescription("block")
        let finalOp = BlockOperation { _ in
            expectation.fulfill()
        }
        for op in [operationA, operationB, operationC, operationD, operationE, operationF, operationG, operationH] {
            finalOp.addDependency(op)
        }
        opQueue.addOperation(finalOp, identifier: "Final", groupIdentifier: "Final", priority: .Highest)
        
        waitForExpectationsWithTimeout(1.5, handler: nil)
        XCTAssertEqual(expectedResult, actualResult, "Two arrays should be identical")
        
    }
    
}




