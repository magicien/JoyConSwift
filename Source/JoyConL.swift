//
//  JoyConL.swift
//  JoyConSwift
//
//  Created by magicien on 2019/06/16.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import IOKit
import IOKit.hid

/// Joy-Con (L) class
public class JoyConL: Controller {
    static let buttonMap: [UInt32: JoyCon.Button] = [
        1: .Left,
        2: .Down,
        3: .Up,
        4: .Right,
        5: .LeftSL,
        6: .LeftSR,
        9: .Minus,
        11: .LStick,
        14: .Capture,
        15: .L,
        16: .ZL,
    ]
    
    static let stickDirection: [UInt8: JoyCon.StickDirection] = [
        0: .Up,
        1: .UpRight,
        2: .Right,
        3: .DownRight,
        4: .Down,
        5: .DownLeft,
        6: .Left,
        7: .UpLeft,
        8: .Neutral
    ]
    
    public override var type: JoyCon.ControllerType {
        return .JoyConL
    }
    
    override func readSimpleState(value: IOHIDValue) {
        super.readSimpleState(value: value)
        
        let ptr = IOHIDValueGetBytePtr(value)
        let element = IOHIDValueGetElement(value)
        let buttonNo = IOHIDElementGetUsage(element)
        let buttonState = ptr.pointee
        
        if buttonNo == 57 {
            // Stick
            if let direction = JoyConL.stickDirection[buttonState] {
                self.setLeftStickDirection(direction: direction)
            }
        } else if let button = JoyConL.buttonMap[buttonNo] {
            let isPushed = (buttonState != 0)
            self.setButtonState(state: [button: isPushed])
        }
    }
    
    override func readStandardState(value: IOHIDValue) {
        super.readStandardState(value: value)
        
        let ptr = IOHIDValueGetBytePtr(value)
        let button1 = (ptr+3).pointee
        let button2 = (ptr+4).pointee
        
        let minus = (button1 & 0x01) == 0x01
        let capture = button1 & 0x20 == 0x20
        let stick = button1 & 0x08 == 0x08
        let down = button2 & 0x01 == 0x01
        let up = button2 & 0x02 == 0x02
        let right = button2 & 0x04 == 0x04
        let left = button2 & 0x08 == 0x08
        let sr = button2 & 0x10 == 0x10
        let sl = button2 & 0x20 == 0x20
        let l = button2 & 0x40 == 0x40
        let zl = button2 & 0x80 == 0x80
        
        let newState: [JoyCon.Button: Bool] = [
            .Minus: minus,
            .Capture: capture,
            .LStick: stick,
            .Down: down,
            .Up: up,
            .Right: right,
            .Left: left,
            .LeftSR: sr,
            .LeftSL: sl,
            .L: l,
            .ZL: zl
        ]
        self.setButtonState(state: newState)
        
        self.readLStickData(value: value)
    }
    
    override public func readCalibration() {
        self.readLStickCalibration()
        self.readSensorCalibration()
    }
}
