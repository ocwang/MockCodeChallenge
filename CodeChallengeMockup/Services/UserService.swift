//
//  UserService.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/3/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import UIKit

enum UserServiceError: Error, LocalizedError {
    case networkError
    case failedToDecodeData
    case actionFailed(message: String)
    
    var errorDescription: String? {
        switch self {
        case .actionFailed(let message):
            return message
        case .networkError:
            return "Please ensure that you're connected to the Internet and try again in a few moments."
        default:
            return "Our engineering team has been notified about the issue. Please try again later or contact our support team."
        }
    }
}

enum UserService {
    static func me(completion: @escaping (Result<User, UserServiceError>) -> Void) {
        NetworkManager.shared.response(.getProfile) { result in
            switch result {
            case .success(let data):
                do {
                    // as an optimization you could add a generic decoder as part of Endpoint
                    // that converts the data to the expected model
                    let response = try JSONDecoder().decode(UserProfileResponse.self, from: data)
                    completion(.success(response.data))
                } catch {
                    completion(.failure(.failedToDecodeData))
                }
                
            case .failure(let error):
                // in production, you would handle each individual network error accordingly
                switch error {
                case .errorResponse:
                    completion(.failure(.actionFailed(message: "We had trouble loading your profile. Please try again later.")))
                default:
                    completion(.failure(.networkError))
                }
            }
        }
    }
    
    static func updateProfile(_ profileUpdate: ProfileUpdate, completion: @escaping (Result<User, UserServiceError>) -> Void) {
        NetworkManager.shared.response(.updateProfile(profileUpdate)) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(UserProfileResponse.self, from: data)
                    completion(.success(response.data))
                } catch {
                    completion(.failure(.failedToDecodeData))
                }
                
            case .failure(let error):
                // in production, you would handle each individual network error accordingly
                switch error {
                case .errorResponse:
                    completion(.failure(.actionFailed(message: "We failed to update your profile. Please try again later.")))
                default:
                    completion(.failure(.networkError))
                }
            }
        }
    }
    
    static func changePassword(_ newPasswordInfo: NewPasswordInfo, completion: @escaping (Result<String, UserServiceError>) -> Void) {
        NetworkManager.shared.response(.changePassword(newPasswordInfo)) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(UpdatedPasswordResponse.self, from: data)
                    completion(.success(response.message))
                } catch {
                    completion(.failure(.failedToDecodeData))
                }
                
                return
            case .failure(let error):
                // in production, you would handle each individual network error accordingly
                switch error {
                case .errorResponse:
                    completion(.failure(.actionFailed(message: "We failed to change your password. Please try again later.")))
                default:
                    completion(.failure(.networkError))
                }
            }
        }
    }
}

extension UserService {
    struct UserProfileResponse: Decodable {
        let message: String
        let data: User
    }
    
    struct UpdatedPasswordResponse: Decodable {
        let code: String
        let message: String
        let exceptionName: String?
    }
}

