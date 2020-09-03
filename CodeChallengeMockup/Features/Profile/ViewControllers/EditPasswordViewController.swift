//
//  EditPasswordViewController.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/3/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import UIKit

class EditPasswordViewController: UIViewController {
    
    // MARK: - Data
    
    private var newPasswordInfo: NewPasswordInfo?
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        installSubviews()
        installConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // dismiss keyboard if it's active
        view.endEditing(true)
        removeNotifications()
    }
    
    // MARK: - Subviews
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.rowHeight = TextFieldTableViewCell.height
        tableView.backgroundColor = Colors.hex_f8f8f7_offWhite
        tableView.allowsSelection = false
        
        tableView.register(TextFieldTableViewCell.self)
        
        return tableView
    }()
    
    private lazy var saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped(_:)))
}

extension EditPasswordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditPasswordRow.allCases.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = EditPasswordRow.allCases[indexPath.row]
        let cell: TextFieldTableViewCell = tableView.dequeueReusableCell()
        
        switch row {
        case .currentPassword:
            cell.title = "Current Password"
            cell.placeholder = "••••••"
            cell.isFieldEnabled = true
            cell.contentType = .password
            cell.fieldText = newPasswordInfo?.currentPassword
            cell.fieldTextDidChange = { [weak self] newValue in
                self?.didChangeTextField(at: row, to: newValue)
            }
            
        case .newPassword:
            cell.title = "New Password"
            cell.placeholder = "••••••"
            cell.isFieldEnabled = true
            cell.contentType = .newPassword
            cell.fieldText = newPasswordInfo?.newPassword
            cell.fieldTextDidChange = { [weak self] newValue in
                self?.didChangeTextField(at: row, to: newValue)
            }
            
        case .passwordConfirmation:
            cell.title = "Confirm Password"
            cell.placeholder = "••••••"
            cell.isFieldEnabled = true
            cell.contentType = .newPassword
            cell.fieldText = newPasswordInfo?.passwordConfirmation
            cell.fieldTextDidChange = { [weak self] newValue in
                self?.didChangeTextField(at: row, to: newValue)
            }
        }
        
        return cell
    }
}

// MARK: - Handle Actions

extension EditPasswordViewController {
    private func didChangeTextField(at row: EditPasswordRow, to updatedValue: String) {
        let currentPassword = newPasswordInfo?.currentPassword ?? ""
        let newPassword = newPasswordInfo?.newPassword ?? ""
        let passwordConfirmation = newPasswordInfo?.passwordConfirmation ?? ""
        
        switch row {
        case .currentPassword:
            self.newPasswordInfo = NewPasswordInfo(currentPassword: updatedValue, newPassword: newPassword, passwordConfirmation: passwordConfirmation)
        case .newPassword:
            self.newPasswordInfo = NewPasswordInfo(currentPassword: currentPassword, newPassword: updatedValue, passwordConfirmation: passwordConfirmation)
        case .passwordConfirmation:
            self.newPasswordInfo = NewPasswordInfo(currentPassword: currentPassword, newPassword: newPassword, passwordConfirmation: updatedValue)
        }
    }
    @objc func saveTapped(_ barButtonItem: UIBarButtonItem) {
        view.endEditing(true)
        
        guard let newPasswordInfo = self.newPasswordInfo else {
            return displayErrorAlert(message: "Please fill out the fields below to continue.")
        }
        guard newPasswordInfo.newPasswordMatchesConfirmation else {
            return displayErrorAlert(message: "Your new password doesn't match the confirmation.")
        }
        guard newPasswordInfo.isValid else {
            return displayErrorAlert(message: "Please ensure your new password is \(NewPasswordInfo.minPasswordLength)+ characters.")
        }
        
        UserService.changePassword(newPasswordInfo) { [weak self] result in
            switch result {
            case .success(let message):
                self?.newPasswordInfo = nil
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.displayAlert(message: message)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.displayErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameBeginUserInfo = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
        
        let keyboardSize = keyboardFrameBeginUserInfo.cgRectValue
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
    }
}

// MARK: - Setup

extension EditPasswordViewController {
    fileprivate func setup() {
        title = "Edit Password"
        navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    private func installSubviews() {
        view.addSubview(tableView)
    }
    private func installConstraints() {
        let topConstraint = tableView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let leadingConstraint = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension EditPasswordViewController {
    private enum EditPasswordRow: CaseIterable {
        case currentPassword
        case newPassword
        case passwordConfirmation
    }
}
