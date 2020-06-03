//
//  UniversalSplitController+Helpers.swift
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

    func getPortraitWidthOfScreen() -> CGFloat {
        var absoulteSize = UIScreen.main.bounds.size
        if absoulteSize.width > absoulteSize.height {
            absoulteSize = CGSize(width: absoulteSize.height, height: absoulteSize.width)
        }
        return absoulteSize.width
    }

    func getLandscapeWidthOfScreen() -> CGFloat {
        var absoulteSize = UIScreen.main.bounds.size
        if absoulteSize.width > absoulteSize.height {
            absoulteSize = CGSize(width: absoulteSize.height, height: absoulteSize.width)
        }
        return absoulteSize.height
    }

    func isLandscape() -> Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }

    func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    func getSafeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows
            .first?
            .safeAreaInsets ?? .zero
        } else {
            return .zero
        }
    }

    func navigationControllerWrapper(_ controller: UIViewController) -> UINavigationController? {
        if !controller.isKind(of: UINavigationController.self) {
            let navigationController = UINavigationController(rootViewController: controller)
            return navigationController
        }
        return nil
    }

    func safeAreaAdditionForLandsacpe() -> CGFloat {
        guard #available(iOS 11.0, *),
            let currentDataSource = dataSource,
            let window = UIApplication.shared.windows.first,
            isLandscape(),
            let customWidth = isCustomWidthSetForLandscape else { return 0.0 }
        var returunValue: CGFloat = 0.0
        if currentDataSource.direction == .trailing {
            if customWidth < defaultMinWidth + window.safeAreaInsets.right {
                returunValue = window.safeAreaInsets.right
            }
        } else if currentDataSource.direction == .leading {
            if customWidth < defaultMinWidth + window.safeAreaInsets.left {
                returunValue = window.safeAreaInsets.left
            }
        }
        return returunValue
    }

    func masterControllerVisibilityCheckher(isLandscape: Bool) -> Bool {
        if !isPhone() || isLandscape {
            return true
        } else {
            if isPhone() && portraitScreenWidth == getPortraitWidthOfScreen() {
                if let currentDataSource = dataSource, currentDataSource.overlapWhileInPortrait {
                    return true
                }
                return visibility == .invisible
            } else {
                return true
            }
        }
    }

    func triggerDetailWillVisibility(isAppearing: Bool, animated: Bool) {
        if isDetailControllerAttached() {
            triggerDetailAppearance(isBegin: true, isAppearing: isAppearing, animated: animated)
        } else {
            if isAppearing {
                attachDetailController()
            }
        }
        guard let currentDataSource = dataSource,
            let visibilityWillStartBlock = currentDataSource.visibilityWillStartBlock else { return }
        visibilityWillStartBlock(visibility)
    }

    func triggerDetailDidVisibility(isAppearing: Bool, animated: Bool) {
        if isDetailControllerAttached() {
            if ignoreDetailAppearanceForOnce {
                ignoreDetailAppearanceForOnce = false
            } else {
                triggerDetailAppearance(isBegin: false, isAppearing: isAppearing, animated: animated)
            }
        }
        guard let currentDataSource = dataSource,
            let visibilityDidEndBlock = currentDataSource.visibilityDidEndBlock else { return }
        visibilityDidEndBlock(visibility)
    }

    func triggerDetailAppearance(isBegin: Bool, isAppearing: Bool, animated: Bool) {
        guard let detailController = detailControllerReferance,
            let currentDataSource = dataSource,
            currentDataSource.invokeAppearanceMethods else { return }
        if isBegin {
            detailController.beginAppearanceTransition(isAppearing, animated: animated)
        } else {
            detailController.endAppearanceTransition()
        }
        detailController.view.setNeedsLayout()
        detailHolder.setNeedsLayout()
        detailHolder.layoutIfNeeded()
    }

    func triggerMasterWillVisibility(isAppearing: Bool, animated: Bool) {
        if isMasterControllerAttached() {
            triggerMasterAppearance(isBegin: true,
                                    isAppearing: isAppearing,
                                    animated: animated)
        } else {
            if isAppearing {
                attachMasterController()
                isMasterControllerVisible = true
            }
        }
    }

    func triggerMasterDidVisibility(isAppearing: Bool, animated: Bool) {
        if isMasterControllerAttached() {
            if ignoreMasterAppearanceForOnce {
                ignoreMasterAppearanceForOnce = false
            } else {
                triggerMasterAppearance(isBegin: false,
                                        isAppearing: isAppearing,
                                        animated: animated)
            }
        }
    }

    func triggerMasterAppearance(isBegin: Bool, isAppearing: Bool, animated: Bool) {
        guard let masterController = masterControllerReferance,
            let currentDataSource = dataSource,
            currentDataSource.invokeAppearanceMethods else { return }
        if isMasterControllerVisible != isAppearing {
            if isBegin {
                masterController.beginAppearanceTransition(isAppearing, animated: animated)
            } else {
                masterController.endAppearanceTransition()
                isMasterControllerVisible = isAppearing
            }
            masterController.view.setNeedsLayout()
            masterController.view.layoutIfNeeded()
            masterHolder.setNeedsLayout()
            masterHolder.layoutIfNeeded()
        }
    }

}
