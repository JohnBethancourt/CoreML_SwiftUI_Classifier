//
//  ObjectClassifierTests.swift
//  ObjectClassifierTests
//
//  Created by John Bethancourt on 10/2/21.
//

@testable import ObjectClassifier
import Vision
import XCTest

class ObjectClassifierModelTests: XCTestCase {
    
    func testClassifications() throws {
        
        let model = ObjectClassifierModel()
        
        let c1 = MockVNClassificationObservation(confidence: 0.2, identifier: "Dog")
        let c2 = MockVNClassificationObservation(confidence: 0.99231, identifier: "Cat")
        let c3 = MockVNClassificationObservation(confidence: 0.234, identifier: "Barn")
        let c4 = MockVNClassificationObservation(confidence: 0.148123, identifier: "Kitchen Sink")
        let c5 = MockVNClassificationObservation(confidence: 0.7123, identifier: "Cupcake")
        let classifications = [c1, c2, c3, c4, c5]
        
        let expectation = XCTestExpectation(description: "Expectation of handled classifications.")
        let cancellable = model.$resultText.dropFirst(1).sink { _ in
            expectation.fulfill()
        }
        
        model.handleClassifications(classifications)
        
        wait(for: [expectation], timeout: 5.0)
        
        let expectedText = "1. Dog - Confidence 20.00%\n2. Cat - Confidence 99.23%\n3. Barn - Confidence 23.40%\n4. Kitchen Sink - Confidence 14.81%\n5. Cupcake - Confidence 71.23%\n"
        
        XCTAssertEqual(model.resultText, expectedText)
        
        cancellable.cancel()
    }
    
    func testClassifyImage() throws {
        
        let model = ObjectClassifierModel()
        
        let image = try XCTUnwrap(UIImage(named: "dog"))
        
        model.classifyImage(image)
        
        let expectation = XCTestExpectation(description: "Expectation of classified image.")
        
        let cancellable = model.$resultText.dropFirst(1).sink { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        let expectedText = "1. Shetland sheepdog, Shetland sheep dog, Shetland - Confidence 25.15%\n2. golden retriever - Confidence 9.50%\n3. Australian terrier - Confidence 7.61%\n4. Brittany spaniel - Confidence 7.01%\n5. papillon - Confidence 6.45%\n"
 
        XCTAssertEqual(model.resultText, expectedText)
        
        cancellable.cancel()
    }
    
    func testImageClassificationPerformance() throws {
        // This is an example of a performance test case.
        let image = try XCTUnwrap(UIImage(named: "dog"))
        let model = ObjectClassifierModel()
        
        measure {
            // Put the code you want to measure the time of here.
            let expectation = XCTestExpectation(description: "Expectation of classified image.")
            model.classifyImage(image)
            let cancellable = model.$resultText.dropFirst(1).sink { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
            cancellable.cancel()
        }
    }
}
