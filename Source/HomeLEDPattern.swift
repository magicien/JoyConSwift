//
//  HomeLEDPattern.swift
//  JoyConSwift
//
//  Created by magicien on 2020/06/30.
//

import Foundation

/// Home LED pattern data for setHomeLight function
public struct HomeLEDPattern {
    /// LED intensity
    var intensity: UInt8
    
    /// Fading transition duration to this cycle
    var fadeDuration: UInt8
    
    /// LED duration of this cycle
    var duration: UInt8

    public init(intensity: UInt8, fadeDuration: UInt8, duration: UInt8) {
        self.intensity = intensity
        self.fadeDuration = fadeDuration
        self.duration = duration
    }
}
