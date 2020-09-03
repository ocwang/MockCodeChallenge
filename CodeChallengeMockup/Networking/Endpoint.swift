//
//  Endpoint.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/3/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import Foundation

enum Endpoint {
    case getProfile
    case updateProfile(ProfileUpdate)
    case changePassword(NewPasswordInfo)
}

extension Endpoint {
    var urlString: String {
        switch self {
        case .getProfile:
            return "https://api.foo.com/profiles/mine"
        case .updateProfile:
            return "https://api.foo.com/profiles/update"
        case .changePassword:
            return "https://api.foo.com/password/change"
        }
    }
}

extension Endpoint {
    var urlRequest: URLRequest? {
        guard let endpointURL = self.url else { return nil }
        
        var urlRequest = URLRequest(url: endpointURL)
        urlRequest.httpMethod = self.httpMethod.rawValue
        urlRequest.httpBody = self.httpBody
        
        return urlRequest
    }
    
    private var url: URL? {
        return URL(string: urlString)
    }
    
    var httpBody: Data? {
        switch self {
        case .getProfile:
            return nil
        case .updateProfile(let profileUpdate):
            // the format of the encoded json might be slightly different,
            // but not much detail provided per challenge specs
            return try? JSONEncoder().encode(profileUpdate)
        case .changePassword(let newPasswordInfo):
            // same note as above
            return try? JSONEncoder().encode(newPasswordInfo)
        }
    }
    
    private var httpMethod: HTTPMethods {
        switch self {
        case .getProfile:
            return .get
        case .updateProfile:
            return .post
        case .changePassword:
            return .post
        }
    }
}

extension Endpoint {
    var mockResponse: Data {
        switch self {
        case .getProfile:
            return """
            {
                "message": "User Retrieved",
                "data":
                {
                    "firstName": "Johnny B",
                    "userName": "iOS User",
                    "lastName": "Goode"
                }
            }
            """.data(using: .utf8)!
            
        case .updateProfile(let profileUpdate):
            return """
            {
                "message": "User Retrieved",
                "data":
                {
                    "firstName": "\(profileUpdate.firstName)",
                    "userName": "iOS User",
                    "lastName": "\(profileUpdate.lastName)"
                }
            }
            """.data(using: .utf8)!
            
        case .changePassword:
            return """
                {
                    "data": {},
                    "code": "string",
                    "message": "Password Changed",
                    "exceptionName": null
                }
            """.data(using: .utf8)!
        }
    }
}

enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

struct ProfileUpdate: Encodable {
    let firstName: String
    let lastName: String
}

struct NewPasswordInfo: Encodable {
    
    static let minPasswordLength = 7
    
    let currentPassword: String
    let newPassword: String
    let passwordConfirmation: String
    
    var isValid: Bool {
        return !currentPassword.isEmpty &&
        newPassword.count >= NewPasswordInfo.minPasswordLength &&
            passwordConfirmation.count >= NewPasswordInfo.minPasswordLength
    }
    var newPasswordMatchesConfirmation: Bool {
        return !newPassword.isEmpty && newPassword == passwordConfirmation
    }
}
