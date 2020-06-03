//
//  CustomButton.swift
//  Example
//
//  Created by Yasin TURKOGLU on 2.06.2020.
//  Copyright © 2020 Yasin TURKOGLU. All rights reserved.
//

import UIKit

public class CustomButton: UIControl {

    // MARK: Public access

    public var buttonActionHandler: ((CustomButton) -> Void)?

    override public var isEnabled: Bool {
        didSet {
            updateEnableState()
        }
    }

    public var title: String? {
        didSet {
            label.text = title
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setStyle()
        configureTargets()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Private access

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.isUserInteractionEnabled = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()

    private func setupUI() {
        contentView.fitInto(view: self)
        label.fitInto(view: contentView, paddings: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
    }

    private func setStyle() {
        if isEnabled {
            label.textColor = .white
            contentView.backgroundColor = .customButtonYellow
            contentView.layer.borderColor = UIColor.clear.cgColor
            contentView.layer.borderWidth = 0.0
            contentView.alpha = 1.0
        } else {
            updateEnableState()
        }
    }

    private func configureTargets() {
        addTarget(self, action: #selector(touchDownAction(button:)), for: .touchDown)
        addTarget(self, action: #selector(touchUpInsideAction(button:)), for: .touchUpInside)
        addTarget(self, action: #selector(touchUpOutsideCanceled(button:)), for: .touchUpInside)
        addTarget(self, action: #selector(touchUpOutsideCanceled(button:)), for: .touchUpOutside)
        addTarget(self, action: #selector(touchUpOutsideCanceled(button:)), for: .touchCancel)
    }

    private func updateEnableState() {
        isUserInteractionEnabled = isEnabled
        if isEnabled {
            setStyle()
        } else {
            label.textColor = .white
            contentView.backgroundColor = .customButtonDisableGray
            contentView.layer.borderColor = UIColor.clear.cgColor
            contentView.layer.borderWidth = 0.0
            contentView.alpha = 1.0
        }
    }

    @objc private func touchUpInsideAction(button: UIButton) {
        guard let receivedButtonActionHandler = buttonActionHandler else { return }
        receivedButtonActionHandler(self)
    }

    @objc private func touchDownAction(button: UIButton) {
        if isEnabled {
            label.textColor = .white
            contentView.backgroundColor = .customButtonYellow
            contentView.layer.borderColor = UIColor.clear.cgColor
            contentView.layer.borderWidth = 0.0
            contentView.alpha = 0.3
        }
    }

    @objc private func touchUpOutsideCanceled(button: UIButton) {
        if isEnabled {
            setStyle()
        }
    }

}
