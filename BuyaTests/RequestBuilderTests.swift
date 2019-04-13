//
//  RequestBuilderTests.swift
//  RequestBuilderTests
//
//  Created by Eric Basargin on 02/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
import RxBlocking
@testable import Buya

class RequestBuilderTests: XCTestCase {
    // MARK: - Stubs
    private enum TestAddressManager: String, Buya.AddressManagerProtocol {
        case develop = "http://dev.test.ltd:8181"
        
        var url: URL { return URL(string: self.rawValue)! }
    }
    
    internal enum TestAPI {
        var testQuery: [String: String] { return ["valueOne": "Hello", "valueTwo": "123"] }
        var testDataParameters: [String: Any] { return ["text": "Hello, World!"] }
        var testData: Data { return try! JSONSerialization.data(withJSONObject: self.testDataParameters, options: []) }
        
        case testRequestPlain
        case testRequestData
        case testRequestCompositeData
        case testRequestQueryParameters
        case testRequestDataParameters
        case testRequestCompositeParameters
    }
    
    // MARK: - Tests
    func testRequestPlain() {
        let requestBuilder = RequestBuilder(addressManager: TestAddressManager.develop)
        let endpoint = TestAPI.testRequestPlain
        
        do {
            let urlRequest = try requestBuilder.makeRequest(endpoint).toBlocking().single()
            
            XCTAssertEqual(urlRequest.allHTTPHeaderFields, endpoint.headers)
            XCTAssertEqual(urlRequest.httpMethod, endpoint.requestType.rawValue)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(TestAddressManager.develop.rawValue)\(endpoint.path)")
            XCTAssertNil(urlRequest.httpBody)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testRequestData() {
        let requestBuilder = RequestBuilder(addressManager: TestAddressManager.develop)
        let endpoint = TestAPI.testRequestData
        
        do {
            let urlRequest = try requestBuilder.makeRequest(endpoint).toBlocking().single()
            
            XCTAssertEqual(urlRequest.allHTTPHeaderFields, endpoint.headers)
            XCTAssertEqual(urlRequest.httpMethod, endpoint.requestType.rawValue)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(TestAddressManager.develop.rawValue)\(endpoint.path)")
            XCTAssertEqual(urlRequest.httpBody, endpoint.testData)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testRequestCompositeData() {
        let requestBuilder = RequestBuilder(addressManager: TestAddressManager.develop)
        let endpoint = TestAPI.testRequestCompositeData
        
        do {
            let urlRequest = try requestBuilder.makeRequest(endpoint).toBlocking().single()
            
            XCTAssertEqual(urlRequest.allHTTPHeaderFields, endpoint.headers)
            XCTAssertEqual(urlRequest.httpMethod, endpoint.requestType.rawValue)
            XCTAssertEqual(
                urlRequest.quaryToDict().merging(endpoint.testQuery) { (valueOne, valueTwo) -> String in
                    XCTAssertEqual(valueOne, valueTwo)
                    return valueOne
                    }.count,
                endpoint.testQuery.count
            )
            XCTAssertEqual(urlRequest.httpBody, endpoint.testData)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testRequestQueryParameters() {
        let requestBuilder = RequestBuilder(addressManager: TestAddressManager.develop)
        let endpoint = TestAPI.testRequestQueryParameters
        
        do {
            let urlRequest = try requestBuilder.makeRequest(endpoint).toBlocking().single()
            
            XCTAssertEqual(urlRequest.allHTTPHeaderFields, endpoint.headers)
            XCTAssertEqual(urlRequest.httpMethod, endpoint.requestType.rawValue)
            XCTAssertEqual(
                urlRequest.quaryToDict().merging(endpoint.testQuery) { (valueOne, valueTwo) -> String in
                    XCTAssertEqual(valueOne, valueTwo)
                    return valueOne
                    }.count,
                endpoint.testQuery.count
            )
            XCTAssertNil(urlRequest.httpBody)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testRequestDataParameters() {
        let requestBuilder = RequestBuilder(addressManager: TestAddressManager.develop)
        let endpoint = TestAPI.testRequestDataParameters
        
        do {
            let urlRequest = try requestBuilder.makeRequest(endpoint).toBlocking().single()
            
            XCTAssertEqual(urlRequest.allHTTPHeaderFields, endpoint.headers)
            XCTAssertEqual(urlRequest.httpMethod, endpoint.requestType.rawValue)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(TestAddressManager.develop.rawValue)\(endpoint.path)")
            XCTAssertEqual(urlRequest.httpBody, endpoint.testData)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testRequestCompositeParameters() {
        let requestBuilder = RequestBuilder(addressManager: TestAddressManager.develop)
        let endpoint = TestAPI.testRequestCompositeParameters
        
        do {
            let urlRequest = try requestBuilder.makeRequest(endpoint).toBlocking().single()
            
            XCTAssertEqual(urlRequest.allHTTPHeaderFields, endpoint.headers)
            XCTAssertEqual(urlRequest.httpMethod, endpoint.requestType.rawValue)
            XCTAssertEqual(
                urlRequest.quaryToDict().merging(endpoint.testQuery) { (valueOne, valueTwo) -> String in
                    XCTAssertEqual(valueOne, valueTwo)
                    return valueOne
                    }.count,
                endpoint.testQuery.count
            )
            XCTAssertEqual(urlRequest.httpBody, endpoint.testData)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension RequestBuilderTests.TestAPI: Buya.EndpointType {
    var path: String {
        return "/api/test"
    }
    
    var requestType: RequestType {
        switch self {
        case .testRequestData, .testRequestCompositeData, .testRequestDataParameters:
            return .post
        default:
            return .get
        }
    }
    
    var requestInfo: RequestInfo {
        switch self {
        case .testRequestData:
            return .bodyData(data: self.testData)
        case .testRequestCompositeData:
            return .commonData(urlParameters: self.testQuery, bodyData: self.testData)
        case .testRequestQueryParameters:
            return .query(parameters: self.testQuery)
        case .testRequestDataParameters:
            return .body(parameters: self.testDataParameters)
        case .testRequestCompositeParameters:
            return .common(urlParameters: self.testQuery, bodyParameters: self.testDataParameters)
        default:
            return .none
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}

fileprivate extension URLRequest {
    func quaryToDict() -> [String: String] {
        guard let quary = self.url?.query else { return [:] }
        
        var result: [String: String] = [:]
        
        for quaryValue in quary.split(separator: "&") {
            let pair = quaryValue.split(separator: "=").map({ return String($0) })
            result[pair[0]] = pair[1]
        }
        
        return result
    }
}
