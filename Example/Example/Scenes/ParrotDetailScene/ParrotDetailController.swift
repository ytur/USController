//
//  ParrotDetailController.swift
//  Example
//
//  Created by Yasin TURKOGLU on 25.05.2020.
//  Copyright © 2020 Yasin TURKOGLU. All rights reserved.
//

import UIKit

class ParrotDetailController: UIViewController {

    private var viewModel: ParrotDetailViewModel!
    private lazy var rightBarButton: UIBarButtonItem = { [weak self] in
        let barButton = UIBarButtonItem(image: nil,
        style: .done,
        target: self,
        action: #selector(self?.barButtonAction))
        navigationItem.rightBarButtonItem = barButton
        return barButton
    }()

    private lazy var parrotViewer: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var parrotTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(viewModel: ParrotDetailViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        barButtonUpdate(status: true)
        viewModel.barButtonStatusUpdater = { [weak self] status in
            guard let self = self else { return }
            self.barButtonUpdate(status: status)
        }
        view.addSubview(parrotViewer)

        let topAnchor: NSLayoutYAxisAnchor = topLayoutGuide.bottomAnchor
        var bottomAnchor: NSLayoutYAxisAnchor = view.bottomAnchor
        var leadingAnchor: NSLayoutXAxisAnchor = view.leadingAnchor
        var trailingAnchor: NSLayoutXAxisAnchor = view.trailingAnchor
        if #available(iOS 11.0, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
            leadingAnchor = view.safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = view.safeAreaLayoutGuide.trailingAnchor
        }

        parrotViewer.topAnchor.constraint(equalTo: topAnchor, constant: 10.0).isActive = true
        parrotViewer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0).isActive = true
        parrotViewer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let widthConstraint = parrotViewer.widthAnchor.constraint(lessThanOrEqualToConstant: 414.0)
        widthConstraint.priority = UILayoutPriority(rawValue: 999)
        widthConstraint.isActive = true
        let leadingConstraint = parrotViewer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0)
        leadingConstraint.priority = UILayoutPriority(998)
        leadingConstraint.isActive = true
        let trailingConstraint = parrotViewer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0)
        trailingConstraint.priority = UILayoutPriority(rawValue: 998)
        trailingConstraint.isActive = true
        view.layoutIfNeeded()

        viewModel.parrotDetailUpdater = { [weak self] parrot in
            guard let self = self,
                let parrotData = parrot.data else { return }
            self.title = parrot.name
            self.parrotViewer.image = UIImage.gifImageWithData(parrotData)
        }
    }

    private func barButtonUpdate(status: Bool) {
        if status {
            rightBarButton.image = UIImage(named: "rightArrow")
        } else {
            rightBarButton.image = UIImage(named: "parrot")
        }
    }

    @objc func barButtonAction() {
        guard let parrotSelectionToggleHandler = viewModel.parrotSelectionToggleHandler else { return }
        parrotSelectionToggleHandler()
    }

}
