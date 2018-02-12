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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetRestCall() {
        let testDelegate = TestDelegate()
        let testRestController = RESTController(delegate: testDelegate)
        testDelegate.asyncExpectation = expectation(description: "JSON call with jsonplaceholder post call 1 return")
        testRestController.restCall(url: "https://jsonplaceholder.typicode.com/posts/1", method: HTTPMethod.get)
        
        wait(for: [testDelegate.asyncExpectation!], timeout: 10)
        if let error = testDelegate.errorString{
            XCTFail("didNotReceiveAPIResults triggered with the following \(error)")
            return
        }
        guard let result = testDelegate.results else {
            XCTFail("Expected result to be successful")
            return
        }
        XCTAssertTrue(result["title"] != nil, result.description)
    }
    
    func testPostRestCall() {
        let testDelegate = TestDelegate()
        let testRestController = RESTController(delegate: testDelegate)
        testDelegate.asyncExpectation = expectation(description: "JSON call with jsonplaceholder post call 1 return")
        testRestController.restCall(url: "http://ip.jsontest.com/")
        
        waitForExpectations(timeout: 1, handler: { (testError) in
            if let error = testError{
                XCTFail("waitForExpectations errored with \(error)")
            }
            if let error = testDelegate.errorString{
                XCTFail("didNotReceiveAPIResults triggered with the following \(error)")
                return
            }
            guard let result = testDelegate.results else {
                XCTFail("Result is empty for testPostRestCal")
                return
            }
            XCTAssertTrue(result["ip"] != nil, result.description)
        })
    }
    
    func testFailedRestCall(){
        let testDelegate = TestDelegate()
        let testRestController = RESTController(delegate: testDelegate)
        testDelegate.asyncExpectation = expectation(description: "FlixBusTest")
        testRestController.restCall(url: "http://bogus.url.com/notreal")
        waitForExpectations(timeout: 10, handler: { (testError) in
            if let error = testError{
                XCTFail("waitForExpectations errored with \(error)")
            }
            if let error = testDelegate.results{
                XCTFail("didReceiveAPIResults triggered with the following \(error.description)")
                return
            }
            guard let correctResponse = testDelegate.errorString else {
                XCTFail("Expected result to be successful")
                return
            }
            XCTAssertTrue(correctResponse == "", correctResponse)
        })
    }
    
    func testPerformanceExample() {
        /*
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
        // */
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
