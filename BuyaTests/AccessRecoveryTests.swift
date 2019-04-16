//
//  AccessRecoveryTests.swift
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

class AccessRecoveryTests: XCTestCase {
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
    
    private class NetworkWorkerMock: NetworkWorkerProtocol {
        func performRequest(_ request: URLRequest) -> Single<Data> {
            let error = RxCocoa.RxCocoaURLError.httpRequestFailed(
                response: HTTPURLResponse(
                    url: URL(string: "http://dev.test.ltd:8181")!,
                    statusCode: 401,
                    httpVersion: nil,
                    headerFields: nil
                    )!,
                data: nil
            )
            return Single.error(error)
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
    func testRefreshTokenApplyPlugin() {
        let networkWorker = NetworkWorkerMock()
        let requestBuilder = RequestBuilder(addressManager: TestAddressManager.develop)
        let plugin = AccessRecoveryPlugin(accessRecoveryClosure: { () -> Single<Data> in
            return Single.just(Data())
        })
        let provider = Buya.Provider<TestAPI>(requestBuilder: requestBuilder, plugins: [plugin], networkWorker: networkWorker)
        let endpoint = TestAPI.fakeRequest
        
        do {
            _ = try provider.request(endpoint).toBlocking().single()
            XCTFail("Current request should return error")
        } catch {
            guard case ProviderError.invalidReuseEndpoint = error else {
                XCTFail("Error should be the same type as ProviderError.invalidReuseEndpoint")
                return
            }
        }
    }
    
    func testRefreshError() {
        let networkWorker = NetworkWorkerMock()
        let requestBuilder = RequestBuilder(addressManager: TestAddressManager.develop)
        let plugin = AccessRecoveryPlugin(accessRecoveryClosure: { () -> Single<Data> in
            return Single.error(self.testError(statusCode: 401))
        })
        let provider = Buya.Provider<TestAPI>(requestBuilder: requestBuilder, plugins: [plugin], networkWorker: networkWorker)
        
        do {
            _ = try provider.request(TestAPI.fakeRequest).toBlocking().single()
            XCTFail("Current request should return error")
        } catch {
            XCTAssertTrue(error.isUnauthorized)
        }
    }
}

extension AccessRecoveryTests.TestAPI: Buya.EndpointType, Buya.AccessTokenAuthorizable, Buya.RefreshTokenApply, Buya.AccessRecovery {
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
    
    public var refreshTokenApply: Bool {
        return true
    }
    
    public var accessRecovery: Bool {
        return true
    }
}

