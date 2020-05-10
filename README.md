# JoyConSwift
IOKit wrapper for Nintendo Joy-Con and ProController (macOS, Swift)

## Installation

### Using [CocoaPods](http://cocoapods.org/)

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'JoyConSwift'
```

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
