//
//  JoyConR.swift
//  JoyConSwift
//
//  Created by magicien on 2019/06/16.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import IOKit
import IOKit.hid

/// Joy-Con (R) class
public class JoyConR: Controller {
    static let buttonMap: [UInt32: JoyCon.Button] = [
        1: .A,
        2: .X,
        3: .B,
        4: .Y,
        5: .RightSL,
        6: .RightSR,
        10: .Plus,
        12: .RStick,
        13: .Home,
        15: .R,
        16: .ZR
    ]
    
    static let stickDirection: [UInt8: JoyCon.StickDirection] = [
        0: .Left,
        1: .UpLeft,
        2: .Up,
        3: .UpRight,
        4: .Right,
        5: .DownRight,
        6: .Down,
        7: .DownLeft,
        8: .Neutral
    ]
    
    public override var type: JoyCon.ControllerType {
        return .JoyConR
    }
    
    override func readSimpleState(value: IOHIDValue) {
        super.readSimpleState(value: value)
        
        let ptr = IOHIDValueGetBytePtr(value)
        let element = IOHIDValueGetElement(value)
        let buttonNo = IOHIDElementGetUsage(element)
        let buttonState = ptr.pointee
        
        if buttonNo == 57 {
            // Stick
            if let direction = JoyConR.stickDirection[buttonState] {
                self.setRightStickDirection(direction: direction)
            }
        } else if let button = JoyConR.buttonMap[buttonNo] {
            let isPushed = (buttonState != 0)
            self.setButtonState(state: [button: isPushed])
        }
    }
    
    override func readStandardState(value: IOHIDValue) {
        super.readStandardState(value: value)

        let ptr = IOHIDValueGetBytePtr(value)
        let button1 = (ptr+2).pointee
        let button2 = (ptr+3).pointee

        let y = button1 & 0x01 == 0x01
        let x = button1 & 0x02 == 0x02
        let b = button1 & 0x04 == 0x04
        let a = button1 & 0x08 == 0x08
        let sr = button1 & 0x10 == 0x10
        let sl = button1 & 0x20 == 0x20
        let r = button1 & 0x40 == 0x40
        let zr = button1 & 0x80 == 0x80
        let plus = button2 & 0x02 == 0x02
        let stick = button2 & 0x04 == 0x04
        let home = button2 & 0x10 == 0x10

        let newState: [JoyCon.Button: Bool] = [
            .Y: y,
            .X: x,
            .B: b,
            .A: a,
            .RightSR: sr,
            .RightSL: sl,
            .R: r,
            .ZR: zr,
            .Plus: plus,
            .Home: home,
            .RStick: stick
        ]
        self.setButtonState(state: newState)
        
        self.readRStickData(value: value)
    }
    
    override public func readCalibration() {
        self.readRStickCalibration()
        self.readSensorCalibration()
    }
}
