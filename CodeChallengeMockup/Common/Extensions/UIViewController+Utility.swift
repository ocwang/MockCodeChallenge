//
//  UIViewController+Utility.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/3/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import UIKit

extension UIViewController {
    func displayAlert(message: String) {
        let alertController = UIAlertController(title: "Hey, you!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertController, animated: true)
    }
    func displayErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Oops! Something went wrong.", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertController, animated: true)
    }
}
