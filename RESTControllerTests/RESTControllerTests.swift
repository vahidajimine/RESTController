//
//  RESTControllerTests.swift
//  RESTControllerTests
//
//  Created by Vahid Ajimine on 09.02.18.
//  Copyright © 2018 Vahid Ajimine. All rights reserved.
//

import XCTest
@testable import RESTController

class RESTControllerTests: XCTestCase {
    
    let testClassDelegate = TestDelegate()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRestCall() {
        let testRestController = RESTController(delegate: testClassDelegate)
        
        self.testClassDelegate.asyncExpectation = expectation(description: "JSON call with jsonplaceholder post call 1 return")
        
        testRestController.restCall(params: [:], url: "https://jsonplaceholder.typicode.com/posts/1")
        
        waitForExpectations(timeout: 1, handler: { (testError) in
            if let error = testError{
                XCTFail("waitForExpectations errored with \(error)")
            }
            guard let errorString = self.testClassDelegate.errorString else {
                XCTFail("Expected result to be successful")
                return
            }
            guard let result = self.testClassDelegate.results else {
                XCTFail("Expected result to be successful")
                return
            }
            print(result)
            print(errorString)
            XCTAssertTrue(true)
        })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //MARK: - RESTControllerDelegate
    class TestDelegate: RESTControllerDelegate{
       
        
        var results:[String:AnyObject]?
        var errorString:String?
        
        var asyncExpectation: XCTestExpectation?
        init() {
        }
        
        func didNotReceiveAPIResults(error: String, url: String) {
            guard let expectation = asyncExpectation else {
                XCTFail("Test Delegate didNotReceiveAPIResults not set up properly")
                return
            }
            errorString = error
            results = nil
            expectation.fulfill()
        }
        
        func didReceiveAPIResults(results: [String : AnyObject], url: String) {
            guard let expectation = asyncExpectation else {
                XCTFail("Test Delegate didReceiveAPIResults not set up properly")
                return
            }
            errorString = nil
            self.results = results
            expectation.fulfill()
        }

    }
}
