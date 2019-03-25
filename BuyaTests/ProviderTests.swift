//
//  ProviderTests.swift
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

class ProviderTests: XCTestCase {
    // MARK: - Stubs
    private class NetworkWorkerMock: NetworkWorkerProtocol {
        func performRequest(_ request: URLRequest) -> Single<Data> {
            return Single.just(Data())
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
    
    // MARK: - Tests
    func testDefaultProvider() {
        let networkWorker = NetworkWorkerMock()
        let requestBuilder = RequestBuilder(addressManager: TestAddressManager.develop)
        let provider = Buya.Provider<TestAPI>(requestBuilder: requestBuilder, networkWorker: networkWorker)
        
        do {
            let request = try provider.request(TestAPI.fakeRequest).toBlocking().single()
            XCTAssertEqual(request, Data())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension ProviderTests.TestAPI: Buya.EndpointType {
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
}
