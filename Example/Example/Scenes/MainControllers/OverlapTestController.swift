//
//  OverlapTestController.swift
//  Example
//
//  Created by Yasin TURKOGLU on 2.06.2020.
//  Copyright © 2020 Yasin TURKOGLU. All rights reserved.
//

import UIKit
import USController

class OverlapTestController: UIViewController {

    private var uscDataSource: USCDataSource?

    private lazy var parrotDetailViewModel = ParrotDetailViewModel()
    private lazy var parrotDetailController = ParrotDetailController(viewModel: parrotDetailViewModel)

    private lazy var parrotSelectionViewModel = ParrotSelectionViewModel()
    private lazy var parrotSelectionController = ParrotSelectionController(viewModel: parrotSelectionViewModel)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSplitController()
        setupParrotSelectionScene()
        setupParrotDetailScene()
    }

    // MARK: Universal Split Controller setup

    private func setupSplitController() {
        parrotSelectionController.leftBarButton.image = UIImage(named: "rightArrow")
        uscDataSource = USCDataSource.Builder(parentController: self)
            .setMasterController(parrotDetailController, embedInNavController: true)
            .setDetailController(parrotSelectionController, embedInNavController: true)
            .setAppearance(.invisibleInit)
            .setDirection(.trailing)
            .showBlockerOnMaster(color: .black, opacity: 0.1, allowInteractions: true)
            .swipeable()
            .setDetailBackground(color: .white, opacity: 0.5, blur: .light)
            .invokeAppearanceMethods()
            .overlapWhileInPortrait()
            .overlapWhileInLandscape()
            .portraitAnimationProperties(duration: 0.35, forwardDampingRatio: 0.5)
            .landscapeAnimationProperties(duration: 0.35, forwardDampingRatio: 0.5)
            .portraitCustomWidth(75.0, inPercentage: true)
            .landscapeCustomWidth(50.0, inPercentage: true)
            .visibilityChangesListener(willStartBlock: { [weak self] (targetVisibility) in
                guard let self = self else { return }
                self.updateDetailSceneBarButtonStatus(status: targetVisibility == .visible)
            })
            .build()
    }

    // MARK: Parrot Selection Scene setup

    private func setupParrotSelectionScene() {
        parrotSelectionViewModel.parrotSelectionHandler = { [weak self] parrot in
            guard let self = self else { return }
            self.parrotDetailViewModel.selectedParrot = parrot
        }
        parrotSelectionViewModel.barButtonActionHandler = { [weak self] in
            guard let self = self,
                let dataSource = self.uscDataSource else { return }
            dataSource.detailToggle()
        }
        parrotSelectionViewModel.createParrotsList()
        parrotDetailViewModel.selectedParrot = parrotSelectionViewModel.parrots.first
    }

    // MARK: Parrot Detail Scene setup

    private func setupParrotDetailScene() {
        parrotDetailViewModel.barButtonActionHandler = { [weak self] in
            guard let self = self,
                let dataSource = self.uscDataSource else { return }
            dataSource.detailToggle()
        }
    }

    private func updateDetailSceneBarButtonStatus(status: Bool) {
        guard let barButtonStatusUpdater = parrotDetailViewModel.barButtonStatusUpdater else { return }
        barButtonStatusUpdater(status)
    }

}
