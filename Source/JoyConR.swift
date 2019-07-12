//
//  JoyConR.swift
//  JoyConSwift
//
//  Created by magicien on 2019/06/16.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import IOKit
import IOKit.hid

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

        let plus = button1 & 0x02 == 0x02
        let home = button1 & 0x10 == 0x10
        let stick = button1 & 0x04 == 0x04
        let y = button2 & 0x01 == 0x01
        let x = button2 & 0x02 == 0x02
        let b = button2 & 0x04 == 0x04
        let a = button2 & 0x08 == 0x08
        let sr = button2 & 0x10 == 0x10
        let sl = button2 & 0x20 == 0x20
        let r = button2 & 0x40 == 0x40
        let zr = button2 & 0x80 == 0x80
        
        self.buttonState[.Plus] = plus
        self.buttonState[.Home] = home
        self.buttonState[.RStick] = stick
        self.buttonState[.Y] = y
        self.buttonState[.X] = x
        self.buttonState[.B] = b
        self.buttonState[.A] = a
        self.buttonState[.RightSR] = sr
        self.buttonState[.RightSL] = sl
        self.buttonState[.R] = r
        self.buttonState[.ZR] = zr
        
        self.readRStickData(value: value)
    }
    
    override public func readCalibration() {
        self.readRStickCalibration()
        self.readSensorCalibration()
    }
}
