//
//  ViewController.swift
//  Example
//
//  Created by Yasin TURKOGLU on 25.05.2020.
//  Copyright © 2020 Yasin TURKOGLU. All rights reserved.
//

import UIKit
import USController

class ViewController: UIViewController {

    private lazy var firstButton: CustomButton = {
        let button = CustomButton()
        button.title = "Split Controller Sample"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var secondButton: CustomButton = {
        let button = CustomButton()
        button.title = "Overlap Controller Sample"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirstButton()
        setupSecondButton()
    }

    private func setupFirstButton() {
        firstButton.buttonActionHandler = { [weak self] _ in
            guard let self = self else { return }
            self.swapPresented(with: SplitTestController())
        }

        view.addSubview(firstButton)
        let leadingConstraint = firstButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                                                 constant: 16.0)
        leadingConstraint.priority = UILayoutPriority(998)
        leadingConstraint.isActive = true
        let trailingConstraint = firstButton.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor,
                                                                   constant: -16.0)
        trailingConstraint.priority = UILayoutPriority(998)
        trailingConstraint.isActive = true
        firstButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        let widthConstraint = firstButton.widthAnchor.constraint(lessThanOrEqualToConstant: 414.0)
        widthConstraint.priority = UILayoutPriority(rawValue: 999)
        widthConstraint.isActive = true
        firstButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -8.0).isActive = true
        firstButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.layoutIfNeeded()
    }

    private func setupSecondButton() {
        secondButton.buttonActionHandler = { _ in
            self.swapPresented(with: OverlapTestController())
        }

        view.addSubview(secondButton)
        let leadingConstraint = secondButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                                                 constant: 16.0)
        leadingConstraint.priority = UILayoutPriority(998)
        leadingConstraint.isActive = true
        let trailingConstraint = secondButton.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor,
                                                                   constant: -16.0)
        trailingConstraint.priority = UILayoutPriority(998)
        trailingConstraint.isActive = true
        secondButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        let widthConstraint = secondButton.widthAnchor.constraint(lessThanOrEqualToConstant: 414.0)
        widthConstraint.priority = UILayoutPriority(rawValue: 999)
        widthConstraint.isActive = true
        secondButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 8.0).isActive = true
        secondButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.layoutIfNeeded()
    }

    private func swapPresented(with controller: UIViewController, animated: Bool = true) {
        controller.modalTransitionStyle = .flipHorizontal
        controller.modalPresentationStyle = .currentContext
        if presentedViewController != nil {
            dismiss(animated: animated, completion: nil)
        }
        present(controller, animated: animated, completion: nil)
    }

}
