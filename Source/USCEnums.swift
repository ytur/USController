//
//  USCEnums.swift
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

/// Options that define how the detail controller is displayed on screen.
///
public enum USCDetailAppearance {
    /// - Detail controller always be visible in portrait orientation for all devices
    /// except phones and user can toggle it to hide/show.
    /// - Detail controller always be visible in landscape orientation for all devices
    /// and user can toggle it to hide/show.
    ///
    case auto

    /// - Detail controller always be visible in all orientations for all devices
    /// and user can toggle it to hide/show.
    /// - Orientation changes make it visible if previously hidden.
    ///
    case visibleInit

    /// - Detail controller always be invisible in all orientations for all devices
    /// and user can toggle it to show/hide.
    /// - Orientation changes make it invisible if previously shown.
    ///
    case invisibleInit

    /// - Detail controller always be visible in all orientations for all devices
    /// and user can toggle it to hide/show.
    /// - Visibility won't affected by orientation changes.
    ///
    case visibleInitAndPreserveTheStatus

    /// - Detail controller always be invisible in all orientations for all devices
    /// and user can toggle it to show/hide.
    /// - Visibility won't affected by orientation changes.
    ///
    case invisibleInitAndPreserveTheStatus
}

/// Options that define the displaying direction of the detail controller on screen.
///
public enum USCDetailDirection {
    /// Detail controller appears from the left side of screen.
    ///
    case leading
    /// Detail controller appears from the right side of screen.
    ///
    case trailing
}

/// Options that define the visibility of the detail controller on screen.
///
public enum USCDetailVisibility {
    /// Detail controller visible on screen.
    ///
    case visible

    /// Detail controller invisible on screen.
    ///
    case invisible
}

public enum USCAnimationPreference {
    case auto
    case none
    case noneWithoutCompletion
}

public enum USCHorizontalSwipeState {
    case began(point: CGFloat)
    case moved(direction: CGFloat, maximumChanges: CGFloat, distance: CGFloat)
    case ended
}

public enum USCSwipeOccurrence {
    case locked
    case trailingOpeningSequence
    case trailingClosingSequence
    case leadingOpeningSequence
    case leadingClosingSequence
}
