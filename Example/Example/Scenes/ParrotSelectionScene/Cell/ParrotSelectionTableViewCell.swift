//
//  ParrotSelectionTableViewCell.swift
//  Example
//
//  Created by Yasin TURKOGLU on 25.05.2020.
//  Copyright © 2020 Yasin TURKOGLU. All rights reserved.
//

import UIKit

class ParrotSelectionTableViewCell: UITableViewCell {

    var parrotImageData: Data? {
        didSet {
            guard let data = parrotImageData else { return }
            parrotImageView.image = UIImage(data: data)
        }
    }

    private lazy var parrotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(parrotImageView)
        parrotImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0).isActive = true
        parrotImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0).isActive = true
        let heightAnchor = parrotImageView.heightAnchor.constraint(equalToConstant: 50.0)
        heightAnchor.priority = UILayoutPriority(999)
        heightAnchor.isActive = true
        parrotImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5.0).isActive = true
        parrotImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5.0).isActive = true
        contentView.layoutIfNeeded()
    }

}
