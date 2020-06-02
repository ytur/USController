//
//  UniversalSplitController+CustomSwipeConfiguration.swift
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

extension UniversalSplitController: UIGestureRecognizerDelegate {

    func configureSwipe() {
        guard let currentDataSource = dataSource, currentDataSource.swipeable else { return }

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(recognizer:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)

        horizontalSwipeHandler = { [weak self ]state in
            guard let self = self else { return }
            switch state {
            case .began(let point):
                self.swipeBeganLogic(point: point)
            case .moved(let direction, let maximumChanges, let distance):
                self.swipeMovedLogic(direction: direction, maximumChanges: maximumChanges, distance: distance)
            case .ended:
                self.isHorizontalSwipeOccurred = .locked
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let currentDataSource = dataSource else { return false }
        return currentDataSource.couldBeBlockedByOtherEventsIfAny
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        guard let currentDataSource = dataSource else { return true }
        return !currentDataSource.couldBeBlockedByOtherEventsIfAny
    }

    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        guard let swipeHandler = horizontalSwipeHandler else { return }
        let position = recognizer.location(in: view)
        switch recognizer.state {
        case .began:
            startingPointOfSwipe = position.x
            maximumChanges = 0.0
            previousPosition = position
            swipeHandler(.began(point: position.x))
        case .changed:
            let diff = previousPosition.x - position.x
            var distance: CGFloat = 0.0
            if let currentStartingPointOfSwipe = startingPointOfSwipe {
                distance = CGFloat(fabsf(Float(currentStartingPointOfSwipe - position.x)))
            }
            let absoluteDifference = CGFloat(fabsf(Float(diff)))
            if absoluteDifference > maximumChanges {
                maximumChanges = absoluteDifference
            }
            if fabsf(Float(diff)) > 0 {
                swipeHandler(.moved(direction: diff, maximumChanges: maximumChanges, distance: distance))
            }
            previousPosition = position
        case .ended, .cancelled, .failed:
            startingPointOfSwipe = nil
            maximumChanges = 0.0
            previousPosition = .zero
            swipeHandler(.ended)
        default:
            break
        }
    }

    func swipeBeganLogic(point: CGFloat) {
        guard let currentDataSource = dataSource else { return }
        let viewWidth = view.bounds.size.width
        let swipeWidth = isLandscape() ? calculatedLandscapeWidth : portraitScreenWidth
        var limit: CGFloat = visibility == .visible ? swipeWidth < viewWidth ? 50.0 : 60.0 : 60.0
        isHorizontalSwipeOccurred = .locked
        let diff: CGFloat = (viewWidth - swipeWidth) < 0.0 ? 0.0 : (viewWidth - swipeWidth)
        let screenWidth = isLandscape() ? getLandscapeWidthOfScreen() : getPortraitWidthOfScreen()
        if currentDataSource.direction == .trailing {
            limit += getSafeAreaInsets().right
            if point >= viewWidth - limit && point <= viewWidth {
                isHorizontalSwipeOccurred = .trailingOpeningSequence
            } else if (swipeWidth == screenWidth && point >= diff && point <= limit) ||
                (swipeWidth != screenWidth && diff - limit >= 0.0 && point >= diff - (limit * 2.0) && point <= diff) ||
                (swipeWidth != screenWidth && diff - limit < 0.0 && point >= 0.0 && point <= limit) {
                isHorizontalSwipeOccurred = .trailingClosingSequence
            }
        } else if currentDataSource.direction == .leading {
            limit += getSafeAreaInsets().left
            if point >= 0.0 && point <= limit {
                isHorizontalSwipeOccurred = .leadingOpeningSequence
            } else if (swipeWidth == screenWidth && point >= viewWidth - limit && point <= viewWidth) ||
                (swipeWidth != screenWidth && diff - limit >= 0.0 && point >= swipeWidth &&
                    point <= swipeWidth + (limit * 2.0)) ||
                (swipeWidth != screenWidth && diff - limit < 0.0 && point >= viewWidth - limit && point <= viewWidth) {
                isHorizontalSwipeOccurred = .leadingClosingSequence
            }
        }
    }

    func swipeMovedLogic(direction: CGFloat, maximumChanges: CGFloat, distance: CGFloat) {
        let minimumChangingToTrigger: CGFloat = 10.0
        if isHorizontalSwipeOccurred != .locked && maximumChanges > minimumChangingToTrigger && distance >= 80.0 {
            if direction < 0.0 {
                if isHorizontalSwipeOccurred == .trailingClosingSequence && visibility == .visible {
                    detailToggle()
                } else if isHorizontalSwipeOccurred == .leadingOpeningSequence && visibility == .invisible {
                    detailToggle()
                }
            } else if direction > 0.0 {
                if isHorizontalSwipeOccurred == .trailingOpeningSequence && visibility == .invisible {
                    detailToggle()
                } else if isHorizontalSwipeOccurred == .leadingClosingSequence && visibility == .visible {
                    detailToggle()
                }
            }
            isHorizontalSwipeOccurred = .locked
        }
    }

}
