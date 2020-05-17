//
//  JoyConR.swift
//  JoyConSwift
//
//  Created by magicien on 2019/06/16.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import IOKit
import IOKit.hid

/// Pro Controller class
public class ProController: Controller {
    static let buttonMap: [UInt32: JoyCon.Button] = [
        1: .B,
        2: .A,
        3: .Y,
        4: .X,
        5: .L,
        6: .R,
        7: .ZL,
        8: .ZR,
        9: .Minus,
        10: .Plus,
        11: .LStick,
        12: .RStick,
        13: .Home,
        14: .Capture,
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
        return .ProController
    }

    override func readSimpleState(value: IOHIDValue) {
        super.readSimpleState(value: value)
        
        let ptr = IOHIDValueGetBytePtr(value)
        let element = IOHIDValueGetElement(value)
        let buttonNo = IOHIDElementGetUsage(element)
        let buttonState = ptr.pointee

        if buttonNo == 57 {
            // D-Pad
            let up = (buttonState == 7 || buttonState == 0 || buttonState == 1)
            let right = (buttonState == 1 || buttonState == 2 || buttonState == 3)
            let down = (buttonState == 3 || buttonState == 4 || buttonState == 5)
            let left = (buttonState == 5 || buttonState == 6 || buttonState == 7)
            
            self.setButtonState(state: [
                .Up: up,
                .Right: right,
                .Down: down,
                .Left: left
            ])
        } else if let button = ProController.buttonMap[buttonNo] {
            let isPushed = (buttonState != 0)
            self.setButtonState(state: [button: isPushed])
        } else {
            // buttonNo: 48-52 ???
        }
    }
    
    override func readStandardState(value: IOHIDValue) {
        super.readStandardState(value: value)

        let ptr = IOHIDValueGetBytePtr(value)
        let button1 = (ptr+2).pointee
        let button2 = (ptr+3).pointee
        let button3 = (ptr+4).pointee

        let y = button1 & 0x01 == 0x01
        let x = button1 & 0x02 == 0x02
        let b = button1 & 0x04 == 0x04
        let a = button1 & 0x08 == 0x08
        let r = button1 & 0x40 == 0x40
        let zr = button1 & 0x80 == 0x80
        let minus = button2 & 0x01 == 0x01
        let plus = button2 & 0x02 == 0x02
        let rStick = button2 & 0x04 == 0x04
        let lStick = button2 & 0x08 == 0x08
        let home = button2 & 0x10 == 0x10
        let capture = button2 & 0x20 == 0x20
        let down = button3 & 0x01 == 0x01
        let up = button3 & 0x02 == 0x02
        let right = button3 & 0x04 == 0x04
        let left = button3 & 0x08 == 0x08
        let l = button3 & 0x40 == 0x40
        let zl = button3 & 0x80 == 0x80
        
        let newState: [JoyCon.Button: Bool] = [
            .Y: y,
            .X: x,
            .B: b,
            .A: a,
            .R: r,
            .ZR: zr,
            .Minus: minus,
            .Plus: plus,
            .LStick: lStick,
            .RStick: rStick,
            .Home: home,
            .Capture: capture,
            .Down: down,
            .Up: up,
            .Right: right,
            .Left: left,
            .L: l,
            .ZL: zl
        ]
        self.setButtonState(state: newState)
        
        self.readLStickData(value: value)
        self.readRStickData(value: value)
    }
    
    override public func readCalibration() {
        self.readLStickCalibration()
        self.readRStickCalibration()
        self.readSensorCalibration()
    }
}
