//
//  CellIdentifiable.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/2/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import UIKit

protocol CellIdentifiable {}

extension CellIdentifiable where Self: UITableViewCell {
    static var cellIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: CellIdentifiable {}
