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
    
    func testScenario() {

        let expectedResult = ["C", "E", "G", "H", "A", "B", "F", "D"]
        var actualResult : [String] = []
        
        let theSpeedyGroupId = "theSpeedyGroup"
        let thePromptGroupId = "thePromptGroup"
        let theLazyGroupId = "theLazyGroup"
        let theSlooowGroupId = "theSlooowGroup"
        
//        let operationA = BlockOperation { _ in delay(0.1) { actualResult.append("A") } }
//        let operationB = BlockOperation { _ in delay(0.3) { actualResult.append("B") } }
//        let operationC = BlockOperation { _ in delay(0.2) { actualResult.append("C") } }
//        let operationD = BlockOperation { _ in delay(0.1) { actualResult.append("D") } }
//        let operationE = BlockOperation { _ in delay(0.3) { actualResult.append("E") } }
//        let operationF = BlockOperation { _ in delay(0.2) { actualResult.append("F") } }
//        let operationG = BlockOperation { _ in delay(0.1) { actualResult.append("G") } }
//        let operationH = BlockOperation { _ in delay(0.3) { actualResult.append("H") } }

        let operationA = BlockOperation { _ in print("a"); delay(0.1) { print("A"); actualResult.append("A") } }
        let operationB = BlockOperation { _ in print("b"); delay(0.3) { print("B"); actualResult.append("B") } }
        let operationC = BlockOperation { _ in print("c"); delay(0.2) { print("C"); actualResult.append("C") } }
        let operationD = BlockOperation { _ in print("d"); delay(0.1) { print("D"); actualResult.append("D") } }
        let operationE = BlockOperation { _ in print("e"); delay(0.3) { print("E"); actualResult.append("E") } }
        let operationF = BlockOperation { _ in print("f"); delay(0.2) { print("F"); actualResult.append("F") } }
        let operationG = BlockOperation { _ in print("g"); delay(0.1) { print("G"); actualResult.append("G") } }
        let operationH = BlockOperation { _ in print("h"); delay(0.3) { print("H"); actualResult.append("H") } }

//        opQueue.suspended
        opQueue.addOperation(operationA, identifier: randomId(), groupIdentifier: theLazyGroupId, priority: .Normal)
        opQueue.addOperation(operationB, identifier: randomId(), groupIdentifier: theLazyGroupId, priority: .High)
        opQueue.addOperation(operationC, identifier: randomId(), groupIdentifier: theSpeedyGroupId, priority: .Normal)
        opQueue.addOperation(operationD, identifier: randomId(), groupIdentifier: theSlooowGroupId, priority: .High)
        opQueue.addOperation(operationE, identifier: randomId(), groupIdentifier: thePromptGroupId, priority: .Normal)
        opQueue.addOperation(operationF, identifier: randomId(), groupIdentifier: theLazyGroupId, priority: .High)
        opQueue.addOperation(operationG, identifier: randomId(), groupIdentifier: thePromptGroupId, priority: .Normal)
        opQueue.addOperation(operationH, identifier: randomId(), groupIdentifier: thePromptGroupId, priority: .High)
        
        opQueue.setGroupPriorityToHighRestToNormal(thePromptGroupId)
        opQueue.setGroupPriorityTo(.Highest, groupIdentifier: theSpeedyGroupId)
        opQueue.setGroupPriorityTo(.Low, groupIdentifier: theSlooowGroupId)
        
        let expectation = self.expectationWithDescription("block")
        let finalOp = BlockOperation { _ in
            print("\(expectedResult == actualResult)")
            print("Are they equal?")
            expectation.fulfill()
        }
        for op in [operationA, operationB, operationC, operationD, operationE, operationF, operationG, operationH] {
            finalOp.addDependency(op)
        }
        opQueue.addOperation(finalOp, identifier: "Final", groupIdentifier: "Final", priority: .Highest) // Highest, but comes last since it has unfulfilled dependencies
        
        print("Await \(opQueue.operationCount) operations. Suspended? \(opQueue.suspended)")

        
        waitForExpectationsWithTimeout(2.5, handler: nil)
        XCTAssertEqual(expectedResult, actualResult, "Two arrays should be identical")
        
    }
    
}




