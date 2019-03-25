//
//  AccessTokenAyhorizablePluginTests.swift
//  BuyaTests
//
//  Created by Алексей Воронов on 25/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxBlocking
@testable import Buya

class AccessTokenAyhorizablePluginTests: XCTestCase {
    // MARK: - Stubs
    private class NetworkWorkerMock: NetworkWorkerProtocol {
        func performRequest(_ request: URLRequest) -> Single<Data> {
            do {
                let data = try JSONSerialization.data(withJSONObject: request.allHTTPHeaderFields!, options: [])
                return Single.just(data)
            } catch {
                return Single.error(error)
            }
        }
    }
    
    private enum TestAddressManager: String, Buya.AddressManagerProtocol {
        case develop = "http://dev.test.ltd:8181"
        
        var url: URL { return URL(string: self.rawValue)! }
    }
    
    internal enum TestAPI {
        var testQuery: [String: String] { return ["valueOne": "Hello", "valueTwo": "123"] }
        var testDataParameters: [String: Any] { return ["text": "Hello, World!"] }
        var testData: Data { return try! JSONSerialization.data(withJSONObject: self.testDataParameters, options: []) }
        
        case fakeRequest
    }
    
    // MARK: - Test
    func testAccessTokenAyhorizablePlugin() {
        let networkWorker = NetworkWorkerMock()
        let requestBuilder = RequestBuilder(addressManager: TestAddressManager.develop)
        let plugin = AccessTokenPlugin { () -> String? in
            return "test"
        }
        let provider = Buya.Provider<TestAPI>(requestBuilder: requestBuilder, plugins: [plugin], networkWorker: networkWorker)
        
        do {
            let data = try JSONSerialization.jsonObject(with: try provider.request(TestAPI.fakeRequest).toBlocking().single(), options: [])
            let currentRequest = data as! [String: String]
            
            XCTAssertEqual(currentRequest["Authorization"], "Bearer test")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension AccessTokenAyhorizablePluginTests.TestAPI: Buya.EndpointType, Buya.AccessTokenAuthorizable {
    var path: String {
        return "/api/test"
    }
    
    var requestType: RequestType {
        switch self {
        case .fakeRequest:
            return .post
        }
    }
    
    var requestInfo: RequestInfo {
        switch self {
        case .fakeRequest:
            return .none
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    public var authorizationType: Buya.AuthorizationType {
        return Buya.AuthorizationType.bearer
    }
}
