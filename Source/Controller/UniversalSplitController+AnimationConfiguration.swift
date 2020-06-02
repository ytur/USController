//
//  UniversalSplitController+AnimationConfiguration.swift
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

    func animateUI(_ animated: USCAnimationPreference = .auto) {
        guard let currentDataSource = dataSource else { return }
        if visibility == .visible {
            if currentDataSource.direction == .trailing && isLandscape() {
                visibleTrailingLandscapeConstraints(showOnTop: currentDataSource.overlapWhileInLandscape)
            } else if currentDataSource.direction == .trailing && !isLandscape() {
                visibleTrailingPortraitConstraints(showOnTop: currentDataSource.overlapWhileInPortrait)
            } else if currentDataSource.direction == .leading && isLandscape() {
                visibleLeadingLandscapeConstraints(showOnTop: currentDataSource.overlapWhileInLandscape)
            } else if currentDataSource.direction == .leading && !isLandscape() {
                visibleLeadingPortraitConstraints(showOnTop: currentDataSource.overlapWhileInPortrait)
            }
        } else if visibility == .invisible {
            invisiblityConstraints()
        }
        commitAnimation(animated)
    }

    func commitAnimation(_ animated: USCAnimationPreference = .auto) {
        guard let currentDataSource = dataSource else { return }
        isAnimationInProgress = true
        if animated == .none {
            withoutAnimation()
        } else if animated == .noneWithoutCompletion {
            if currentDataSource.contentBlockerColor != nil {
                let interactions = currentDataSource.contentBlockerInteractions ?? false
                blocker.isUserInteractionEnabled = interactions ? false : visibility == .visible
                blocker.alpha = visibility == .visible ? 1.0 : 0.0
            }
            if let visibilityAnimationBlock = currentDataSource.visibilityAnimationBlock,
                previousVisibility != visibility {
                visibilityAnimationBlock(visibility)
            }
            view.layoutIfNeeded()
        } else {
            animation()
        }
    }

    func withoutAnimation() {
        guard let currentDataSource = dataSource else { return }
        if currentDataSource.contentBlockerColor != nil {
            let interactions = currentDataSource.contentBlockerInteractions ?? false
            blocker.isUserInteractionEnabled = interactions ? false : visibility == .visible
            blocker.alpha = visibility == .visible ? 1.0 : 0.0
        }

        triggerMasterWillVisibility(isAppearing: masterControllerVisibilityCheckher(isLandscape: isLandscape()),
                                    animated: false)
        if previousVisibility != visibility {
            triggerDetailWillVisibility(isAppearing: visibility == .visible, animated: false)
            if let visibilityAnimationBlock = currentDataSource.visibilityAnimationBlock {
                visibilityAnimationBlock(visibility)
            }
            view.layoutIfNeeded()
        }
        triggerMasterDidVisibility(isAppearing: masterControllerVisibilityCheckher(isLandscape: isLandscape()),
                                   animated: false)
        if previousVisibility != visibility {
            triggerDetailDidVisibility(isAppearing: visibility == .visible, animated: false)
        }
        isAnimationInProgress = false
        if forceToHide && visibility == .visible {
            detailToggle(animated: false)
        }
    }

    func animation() {
        guard let currentDataSource = dataSource else { return }
        triggerMasterWillVisibility(isAppearing: masterControllerVisibilityCheckher(isLandscape: isLandscape()),
                                    animated: true)
        if previousVisibility != visibility {
            triggerDetailWillVisibility(isAppearing: visibility == .visible, animated: true)
        }
        UIView.animate(withDuration: 0.35,
                       delay: 0.0, usingSpringWithDamping: 5.5,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                        guard let self = self else { return }
                        if currentDataSource.contentBlockerColor != nil {
                            let interactions = currentDataSource.contentBlockerInteractions ?? false
                            self.blocker.isUserInteractionEnabled = interactions ? false : self.visibility == .visible
                            self.blocker.alpha = self.visibility == .visible ? 1.0 : 0.0
                        }
                        if let visibilityAnimationBlock = currentDataSource.visibilityAnimationBlock,
                            self.previousVisibility != self.visibility {
                            visibilityAnimationBlock(self.visibility)
                        }
                        self.view.layoutIfNeeded()
            }, completion: { [weak self] (_) in
                guard let self = self else { return }
                if currentDataSource.contentBlockerColor != nil {
                    let interactions = currentDataSource.contentBlockerInteractions ?? false
                    self.blocker.isUserInteractionEnabled = interactions ? false : self.visibility == .visible
                    self.blocker.alpha = self.visibility == .visible ? 1.0 : 0.0
                }
                self.triggerMasterDidVisibility(
                    isAppearing: self.masterControllerVisibilityCheckher(isLandscape: self.isLandscape()),
                    animated: true)
                if self.previousVisibility != self.visibility {
                    self.triggerDetailDidVisibility(isAppearing: self.visibility == .visible, animated: true)
                }
                self.isAnimationInProgress = false
                if self.forceToHide && self.visibility == .visible {
                    self.detailToggle(animated: false)
                }
        })
    }

    func visibleTrailingLandscapeConstraints(showOnTop: Bool) {
        masterHolderLeading.constant = 0.0
        masterHolderTrailing.constant = showOnTop ? 0.0 : -calculatedLandscapeWidth
        detailHolderWidth.constant = calculatedLandscapeWidth
        detailHolderLeading.constant = showOnTop ? -calculatedLandscapeWidth : 0.0
    }

    func visibleTrailingPortraitConstraints(showOnTop: Bool) {
        if isPhone() && portraitScreenWidth == getPortraitWidthOfScreen() {
            masterHolderLeading.constant = showOnTop ? 0.0 : -portraitScreenWidth
            masterHolderTrailing.constant = showOnTop ? 0.0 : -portraitScreenWidth
            detailHolderWidth.constant = portraitScreenWidth
            detailHolderLeading.constant = showOnTop ? -portraitScreenWidth : 0.0
        } else {
            masterHolderLeading.constant = 0.0
            masterHolderTrailing.constant = showOnTop ? 0.0 : -portraitScreenWidth
            detailHolderWidth.constant = portraitScreenWidth
            detailHolderLeading.constant = showOnTop ? -portraitScreenWidth : 0.0
        }
    }

    func visibleLeadingLandscapeConstraints(showOnTop: Bool) {
        masterHolderLeading.constant = showOnTop ? 0.0 : calculatedLandscapeWidth
        masterHolderTrailing.constant = 0.0
        detailHolderWidth.constant = calculatedLandscapeWidth
        detailHolderTrailing.constant = showOnTop ? calculatedLandscapeWidth : 0.0
    }

    func visibleLeadingPortraitConstraints(showOnTop: Bool) {
        if isPhone() && portraitScreenWidth == getPortraitWidthOfScreen() {
            masterHolderLeading.constant = showOnTop ? 0.0 : portraitScreenWidth
            masterHolderTrailing.constant = showOnTop ? 0.0 : portraitScreenWidth
            detailHolderWidth.constant = portraitScreenWidth
            detailHolderTrailing.constant = showOnTop ? portraitScreenWidth : 0.0
        } else {
            masterHolderLeading.constant = showOnTop ? 0.0 : portraitScreenWidth
            masterHolderTrailing.constant = 0.0
            detailHolderWidth.constant = portraitScreenWidth
            detailHolderTrailing.constant = showOnTop ? portraitScreenWidth : 0.0
        }
    }

    func invisiblityConstraints() {
        masterHolderLeading.constant = 0.0
        masterHolderTrailing.constant = 0.0
        detailHolderWidth.constant = isLandscape() ? calculatedLandscapeWidth : portraitScreenWidth
        guard let currentDataSource = dataSource else { return }
        if currentDataSource.direction == .trailing {
            detailHolderLeading.constant = 0.0
        } else if currentDataSource.direction == .leading {
            detailHolderTrailing.constant = 0.0
        }
    }

}
