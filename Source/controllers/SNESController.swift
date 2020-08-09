//
//  SNESController.swift
//  JoyConSwift
//
//  Created by magicien on 2020/08/08.
//  Copyright © 2020 DarkHorse. All rights reserved.
//

import IOKit
import IOKit.hid

/// SNES Controller class
public class SNESController: Controller {
    static let buttonMap: [UInt32: JoyCon.Button] = [
        1: .B,
        2: .A,
        3: .Y,
        4: .X,
        5: .L,
        6: .R,
        7: .ZL,
        9: .Select,
        10: .Start,
        16: .ZR
    ]
    
    public override var type: JoyCon.ControllerType {
        return .SNESController
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
        } else if let button = SNESController.buttonMap[buttonNo] {
            let isPushed = (buttonState != 0)
            self.setButtonState(state: [button: isPushed])
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
        let select = button2 & 0x01 == 0x01
        let start = button2 & 0x02 == 0x02
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
            .Select: select,
            .Start: start,
            .Down: down,
            .Up: up,
            .Right: right,
            .Left: left,
            .L: l,
            .ZL: zl
        ]
        self.setButtonState(state: newState)
    }
    
    override public func readCalibration() {}
}
