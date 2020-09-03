//
//  ViewController.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/2/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Data
    
    // ideally this would be passed into the view controller through dependency injection
    // after the log in, but per challenge requirements it's loaded in viewDidLoad
    private var user: User?
    private var unsavedProfileUpdate: ProfileUpdate?
    
    // MARK: - VC Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        installSubviews()
        installConstraints()
        
        UserService.me { [weak self] result in
            switch result {
            case .success(let user):
                self?.user =  user
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self?.displayErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerNotifications()
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
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
        tableView.delegate = self
        tableView.backgroundColor = Colors.hex_f8f8f7_offWhite
        
        tableView.register(SubtitleCell.self)
        tableView.register(TextFieldTableViewCell.self)
        
        return tableView
    }()

    private lazy var saveBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped(_:)))
        
        return barButtonItem
    }()
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return user != nil ? TableViewSections.allCases.count : 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tableViewSection = TableViewSections.allCases[section]
        return tableViewSection.numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = TableViewSections.allCases[indexPath.section]
        
        switch section {
        case .info:
            return profileCellAtRow(indexPath.row, in: tableView)
            
        case .security:
            return editPasswordCell(in: tableView)
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let tableViewSection = TableViewSections.allCases[section]
        return tableViewSection.titleForHeader
    }
    
    func profileCellAtRow(_ row: Int, in tableView: UITableView) -> TextFieldTableViewCell {
        let cell: TextFieldTableViewCell = tableView.dequeueReusableCell()
        cell.contentType = .default
        
        let row = ProfileInfoRow.allCases[row]
        switch row {
        case .username:
            cell.title = "Username"
            cell.placeholder = "kalesalad"
            cell.fieldText = user?.username
            cell.isFieldEnabled = false
            
        case .firstName:
            cell.title = "First Name"
            cell.placeholder = "Jane"
            cell.fieldText = user?.firstName
            cell.isFieldEnabled = true
            cell.fieldTextDidChange = { [weak self] newValue in
                self?.didChangeProfileField(at: row, to: newValue)
            }
            
        case .lastName:
            cell.title = "Last Name"
            cell.placeholder = "Doe"
            cell.fieldText = user?.lastName
            cell.isFieldEnabled = true
            cell.fieldTextDidChange = { [weak self] newValue in
                self?.didChangeProfileField(at: row, to: newValue)
            }
        }
        
        return cell
    }
    func editPasswordCell(in tableView: UITableView) -> SubtitleCell {
        let cell: SubtitleCell = tableView.dequeueReusableCell()
        cell.title = "Password"
        cell.subtitle = "Tap to change"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = TableViewSections.allCases[indexPath.section]
        return section.heightForRow
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case .security = TableViewSections.allCases[indexPath.section] else { return }
        
        let destinationViewController = EditPasswordViewController()
        navigationController?.pushViewController(destinationViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let section = TableViewSections.allCases[indexPath.section]
        switch section {
        case .info:
            return false
        case .security:
            return true
        }
    }
}

// MARK: Handle Actions

extension ProfileViewController {
    private func didChangeProfileField(at row: ProfileInfoRow, to updatedValue: String) {
        guard let user = user else {
            // this case should never happen, but fail gracefully if it does
            return displayErrorAlert(message: "Please wait a few moments for your profile to load before making an update.")
        }

        let currentFirstName = unsavedProfileUpdate?.firstName ?? user.firstName
        let currentLastName = unsavedProfileUpdate?.lastName ?? user.lastName
        
        switch row {
        case .firstName:
            self.unsavedProfileUpdate = ProfileUpdate(firstName: updatedValue, lastName: currentLastName)
        case .lastName:
            self.unsavedProfileUpdate = ProfileUpdate(firstName: currentFirstName, lastName: updatedValue)
        case .username:
            // user can't change username per challenge specs
            return
        }
    }
    
    @objc func saveTapped(_ barButtonItem: UIBarButtonItem) {
        view.endEditing(true)
        
        guard let user = user else {
            return displayErrorAlert(message: "Please wait a few moments for your profile to load before making an update.")
        }
        
        // basic validation
        guard let update = unsavedProfileUpdate,
            update.firstName != user.firstName || update.lastName != user.lastName else {
                return displayErrorAlert(message: "You haven't made any changes. Please update your profile and try again.")
            }
        
        UserService.updateProfile(update) { [weak self] result in
            switch result {
            case .success(let updatedUser):
                self?.user = updatedUser
                let section = IndexSet(arrayLiteral: TableViewSections.info.rawValue)
                self?.unsavedProfileUpdate = nil
                
                DispatchQueue.main.async {
                    self?.tableView.reloadSections(section, with: .automatic)
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

extension ProfileViewController {
    private func setupNavigationController() {
        title = "Profile"
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

extension ProfileViewController {
    private enum TableViewSections: Int, CaseIterable {
        case info
        case security
        
        var titleForHeader: String {
            switch self {
            case .info:  return "Info"
            case .security: return "Security"
            }
        }
        var numberOfRows: Int {
            switch self {
            case .info:  return 3
            case .security: return 1
            }
        }
        var heightForRow: CGFloat {
            switch self {
            case .info:  return TextFieldTableViewCell.height
            case .security: return SubtitleCell.height
            }
        }
    }
    
    private enum ProfileInfoRow: CaseIterable {
        case username
        case firstName
        case lastName
    }
}
