//
//  NetworkManager.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/3/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case invalidURLRequest
    case requestFailed(reason: String)
    case invalidResponse
    case errorResponse(statusCode: Int)
}

class NetworkManager {

    // MARK: - Singleton
    static let shared = NetworkManager()
    private init() {}
    
    private let defaultSession: URLSession = {
        let urlSession = URLSession(configuration: .default)
        // as defined per challange spec, assume we magically have acquired a valid JWT token
        let mockJWTToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.0I4-NY8dBfPJUjsLgoymebIP3Zw8WrjUcP4Ibk8PGPs"
        // probably want to throw in some additional headers depending on server configuration
        urlSession.configuration.httpAdditionalHeaders = ["Authorization": mockJWTToken]
        
        return urlSession
    }()
    
    func response(_ endpoint: Endpoint, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        defaultSession.mockDataTask(with: endpoint) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                return completion(Result.failure(.requestFailed(reason: error.localizedDescription)))
            }

            guard let response = response as? HTTPURLResponse, let data = data else {
                return completion(Result.failure(.invalidResponse))
            }
            
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                return completion(Result.failure(.errorResponse(statusCode: response.statusCode)))
            }
            
            completion(Result.success(data))
        }
    }
}

extension URLSession {
    // fake network request because challange doesn't provide a real endpoint :(
    fileprivate func mockDataTask(with endpoint: Endpoint, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let urlRequest = endpoint.urlRequest, let url = urlRequest.url else { return completionHandler(nil, nil, NetworkError.invalidURLRequest) }
        
        let mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        completionHandler(endpoint.mockResponse, mockResponse, nil)
    }
}
