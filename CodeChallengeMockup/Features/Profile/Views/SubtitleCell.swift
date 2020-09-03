//
//  SubtitleCell.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/3/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import UIKit

class SubtitleCell: UITableViewCell {
    
    static let height: CGFloat = 50
    
    var title: String? {
        get { return textLabel?.text }
        set { textLabel?.text = newValue }
    }
    
    var subtitle: String? {
        get { return detailTextLabel?.text }
        set { detailTextLabel?.text = newValue }
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
