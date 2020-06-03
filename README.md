![USController](https://raw.githubusercontent.com/ytur/USController/master/icon.png)
<br/>
More customizable <b>U</b>niversal <b>S</b>plit <b>Controller</b> for IOS device family.

[![Platform](https://img.shields.io/cocoapods/p/USController.svg?style=flat)](https://cocoapods.org/pods/USController)
[![License](https://img.shields.io/cocoapods/l/USController.svg?style=flat)](https://cocoapods.org/pods/USController)
[![Version](https://img.shields.io/cocoapods/v/USController.svg?style=flat)](https://cocoapods.org/pods/USController)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

## Example
### Download Example party-parrot project from repo to poke around.<br/>
![iPhone-example](http://forum.yasinturkoglu.com/uploads/USController/USController-iPhone.gif)
![iPad-example](http://forum.yasinturkoglu.com/uploads/USController/USController-iPad.gif)

## Requirements

• iOS 9.0+ 

• Xcode 11.0+

## Installation

#### CocoaPods

USController is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'USController'
```

#### Carthage 

You can use Carthage to install USController by adding it to your Cartfile:
```ruby
github "ytur/USController"
```
If you use Carthage to build your dependencies, make sure you have added USController.framework to the "Linked Frameworks and Libraries" section of your target, and have included them in your Carthage framework copying build phase.


#### Swift Package Manager

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `USController` by adding the proper description to your `Package.swift` file:

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/ytur/USController.git", from: "1.0.1"),
    ]
)
```
Then run `swift build` whenever you get prepared.

#### Manually 

To use this library in your project manually you may:  

1. for Projects, just drag Source folder to the project tree
2. for Workspaces, include the whole USController.xcodeproj

## Usage
Import USController to the controller which you want to use it as child controller.
```Swift
import USController
```
USController can be configured easily by it's builder initializer methods. You must specify the parent controller with "parentController" parameter of Builder class. Master and Detail controllers can be set with builder methods.
```Swift
let masterController = UIViewController()
let detailController = UIViewController()

let dataSource = USCDataSource.Builder(parentController: self)
                  .setMasterController(masterController, embedInNavController: true)
                  .setDetailController(detailController, embedInNavController: true)
                  .setAppearance(.visibleInit)
                  .setDirection(.trailing)
                  .showBlockerOnMaster(color: .black, opacity: 0.1, allowInteractions: true)
                  .swipeable()
                  .invokeAppearanceMethods()
                  .portraitAnimationProperties(duration: 0.35, forwardDampingRatio: 0.5)
                  .landscapeAnimationProperties(duration: 0.35, forwardDampingRatio: 0.5)
                  .portraitCustomWidth(100.0)
                  .landscapeCustomWidth(100.0)
                  .visibilityChangesListener(willStartBlock: { (targetVisibility) in
                    print("targetVisibility:\(targetVisibility)")
                  })
                  .build()                  
```

It returns current visibility state of detail controller.
```Swift
dataSource.getCurrentVisibility()
```

It changes current visibility state of detail controller between "visible" and "invisible"
```Swift
dataSource.detailToggle()
```

It removes the USController and its subviews permanently from parent controller and view.
```Swift
dataSource.disposeTheController()
```

Forces the detail controller to hide if it's displayed and keep hidden despite toggle actions.
```Swift
dataSource.forceToHide = true
```

## Author

ytur, yasinturkoglu@yahoo.com

## License

USController is available under the MIT license. See the LICENSE file for more info.
