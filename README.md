# Buya [![Build Status](https://travis-ci.com/Puasonych/Buya.svg?branch=master)](https://travis-ci.com/Puasonych/Buya) [![Version](https://img.shields.io/cocoapods/v/Buya.svg?style=flat)](https://cocoapods.org/pods/Buya) [![codebeat badge](https://codebeat.co/badges/1282a7a0-1d96-431d-a6e3-29127688571c)](https://codebeat.co/projects/github-com-puasonych-buya-master) [![codecov](https://codecov.io/gh/Puasonych/Buya/branch/master/graph/badge.svg)](https://codecov.io/gh/Puasonych/Buya) 

Network abstraction framework

## Features

- [x] Interfaces are same as [Moya](https://github.com/Moya/Moya)
- [x] Without [Alamofire](https://github.com/Alamofire/Alamofire) abstraction layer
- [x] Included: AccessTokenPlugin, RefreshTokenPlugin, AccessRecoveryPlugin

## Installation

### CocoaPods

For Buya, use the following entry in your Podfile:

```rb
pod 'RxSwift', '~> 4.5'
pod 'RxCocoa', '~> 4.5'
pod 'Buya', '~> 1.0'
```

Then run `pod install`.

In any file you'd like to use Buya in, don't forget to
import the framework with `import Buya`.

## Usage

Using Buya is really simple. You can access an API like this:

```swift
authorizationProvider
    .request(Authorization.getData)
    .map(YourCodableStruct.self)
    .subscribe(
        onSuccess: { (data) in
            /// Doing something with data
        },
        onError: { (error) in
            print(error.localizedDescription)
        }
    )
    .disposed(by: self.disposeBag)
```

To do this, you must implement the following:

```swift
typealias AuthorizationProvider = Buya.Provider<Authorization>

enum Authorization {
    /// Authorization
    case authorize

    /// Return data
    case getData
}

extension Authorization: EndpointType, Buya.RefreshTokenApply {
    var path: String {
        switch self {
        case Authorization.authorize:
            return "/authorize"
            
        case Authorization.getData:
            return "/getData"
        }
    }
    
    var requestType: RequestType {
        switch self {
        case Authorization.authorize:
            return RequestType.post
        case Authorization.getData:
            return RequestType.get
        }
    }
    
    var requestInfo: RequestInfo {
        switch self {
        case let Authorization.authorize(login, password):
            let query = [
                "login" : login,
                "password": password
            ]
            return RequestInfo.query(parameters: query)
            
        case Authorization.getData:
            return RequestInfo.none
        }
    }

    var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var refreshTokenApply: Bool {
        switch self {
        case Authorization.getData: return true
        default:
            return false
        }
    }
}
```

## License

RStorage is released under an MIT license. See [LICENSE](https://github.com/Puasonych/Buya/blob/master/LICENSE) for more information.
