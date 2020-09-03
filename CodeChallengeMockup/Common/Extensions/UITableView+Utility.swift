//
//  UITableView+Utility.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/2/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import UIKit

extension UITableView {
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        self.register(cellClass, forCellReuseIdentifier: T.cellIdentifier)
    }
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.cellIdentifier) as? T else {
            preconditionFailure("Error dequeuing cell for identifier \(T.cellIdentifier)")
        }
        return cell
    }
}
