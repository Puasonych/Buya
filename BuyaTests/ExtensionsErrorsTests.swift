//
//  ExtensionsErrorsTests.swift
//  BuyaTests
//
//  Created by Алексей Воронов on 25/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
import RxCocoa

class ExtensionsErrorsTests: XCTestCase {
    // MARK: - Stubs
    func testError(statusCode: Int) -> RxCocoa.RxCocoaURLError {
        return RxCocoa.RxCocoaURLError.httpRequestFailed(
            response: HTTPURLResponse(
                url: URL(string: "http://dev.test.ltd:8181")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!,
            data: nil
        )
    }
    
    // MARK: - Tests
    func testBadRequest() {
        XCTAssertTrue(self.testError(statusCode: 400).isBadRequest)
        XCTAssertFalse(self.testError(statusCode: 500).isBadRequest)
    }
    
    func testUnauthorized() {
        XCTAssertTrue(self.testError(statusCode: 401).isUnauthorized)
        XCTAssertFalse(self.testError(statusCode: 400).isUnauthorized)
    }
    
    func testInternalServerError() {
        XCTAssertTrue(self.testError(statusCode: 500).isInternalServerError)
        XCTAssertFalse(self.testError(statusCode: 401).isInternalServerError)
    }
    
    func testClientError() {
        XCTAssertEqual(self.testError(statusCode: 401).isClientError, self.testError(statusCode: 404).isClientError)
        XCTAssertEqual(self.testError(statusCode: 500).isClientError, self.testError(statusCode: 502).isClientError)
    }
    
    func testServerError() {
        XCTAssertEqual(self.testError(statusCode: 500).isServerError, self.testError(statusCode: 502).isServerError)
        XCTAssertEqual(self.testError(statusCode: 400).isServerError, self.testError(statusCode: 401).isServerError)
    }
}
