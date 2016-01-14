import XCTest
@testable import SnapOperationQueue
import PSOperations

class SnapOperationQueueTests: XCTestCase {

    var opQueue : SnapOperationQueue!
    
    override func setUp() {
        super.setUp()
        
        opQueue = SnapOperationQueue()
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
        
        let operationA = BlockOperation { _ in delay(0.1) { actualResult.append("A") } }
        let operationB = BlockOperation { _ in delay(0.3) { actualResult.append("B") } }
        let operationC = BlockOperation { _ in delay(0.2) { actualResult.append("C") } }
        let operationD = BlockOperation { _ in delay(0.1) { actualResult.append("D") } }
        let operationE = BlockOperation { _ in delay(0.3) { actualResult.append("E") } }
        let operationF = BlockOperation { _ in delay(0.2) { actualResult.append("F") } }
        let operationG = BlockOperation { _ in delay(0.1) { actualResult.append("G") } }
        let operationH = BlockOperation { _ in delay(0.3) { actualResult.append("H") } }
        
//        opQueue.suspended
        opQueue.addOperation(operationA, identifier: randomId(), groupIdentifier: theLazyGroupId, priority: .Normal)
        opQueue.addOperation(operationB, identifier: randomId(), groupIdentifier: theLazyGroupId, priority: .High)
        opQueue.addOperation(operationC, identifier: randomId(), groupIdentifier: theSpeedyGroupId, priority: .Normal)
        opQueue.addOperation(operationD, identifier: randomId(), groupIdentifier: theSlooowGroupId, priority: .High)
        opQueue.addOperation(operationE, identifier: randomId(), groupIdentifier: thePromptGroupId, priority: .Normal)
        opQueue.addOperation(operationF, identifier: randomId(), groupIdentifier: theLazyGroupId, priority: .High)
        opQueue.addOperation(operationG, identifier: randomId(), groupIdentifier: thePromptGroupId, priority: .Normal)
        opQueue.addOperation(operationH, identifier: randomId(), groupIdentifier: thePromptGroupId, priority: .High)
        
        opQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(expectedResult, actualResult, "Two arrays should be identical")
        
    }
    
}




