//
//  USCDataSource.swift
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
// swiftlint:disable file_length

import UIKit

protocol USCDataSourceProtocol {
    func getCurrentVisibility() -> USCDetailVisibility
    func detailToggle(animated: Bool)
    func disposeTheController()
    var forceToHide: Bool { get set }
}

public class USCDataSource {
    typealias AnimationProperties = (duration: TimeInterval,
        options: UIView.AnimationOptions,
        forwardDampingRatio: CGFloat,
        rewindDampingRatio: CGFloat,
        velocity: CGFloat)
    private lazy var universalSplitController = UniversalSplitController()
    private(set) var parentController: UIViewController?
    private(set) var masterController: UIViewController?
    private(set) var masterWillEmbedInNavController: Bool = false
    private(set) var detailController: UIViewController?
    private(set) var detailWillEmbedInNavController: Bool = false
    private(set) var appearance: USCDetailAppearance = .auto
    private(set) var direction: USCDetailDirection = .trailing
    private(set) var contentBlockerColor: UIColor?
    private(set) var contentBlockerBlur: UIBlurEffect.Style?
    private(set) var contentBlockerInteractions: Bool?
    private(set) var customWidthForPortrait: CGFloat?
    private(set) var widthInPercentageForPortrait: Bool = false
    private(set) var customWidthForLandscape: CGFloat?
    private(set) var widthInPercentageForLandscape: Bool = false
    private(set) var overlapWhileInPortrait: Bool = false
    private(set) var overlapWhileInLandscape: Bool = false
    private(set) var visibilityWillStartBlock: ((USCDetailVisibility) -> Void)?
    private(set) var visibilityAnimationBlock: ((USCDetailVisibility) -> Void)?
    private(set) var visibilityDidEndBlock: ((USCDetailVisibility) -> Void)?
    private(set) var swipeable: Bool = false
    private(set) var detailBackgroundColor: UIColor?
    private(set) var detailBackgroundBlur: UIBlurEffect.Style?
    private(set) var couldBeBlockedByOtherEventsIfAny: Bool = false
    private(set) var invokeAppearanceMethods: Bool = false
    private(set) var animationPropsForPortrait = AnimationProperties(duration: 0.35,
                                                                          options: .curveEaseInOut,
                                                                          forwardDampingRatio: 1.0,
                                                                          rewindDampingRatio: 1.0,
                                                                          velocity: 1.0)
    private(set) var animationPropsForLandscape = AnimationProperties(duration: 0.35,
                                                                           options: .curveEaseInOut,
                                                                           forwardDampingRatio: 1.0,
                                                                           rewindDampingRatio: 1.0,
                                                                           velocity: 1.0)
    /// Builder object should be initiated with `parentController` parameter
    /// to specify where the USController will append as child controller.
    ///
    public class Builder {

        private let dataSource = USCDataSource()
        /// Builder object should be initiated with `parentController` parameter
        /// to specify where the USController will append as child controller.
        ///
        /// - Parameters:
        ///     - parentController: The controller where the USController will append as child controller.
        ///
        public init(parentController: UIViewController) {
            dataSource.parentController = parentController
        }
        /// It specifies the controller which will be placed in master controller division of the screen.
        ///
        /// - Parameters:
        ///     - controller: The controller which will be placed in.
        ///     - embedInNavController: If parameter takes true,
        ///     the controller embed in to the navigation controller before place in. Default value is false.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func setMasterController(_ controller: UIViewController, embedInNavController: Bool = false) -> Builder {
            dataSource.masterController = controller
            dataSource.masterWillEmbedInNavController = embedInNavController
            return self
        }
        /// It specifies the controller which will be placed in master controller division of the screen.
        ///
        /// - Parameters:
        ///     - storyboardName: The name of the storyboard resource file without the filename extension.
        ///     - bundle: The bundle containing the storyboard file and its related resources.
        ///     If you specify nil, this method looks in the main bundle of the current application.
        ///     - identifier: An identifier string that uniquely identifies the view controller in the storyboard file.
        ///     At design time, put this same string in the Storyboard ID attribute of your view controller
        ///     in Interface Builder. This identifier is not a property of the view controller object itself.
        ///     The storyboard uses it to locate the appropriate data for your view controller.
        ///     If the specified identifier does not exist in the storyboard file, this method raises an exception.
        ///     If you specify nil, this method looks in the initial controller of the storyboard.
        ///     - embedInNavController: If parameter takes true,
        ///     the controller embed in to the navigation controller before place in. Default value is false.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func setMasterControllerFrom(storyboardName: String,
                                            bundle: Bundle? = nil,
                                            identifier: String? = nil,
                                            embedInNavController: Bool = false) -> Builder {
            let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
            if let identifier = identifier {
                dataSource.masterController = storyboard.instantiateViewController(withIdentifier: identifier)
            } else {
                dataSource.masterController = storyboard.instantiateInitialViewController()!
            }
            dataSource.masterWillEmbedInNavController = embedInNavController
            return self
        }
        /// It specifies the controller which will be placed in detail controller division of the screen.
        ///
        /// - Parameters:
        ///     - controller: The controller which will be placed in.
        ///     - embedInNavController: If parameter takes true,
        ///     the controller embed in to the navigation controller before place in. Default value is false.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func setDetailController(_ controller: UIViewController, embedInNavController: Bool = false) -> Builder {
            dataSource.detailController = controller
            dataSource.detailWillEmbedInNavController = embedInNavController
            return self
        }
        /// It specifies the controller which will be placed in detail controller division of the screen.
        ///
        /// - Parameters:
        ///     - storyboardName: The name of the storyboard resource file without the filename extension.
        ///     - bundle: The bundle containing the storyboard file and its related resources.
        ///     If you specify nil, this method looks in the main bundle of the current application.
        ///     - identifier: An identifier string that uniquely identifies the view controller in the storyboard file.
        ///     At design time, put this same string in the Storyboard ID attribute of your view controller
        ///     in Interface Builder. This identifier is not a property of the view controller object itself.
        ///     The storyboard uses it to locate the appropriate data for your view controller.
        ///     If the specified identifier does not exist in the storyboard file, this method raises an exception.
        ///     If you specify nil, this method looks in the initial controller of the storyboard.
        ///     - embedInNavController: If parameter takes true,
        ///     the controller embed in to the navigation controller before place in. Default value is false.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func setDetailControllerFrom(storyboardName: String,
                                            bundle: Bundle? = nil,
                                            identifier: String? = nil,
                                            embedInNavController: Bool = false) -> Builder {
            let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
            if let identifier = identifier {
                dataSource.detailController = storyboard.instantiateViewController(withIdentifier: identifier)
            } else {
                dataSource.detailController = storyboard.instantiateInitialViewController()!
            }
            dataSource.detailWillEmbedInNavController = embedInNavController
            return self
        }
        /// It specifies the option that define how the detail controller is displayed on the screen.
        ///
        /// - Parameters:
        ///     - appearance: The option that specify how detail controller will display.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        /// - If  this method won't be included in builder chain, default value will be `auto` for detail controller.
        ///
        public func setAppearance(_ appearance: USCDetailAppearance) -> Builder {
            dataSource.appearance = appearance
            return self
        }
        /// It specifies the option that define the displaying direction of the detail controller on screen.
        ///
        /// - Parameters:
        ///     - direction: The option that specify the displaying direction of the detail controller.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        /// - If  this method won't be included in builder chain,
        /// default value will be `trailing` for detail controller.
        ///
        public func setDirection(_ direction: USCDetailDirection) -> Builder {
            dataSource.direction = direction
            return self
        }
        /// It blocks user interactions of the master controller with a view to be placed on
        /// top of the master controller while both in detail and master controller appears on the screen.
        ///
        /// - Parameters:
        ///     - color: Custom color of content blocker.
        ///     - opacity: Custom opacity of content blocker. The opacity value specified as a value f
        ///     rom 0.0 to 1.0. Alpha values below 0.0 are interpreted as 0.0,
        ///     and values above 1.0 are interpreted as 1.0
        ///     - blur: The intensity of the blur effect. See UIBlurEffect.Style for valid options.
        ///     - allowInteractions: If parameter takes true, it allows the user interactions while blocker displayed.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func showBlockerOnMaster(color: UIColor,
                                        opacity: CGFloat = 1.0,
                                        blur: UIBlurEffect.Style? = nil,
                                        allowInteractions: Bool = false) -> Builder {
            dataSource.contentBlockerColor = color.withAlphaComponent(opacity)
            dataSource.contentBlockerBlur = blur
            dataSource.contentBlockerInteractions = allowInteractions
            return self
        }
        /// It sets a background color and optionally apply a blur effect to the background of detail controller.
        ///
        /// - Parameters:
        ///     - color: Custom color for detail controller background.
        ///     - opacity: Custom opacity of detail controller background. The opacity value specified as a value f
        ///     rom 0.0 to 1.0. Alpha values below 0.0 are interpreted as 0.0,
        ///     and values above 1.0 are interpreted as 1.0
        ///     - blur: The intensity of the blur effect. See UIBlurEffect.Style for valid options.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func setDetailBackground(color: UIColor,
                                        opacity: CGFloat = 1.0,
                                        blur: UIBlurEffect.Style? = nil) -> Builder {
            dataSource.detailBackgroundColor = color.withAlphaComponent(opacity)
            dataSource.detailBackgroundBlur = blur
            return self
        }
        /// It makes the detail controller swipeable with UI Gestures to hide or show it.
        ///
        /// - Parameters:
        ///     - couldBeBlockedByOtherEventsIfAny: If parameter takes true, it allows to suppress
        ///     recognizer responsible for the detail controller toggling while other gesture recognizers,
        ///     touch or press events are in use on placed controllers. Default value is false
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func swipeable(couldBeBlockedByOtherEventsIfAny: Bool = false) -> Builder {
            dataSource.swipeable = true
            dataSource.couldBeBlockedByOtherEventsIfAny = couldBeBlockedByOtherEventsIfAny
            return self
        }
        /// It allows calling the appearance methods (viewWillAppear, viewDidAppear,
        /// viewWillDisappear, viewDidDisappear) of master and detail controllers
        /// which invokes by their visibility changes.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func invokeAppearanceMethods() -> Builder {
            dataSource.invokeAppearanceMethods = true
            return self
        }
        /// It overlap detail controller over master controller rather than splitting them while in portrait.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func overlapWhileInPortrait() -> Builder {
            dataSource.overlapWhileInPortrait = true
            return self
        }
        /// It overlap detail controller over master controller rather than splitting them while in landscape.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func overlapWhileInLandscape() -> Builder {
            dataSource.overlapWhileInLandscape = true
            return self
        }
        /// It allows you to define custom width for detail controller while in portrait.
        ///
        /// - Parameters:
        ///     - customWidth: Width or percent value to define custom width for detail while in portrait.
        ///     - inPercentage: If parameter takes true, "customWidth" parameter will takes value
        ///     between 0 .0 - 100.0 for defining detail width as percentage of screen width while in portrait.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        /// - Custom width can not be greater than half of the screen width
        /// while in portrait and smaller than 100px.
        /// - If this method won't be included in builder chain, default width value for the detail controller
        /// while in portrait will vary according to current device type and all cases were explained below:
        ///
        /// **Phones =>** Screen width
        ///
        /// **Pads =>** If half of the screen width is smaller than 414px,
        /// it will be equal to the half of the screen width. Otherwise it will be 414px.
        ///
        public func portraitCustomWidth(_ customWidth: CGFloat, inPercentage: Bool = false) -> Builder {
            dataSource.customWidthForPortrait = CGFloat(fabsf(Float(customWidth)))
            dataSource.widthInPercentageForPortrait = inPercentage
            return self
        }
        /// It allows you to define custom width for detail controller while in landscape.
        ///
        /// - Parameters:
        ///     - customWidth: Width or percent value to define custom width for detail while in landscape.
        ///     - inPercentage: If parameter takes true, "customWidth" parameter will takes value
        ///     between 0 .0 - 100.0 for defining detail width as percentage of screen width while in landscape.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        /// - If this method won't be included in builder chain, default width value for the detail controller
        /// while in landscape will vary device type independent and all cases were explained below:
        ///
        /// ** If screen width while in portrait greater than half of the screen width while in landscape:**
        ///
        /// **case 1 =>** If half of the screen width greater than 414px while in landscape,
        /// so detail controller width will be equal to 414px.
        ///
        /// **case 2 =>** If half of the screen width smaller than 414px while in landscape,
        /// than detail controller width will be equal to half of the screen width while in landscape.
        ///
        /// ** If screen width while in portrait smaller than half of the screen width while in landscape:**
        ///
        /// **case 1 =>** If screen width greater than 414px while in portrait,
        /// so detail controller width will be equal to 414px.
        ///
        /// **case 2 =>**If screen width smaller than 414px while in portrait,
        /// than detail controller width will be equal to screen width while in portrait.
        ///
        public func landscapeCustomWidth(_ customWidth: CGFloat, inPercentage: Bool = false) -> Builder {
            dataSource.customWidthForLandscape = CGFloat(fabsf(Float(customWidth)))
            dataSource.widthInPercentageForLandscape = inPercentage
            return self
        }
        /// Detail controller visibility changes can be observable by this method's closure arguments.
        ///
        /// - Parameters:
        ///     - willStartBlock: A block object to be executed before the visibility animation starts.
        ///     This block has no return value and takes a single enum argument that indicates
        ///     target visibility of detail controller when animation actually finished. This parameter may be NULL.
        ///     
        ///     - animationBlock: A block object to be executed when the detail controller
        ///     visibility change animation ongoing. This block has no return value and takes a
        ///     single enum argument that indicates target visibility of detail controller
        ///     when animation actually finished. This parameter may be NULL.
        ///     
        ///     - didEndBlock: A block object to be executed when the visibility animation ends.
        ///     This block has no return value and takes a single enum argument that indicates
        ///     final visibility of detail controller when animation actually finished. This parameter may be NULL.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func visibilityChangesListener(
            willStartBlock: ((USCDetailVisibility) -> Void)? = nil,
            animationBlock: ((USCDetailVisibility) -> Void)? = nil,
            didEndBlock: ((USCDetailVisibility) -> Void)? = nil
        ) -> Builder {
            dataSource.visibilityWillStartBlock = willStartBlock
            dataSource.visibilityAnimationBlock = animationBlock
            dataSource.visibilityDidEndBlock = didEndBlock
            return self
        }
        /// Its set detail controller's toggling animation while in portrait
        /// using a timing curve corresponding to the motion of a physical spring.
        ///
        /// - Parameters:
        ///     - duration: The total duration of the animations, measured in seconds.
        ///     If you specify a negative value or 0, the changes are made without animating them.
        ///
        ///     - options: A mask of options indicating how you want to perform the animations.
        ///     For a list of valid constants, see UIView.AnimationOptions.
        ///
        ///     - forwardDampingRatio: The damping ratio for the spring animation while detail controller opening.
        ///     To smoothly decelerate the animation without oscillation, use a value of 1.
        ///     Employ a damping ratio closer to zero to increase oscillation.
        ///     
        ///     - rewindDampingRatio:The damping ratio for the spring animation while detail controller closing.
        ///     To smoothly decelerate the animation without oscillation, use a value of 1.
        ///     Employ a damping ratio closer to zero to increase oscillation.
        ///
        ///     - velocity: The initial spring velocity. For smooth start to the animation,
        ///     match this value to the view’s velocity as it was prior to attachment.
        ///     A value of 1 corresponds to the total animation distance traversed in one second.
        ///     For example, if the total animation distance is 200 points and you want the start of the animation
        ///     to match a view velocity of 100 pt/s, use a value of 0.5.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func portraitAnimationProperties(duration: TimeInterval,
                                                options: UIView.AnimationOptions = .curveEaseInOut,
                                                forwardDampingRatio: CGFloat = 1.0,
                                                rewindDampingRatio: CGFloat = 1.0,
                                                velocity: CGFloat = 1.0) -> Builder {
            dataSource.animationPropsForPortrait = AnimationProperties(duration: duration,
                                                                            options: options,
                                                                            forwardDampingRatio: forwardDampingRatio,
                                                                            rewindDampingRatio: rewindDampingRatio,
                                                                            velocity: velocity)
            return self
        }
        /// Its set detail controller's toggling animation while in landscape
        /// using a timing curve corresponding to the motion of a physical spring.
        ///
        /// - Parameters:
        ///     - duration: The total duration of the animations, measured in seconds.
        ///     If you specify a negative value or 0, the changes are made without animating them.
        ///
        ///     - options: A mask of options indicating how you want to perform the animations.
        ///     For a list of valid constants, see UIView.AnimationOptions.
        ///
        ///     - forwardDampingRatio: The damping ratio for the spring animation while detail controller opening.
        ///     To smoothly decelerate the animation without oscillation, use a value of 1.
        ///     Employ a damping ratio closer to zero to increase oscillation.
        ///
        ///     - rewindDampingRatio:The damping ratio for the spring animation while detail controller closing.
        ///     To smoothly decelerate the animation without oscillation, use a value of 1.
        ///     Employ a damping ratio closer to zero to increase oscillation.
        ///
        ///     - velocity: The initial spring velocity. For smooth start to the animation,
        ///     match this value to the view’s velocity as it was prior to attachment.
        ///     A value of 1 corresponds to the total animation distance traversed in one second.
        ///     For example, if the total animation distance is 200 points and you want the start of the animation
        ///     to match a view velocity of 100 pt/s, use a value of 0.5.
        ///
        /// - Returns: Builder object returns so that the next method can be called.
        ///
        /// - Absence of this method in builder chain won't affect the build process.
        ///
        public func landscapeAnimationProperties(duration: TimeInterval,
                                                 options: UIView.AnimationOptions = .curveEaseInOut,
                                                 forwardDampingRatio: CGFloat = 1.0,
                                                 rewindDampingRatio: CGFloat = 1.0,
                                                 velocity: CGFloat = 1.0) -> Builder {
            dataSource.animationPropsForLandscape = AnimationProperties(duration: duration,
                                                                        options: options,
                                                                        forwardDampingRatio: forwardDampingRatio,
                                                                        rewindDampingRatio: rewindDampingRatio,
                                                                        velocity: velocity)
            return self
        }
        /// Once the USController is completely configured, this method must be called to construct the builder object.
        ///
        /// - Returns: Datasource object returns for be able to access runtime properties and methods.
        ///
        @discardableResult
        public func build() -> USCDataSource {
            dataSource.universalSplitController.setupTheController(with: dataSource)
            return dataSource
        }

    }

    public init() { }
    /// It returns current visibility state of detail controller.
    /// 
    /// - Returns: USCDetailVisibility
    ///
    public func getCurrentVisibility() -> USCDetailVisibility {
        return universalSplitController.getCurrentVisibility()
    }
    /// It changes current visibility state of detail controller between "visible" and "invisible"
    ///
    public func detailToggle() {
        universalSplitController.detailToggle()
    }
    /// It removes the USController and views permanently from its parent controller and view.
    ///
    public func disposeTheController() {
        universalSplitController.disposeTheController()
    }
    /// Default value of this parameter is "false". When it will set as "true",
    /// detail controller will be immediately dissmissed from screen
    /// and visibility state will turning to "invisible". Detail controller won't be visible again
    /// by visibility or orientation changes until setting this parameter to "false".
    ///
    /// - Setting this parameter to its default value back, won’t make the detail controller
    /// visible automatically and action may be required to displaying it again.
    /// (calling detailToggle, swipe action or orientation change if configured.)
    ///
    public var forceToHide: Bool = false {
        didSet {
            universalSplitController.forceToHide = forceToHide
        }
    }
}
