//
//  UIView+Extension.swift
//  Example
//
//  Created by Yasin TURKOGLU on 2.06.2020.
//  Copyright © 2020 Yasin TURKOGLU. All rights reserved.
//

import UIKit

public extension UIView {

    @discardableResult
    func fitInto(view: UIView, paddings: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        self.removeFromSuperview()
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = self.topAnchor.constraint(equalTo: view.topAnchor, constant: paddings.top)
        topConstraint.priority = UILayoutPriority(rawValue: 999)
        topConstraint.isActive = true
        let bottomConstraint = self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -paddings.bottom)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)
        bottomConstraint.isActive = true
        let leadingConstraint = self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: paddings.left)
        leadingConstraint.priority = UILayoutPriority(rawValue: 999)
        leadingConstraint.isActive = true
        let trailingConstraint = self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -paddings.right)
        trailingConstraint.priority = UILayoutPriority(rawValue: 999)
        trailingConstraint.isActive = true
        view.layoutIfNeeded()
        return [topConstraint, leadingConstraint, bottomConstraint, trailingConstraint]
    }

}
