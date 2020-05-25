//
//  UniversalSplitController.swift
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

class UniversalSplitController: UIViewController, USCDataSourceProtocol {

    var dataSource: USCDataSource?
    var previousVisibility: USCDetailVisibility = .invisible
    var visibility: USCDetailVisibility = .invisible
    var portraitScreenWidth: CGFloat = 0
    var landscapeScreenWidth: CGFloat = 0
    private (set) var calculatedLandscapeWidth: CGFloat {
        get {
            return landscapeScreenWidth + safeAreaAdditionForLandsacpe()
        }
        set { _ = newValue }
    }
    var isCustomWidthSetForLandscape: Bool = false
    var ignoreDetailAppearanceForOnce: Bool = true
    var ignoreMasterAppearanceForOnce: Bool = true
    var isMasterControllerVisible: Bool = false
    var isAnimationInProgress: Bool = false
    var horizontalSwipeHandler: ((USCHorizontalSwipeState) -> Void)?
    var startingPointOfSwipe: CGFloat?
    var maximumChanges: CGFloat = 0.0
    var previousPosition: CGPoint = .zero
    var isHorizontalSwipeOccurred: USCSwipeOccurrence = .locked

    lazy var masterHolder: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var detailHolder: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var masterHolderLeading: NSLayoutConstraint!
    var masterHolderTrailing: NSLayoutConstraint!
    var detailHolderWidth: NSLayoutConstraint!

    lazy var blocker: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var detailControllerReferance: UIViewController!
    var masterControllerReferance: UIViewController!

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupTheController(with dataSource: USCDataSource) {
        self.dataSource = dataSource
        setupInitialData()
        guard let parentController = dataSource.parentController,
            let parrentControllerView = parentController.view else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        parentController.addChild(self)
        didMove(toParent: parentController)
        parrentControllerView.addSubview(view)
        didMove(toParent: parentController)
        view.topAnchor.constraint(equalTo: parrentControllerView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: parrentControllerView.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: parrentControllerView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: parrentControllerView.trailingAnchor).isActive = true
        parentController.view.layoutIfNeeded()
        parentController.view.clipsToBounds = true
        view.clipsToBounds = true
    }

    func setupInitialData() {
        let minWidthForPortrait: CGFloat = 100.0
        let minWidthForLandscape: CGFloat = 100.0
        let defaultMaxWidth: CGFloat = 414.0
        let halfWidthOfPortrait: CGFloat = getPortraitWidthOfScreen() / 2.0
        let halfWidthOfLandscape: CGFloat = getLandscapeWidthOfScreen() / 2.0
        let portraitWidthExceptPhones = halfWidthOfPortrait < defaultMaxWidth ? halfWidthOfPortrait : defaultMaxWidth
        var landscapeWidthForAll: CGFloat = 0.0
        if getPortraitWidthOfScreen() > halfWidthOfLandscape {
            if halfWidthOfLandscape > defaultMaxWidth {
                landscapeWidthForAll = defaultMaxWidth
            } else {
                landscapeWidthForAll = halfWidthOfLandscape
            }
        } else {
            if getPortraitWidthOfScreen() > defaultMaxWidth {
                landscapeWidthForAll = defaultMaxWidth
            } else {
                landscapeWidthForAll = getPortraitWidthOfScreen()
            }
        }
        let portraitWidthForAll: CGFloat = isPhone() ? getPortraitWidthOfScreen() : portraitWidthExceptPhones
        portraitScreenWidth = portraitWidthForAll
        if let currentDataSource = dataSource,
            let customWidth = currentDataSource.customWidthForPortrait {
            if customWidth > halfWidthOfPortrait {
                portraitScreenWidth = halfWidthOfPortrait
            } else if customWidth < minWidthForPortrait {
                portraitScreenWidth = minWidthForPortrait
            } else {
                portraitScreenWidth = customWidth
            }
        }
        landscapeScreenWidth = landscapeWidthForAll
        if let currentDataSource = dataSource,
            let customWidth = currentDataSource.customWidthForLandscape {
            if customWidth > halfWidthOfLandscape {
                landscapeScreenWidth = halfWidthOfLandscape
            } else if customWidth < minWidthForLandscape {
                landscapeScreenWidth = minWidthForLandscape
            } else {
                landscapeScreenWidth = customWidth
                isCustomWidthSetForLandscape = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        var isTargetLandscape: Bool = false
        if size.width > size.height {
            isTargetLandscape = true
        }
        visibilityConfigurator(isLandscape: isTargetLandscape)
        triggerMasterWillVisibility(isAppearing: masterControllerVisibilityCheckher(isLandscape: isTargetLandscape),
                                    animated: true)
        if previousVisibility != visibility {
            triggerDetailWillVisibility(isAppearing: visibility == .visible, animated: true)
        }
        visibility = previousVisibility
        coordinator.animate(alongsideTransition: { [weak self] (_) in
            guard let self = self else { return }
            self.visibilityConfigurator(isLandscape: self.isLandscape())
            self.animateUI(.noneWithoutCompletion)
            self.view.layoutSubviews()
            }, completion: { [weak self] (_) in
                guard let self = self else { return }
                self.isAnimationInProgress = false
                if self.forceToHide && self.visibility == .visible {
                    self.detailToggle(animated: false)
                }
                self.triggerMasterDidVisibility(
                    isAppearing: self.masterControllerVisibilityCheckher(isLandscape: self.isLandscape()),
                    animated: true)
                guard self.previousVisibility != self.visibility else { return }
                self.triggerDetailDidVisibility(isAppearing: self.visibility == .visible, animated: true)
        })
    }

    // MARK: UniversalSplitControllerDataSourceProtocol stubs

    func getCurrentVisibility() -> USCDetailVisibility {
        return visibility
    }

    func detailToggle(animated: Bool = true) {
        guard !isAnimationInProgress else { return }
        previousVisibility = visibility
        if forceToHide {
            visibility = .invisible
        } else {
            visibility = visibility == .visible ? .invisible : .visible
        }
        animateUI(animated ? .auto : .none)
    }

    func disposeTheController() {
        if view.superview != nil {
            view.removeFromSuperview()
        }
        if parent != nil {
            willMove(toParent: nil)
            removeFromParent()
        }
    }

    var forceToHide: Bool = false {
        didSet {
            if forceToHide {
                detailToggle(animated: false)
            }
        }
    }

}
