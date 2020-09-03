//
//  User.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/3/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import Foundation

struct User: Decodable {
    let firstName: String
    let lastName: String
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case firstName, lastName
        case username = "userName"
    }
}
