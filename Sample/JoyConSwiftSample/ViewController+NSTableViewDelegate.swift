//
//  ViewController+NSTableViewDelegate.swift
//  JoyConSwiftSample
//
//  Created by magicien on 2019/07/07.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import Cocoa
import JoyConSwift

let buttonNames: [JoyCon.Button: String] = [
    .Up: "Up",
    .Right: "Right",
    .Down: "Down",
    .Left: "Left",
    .A: "A",
    .B: "B",
    .X: "X",
    .Y: "Y",
    .L: "L",
    .ZL: "ZL",
    .R: "R",
    .ZR: "ZR",
    .Minus: "Minus",
    .Plus: "Plus",
    .Capture: "Capture",
    .Home: "Home",
    .LStick: "Left Stick",
    .RStick: "Right Stick",
    .LeftSL: "SL",
    .LeftSR: "SR",
    .RightSL: "SL",
    .RightSR: "SR"
]
let controllerButtons: [JoyCon.ControllerType: [JoyCon.Button]] = [
    .JoyConL: [.Up, .Right, .Down, .Left, .LeftSL, .LeftSR, .L, .ZL, .Minus, .Capture, .LStick],
    .JoyConR: [.A, .B, .X, .Y, .RightSL, .RightSR, .R, .ZR, .Plus, .Home, .RStick],
    .ProController: [.A, .B, .X, .Y, .L, .ZL, .R, .ZR, .Up, .Right, .Down, .Left, .Minus, .Plus, .Capture, .Home, .LStick, .RStick]
]

let buttonNameColumnID = "buttonName"
let buttonStateColumnID = "buttonState"

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let controller = selectedController else { return 0 }
        guard let buttons = controllerButtons[controller.type] else { return 0 }
        return buttons.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else { return nil }
        let newView = tableView.makeView(withIdentifier: column.identifier, owner: self)
        guard let cellView = newView as? NSTableCellView else { return nil }
        guard let controller = selectedController else { return nil }
        guard let button = controllerButtons[controller.type]?[row] else { return nil }
        
        if column.identifier.rawValue == buttonNameColumnID {
            cellView.textField?.stringValue = buttonNames[button] ?? ""
        } else if column.identifier.rawValue == buttonStateColumnID {
            if let isPushed = self.selectedController?.buttonState[button] {
                cellView.textField?.stringValue = isPushed ? "on" : "off"
            } else {
                cellView.textField?.stringValue = ""
            }
        }
        
        return cellView
    }
}
