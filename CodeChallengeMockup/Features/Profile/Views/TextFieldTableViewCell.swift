//
//  TextFieldTableViewCell.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/2/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    
    static let height: CGFloat = 44
    
    // MARK: - Interface
    
    enum ContentType {
        case `default`
        case password
        case newPassword
    }
    
    var contentType = ContentType.default {
        didSet {
            didUpdateContentType(contentType)
        }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var placeholder: String? {
        get { return textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    var fieldText: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    
    var isFieldEnabled: Bool {
        get { return textField.isEnabled }
        set { textField.isEnabled = newValue }
    }
    
    var fieldTextDidChange: ((String) -> Void)?
    
    // MARK: - Subviews
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.text_16
        
        return label
    }()
    private let textField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .right
        textField.returnKeyType = .done
        
        return textField
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        
        return stackView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
        installSubviews()
        installConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    private func didUpdateContentType(_ contentType: ContentType) {
        switch contentType {
        case .default:
            textField.isSecureTextEntry = false
            textField.keyboardType = .default
            textField.textContentType = .none
            textField.autocapitalizationType = .words
            
        case .password:
            textField.isSecureTextEntry = true
            textField.keyboardType = .default
            textField.textContentType = .password
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            
        case .newPassword:
            textField.isSecureTextEntry = true
            textField.keyboardType = .default
            textField.textContentType = .newPassword
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
    }
}

// MARK: - Setup

extension TextFieldTableViewCell {
    private func setup() {
        textField.delegate = self
        didUpdateContentType(contentType)
    }
    private func installSubviews() {
        contentView.addSubview(stackView)
    }
    private func installConstraints() {
        let titleWidth = 145 as CGFloat
        
        let constraints = [
            titleLabel.widthAnchor.constraint(equalToConstant: titleWidth),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension TextFieldTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        fieldTextDidChange?(textField.text ?? "")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
