//
//  UniversalSplitController+UIConfiguration.swift
//
//  Copyright © 2020 Yasin TURKOGLU.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

extension UniversalSplitController {

    func setupUI() {
        visibilityConfigurator(isLandscape: isLandscape(), isInitialConfiguration: true)
        setupmMasterHolder()
        setupDetailHolder()
        alignHolders()
        configureSwipe()
        animateUI(.none)
    }

    func visibilityConfigurator(isLandscape: Bool, isInitialConfiguration: Bool = false) {
        guard let currentDataSource = dataSource, !forceToHide else { return }
        if !isInitialConfiguration {
            previousVisibility = visibility
        }
        if currentDataSource.appearance == .invisibleInit {
            visibility = .invisible
        } else if currentDataSource.appearance == .invisibleInitAndPreserveTheStatus &&
            isInitialConfiguration {
            visibility = .invisible
        } else if currentDataSource.appearance == .visibleInit {
            visibility = .visible
        } else if currentDataSource.appearance == .visibleInitAndPreserveTheStatus &&
            isInitialConfiguration {
            visibility = .visible
        } else if currentDataSource.appearance == .auto &&
            isPhone() &&
            !isLandscape {
            visibility = .invisible
        } else if currentDataSource.appearance == .auto &&
            isPhone() &&
            isLandscape {
            visibility = .visible
        } else if currentDataSource.appearance == .auto &&
            !isPhone() {
            visibility = .visible
        }
        if isInitialConfiguration {
            previousVisibility = visibility == .visible ? .invisible : .visible
        }
    }

    func setupmMasterHolder() {
        view.addSubview(masterHolder)
        guard let currentDataSource = dataSource,
            var masterController = currentDataSource.masterController else { return }
        if currentDataSource.masterWillEmbedInNavController,
            let wrappedController = navigationControllerWrapper(masterController) {
            masterController = wrappedController
        }
        masterControllerReferance = masterController
    }

    func attachMasterController() {
        guard let masterController = masterControllerReferance,
            let masterControllerView = masterController.view  else { return }
        addChild(masterController)
        masterController.didMove(toParent: self)
        masterControllerView.translatesAutoresizingMaskIntoConstraints = false
        masterHolder.addSubview(masterControllerView)
        masterControllerView.topAnchor.constraint(equalTo: masterHolder.topAnchor).isActive = true
        masterControllerView.bottomAnchor.constraint(equalTo: masterHolder.bottomAnchor).isActive = true
        masterControllerView.leadingAnchor.constraint(equalTo: masterHolder.leadingAnchor).isActive = true
        masterControllerView.trailingAnchor.constraint(equalTo: masterHolder.trailingAnchor).isActive = true
        if let currentDataSource = dataSource,
            let contentBlockerColor = currentDataSource.contentBlockerColor {
            blocker.backgroundColor = contentBlockerColor
            masterHolder.addSubview(blocker)
            blocker.topAnchor.constraint(equalTo: masterHolder.topAnchor).isActive = true
            blocker.bottomAnchor.constraint(equalTo: masterHolder.bottomAnchor).isActive = true
            blocker.leadingAnchor.constraint(equalTo: masterHolder.leadingAnchor).isActive = true
            blocker.trailingAnchor.constraint(equalTo: masterHolder.trailingAnchor).isActive = true
        }
        masterHolder.layoutIfNeeded()
    }

    func isMasterControllerAttached() -> Bool {
        guard let masterController = masterControllerReferance else { return false }
        return masterController.parent != nil
    }

    func setupDetailHolder() {
        view.addSubview(detailHolder)
        guard let currentDataSource = dataSource,
            var detailController = currentDataSource.detailController else { return }
        if currentDataSource.detailWillEmbedInNavController,
            let wrappedController = navigationControllerWrapper(detailController) {
            detailController = wrappedController
        }
        detailControllerReferance = detailController
    }

    func attachDetailController() {
        guard let detailController = detailControllerReferance,
            let detailControllerView = detailController.view  else { return }
        addChild(detailController)
        detailController.didMove(toParent: self)
        detailControllerView.translatesAutoresizingMaskIntoConstraints = false
        detailHolder.addSubview(detailControllerView)
        detailControllerView.topAnchor.constraint(equalTo: detailHolder.topAnchor).isActive = true
        detailControllerView.bottomAnchor.constraint(equalTo: detailHolder.bottomAnchor).isActive = true
        detailControllerView.leadingAnchor.constraint(equalTo: detailHolder.leadingAnchor).isActive = true
        detailControllerView.trailingAnchor.constraint(equalTo: detailHolder.trailingAnchor).isActive = true
        detailHolder.layoutIfNeeded()
    }

    func isDetailControllerAttached() -> Bool {
        guard let detailController = detailControllerReferance else { return false }
        return detailController.parent != nil
    }

    func alignHolders() {
        guard let currentDataSource = dataSource else { return }
        if currentDataSource.direction == .trailing {
            masterHolder.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            masterHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            masterHolderLeading = masterHolder.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            masterHolderLeading.isActive = true
            masterHolderTrailing = masterHolder.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            masterHolderTrailing.isActive = true
            let startWidth = isLandscape() ? calculatedLandscapeWidth : portraitScreenWidth
            detailHolderWidth = detailHolder.widthAnchor.constraint(equalToConstant: startWidth)
            detailHolderWidth.isActive = true
            detailHolder.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            detailHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            detailHolder.leadingAnchor.constraint(equalTo: masterHolder.trailingAnchor).isActive = true
        } else if currentDataSource.direction == .leading {
            masterHolder.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            masterHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            masterHolderLeading = masterHolder.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            masterHolderLeading.isActive = true
            masterHolderTrailing = masterHolder.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            masterHolderTrailing.isActive = true
            let startWidth = isLandscape() ? calculatedLandscapeWidth : portraitScreenWidth
            detailHolderWidth = detailHolder.widthAnchor.constraint(equalToConstant: startWidth)
            detailHolderWidth.isActive = true
            detailHolder.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            detailHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            detailHolder.trailingAnchor.constraint(equalTo: masterHolder.leadingAnchor).isActive = true
        }
        view.layoutIfNeeded()
    }

}
