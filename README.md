# JoyConSwift
IOKit wrapper for Nintendo Joy-Con and ProController (macOS, Swift)

## Installation

### Using [CocoaPods](http://cocoapods.org/)

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'JoyConSwift'
```

## Set USB Capability

To use controllers, you need to check `Signing & Capabilities` > `App SandBox` > `USB` in your Xcode project.

<img width="367" alt="usb_capability" src="https://user-images.githubusercontent.com/1047810/82137704-5f7ea980-9855-11ea-8f21-0e6c2ad518e9.png">

## Usage

```swift
import JoyConSwift

// Initialize the manager
let manager = JoyConManager()

// Set connection event callbacks
manager.connectHandler = { controller in
    // Do something with the controller
    controller.setPlayerLights(l1: .on, l2: .off, l3: .off, l4: .off)
    controller.enableIMU(enable: true)
    controller.setInputMode(mode: .standardFull)
    controller.buttonPressHandler = { button in
        if button == .A {
            // Do something with the A button
        }
    }
}
manager.disconnectHandler = { controller in
    // Clean the controller data
}

// Start waiting for the connection events
manager.runAsync()
```

## See also

[JoyKeyMapper](https://github.com/magicien/JoyKeyMapper) - Nintendo Joy-Con/ProController Key mapper for macOS
