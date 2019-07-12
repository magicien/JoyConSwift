//
//  ViewController.swift
//  JoyConSwiftSample
//
//  Created by magicien on 2019/07/07.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import Cocoa
import JoyConSwift

class ViewController: NSViewController {
    @IBOutlet weak var deviceSelect: NSPopUpButton!
    @IBOutlet weak var buttonTable: NSTableView!
    @IBOutlet weak var leftStickX: NSTextField!
    @IBOutlet weak var leftStickY: NSTextField!
    @IBOutlet weak var rightStickX: NSTextField!
    @IBOutlet weak var rightStickY: NSTextField!
    @IBOutlet weak var accelX: NSTextField!
    @IBOutlet weak var accelY: NSTextField!
    @IBOutlet weak var accelZ: NSTextField!
    @IBOutlet weak var disconnectButton: NSButton!
    
    var manager: JoyConManager = JoyConManager()
    var controllers: [JoyConSwift.Controller] = []
    var selectedController: JoyConSwift.Controller?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.buttonTable.delegate = self
        self.buttonTable.dataSource = self
        
        self.manager.connectHandler = { [weak self] controller in
            self?.addController(controller)
        }
        self.manager.disconnectHandler = { [weak self] controller in
            self?.removeController(controller)
        }
        
        _ = self.manager.runAsync()
    }
    
    override func viewDidDisappear() {
        self.controllers.forEach { controller in
            controller.setHCIState(state: .disconnect)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func selectController(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        guard self.controllers.count > index else { return }
        
        if index < 0 {
            self.selectedController = nil
            return
        }
        self.selectedController = self.controllers[index]
    }
    
    @IBAction func pressDisconnect(_ sender: NSButton) {
        self.selectedController?.setHCIState(state: .disconnect)
    }
    
    func addController(_ controller: JoyConSwift.Controller) {
        controller.setPlayerLights(l1: .on, l2: .off, l3: .off, l4: .off)
        controller.enableIMU(enable: true)
        controller.setInputMode(mode: .standardFull)
        if self.controllers.first(where: { controller === $0 }) == nil {
            self.controllers.append(controller)
            self.refreshDeviceSelect()
        }
        controller.buttonPressHandler = { [weak self] _ in
            if self?.selectedController === controller {
                DispatchQueue.main.async {
                    self?.buttonTable.reloadData()
                }
            }
        }
        controller.buttonReleaseHandler = { [weak self] _ in
            if self?.selectedController === controller {
                DispatchQueue.main.async {
                    self?.buttonTable.reloadData()
                }
            }
        }
        controller.leftStickPosHandler = { pos in
            DispatchQueue.main.async { [weak self] in
                self?.leftStickX.stringValue = String(format: "%.2f", pos.x)
                self?.leftStickY.stringValue = String(format: "%.2f", pos.y)
            }
        }
        controller.rightStickPosHandler = { pos in
            DispatchQueue.main.async { [weak self] in
                self?.rightStickX.stringValue = String(format: "%.2f", pos.x)
                self?.rightStickY.stringValue = String(format: "%.2f", pos.y)
            }
        }
        controller.sensorHandler = {
            DispatchQueue.main.async { [weak self] in
                self?.accelX.stringValue = String(format: "%.2f", controller.acceleration.x)
                self?.accelY.stringValue = String(format: "%.2f", controller.acceleration.y)
                self?.accelZ.stringValue = String(format: "%.2f", controller.acceleration.z)
            }
        }
    }
    
    func removeController(_ controller: JoyConSwift.Controller) {
        self.controllers.removeAll(where: { controller === $0 })
        self.refreshDeviceSelect()
    }
    
    func refreshDeviceSelect() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let selectedTitle = strongSelf.deviceSelect.selectedItem?.title
            strongSelf.deviceSelect.removeAllItems()
            strongSelf.controllers.forEach { controller in
                let title = "\(controller.type) (\(controller.serialID))"
                strongSelf.deviceSelect.addItem(withTitle: title)
            }
            
            if selectedTitle != nil {
                let selectedIndex = strongSelf.deviceSelect.indexOfItem(withTitle: selectedTitle!)
                if selectedIndex < 0 {
                    strongSelf.selectController(strongSelf.deviceSelect)
                    strongSelf.resetData()
                } else {
                    strongSelf.deviceSelect.selectItem(at: selectedIndex)
                }
            } else if strongSelf.deviceSelect.numberOfItems > 0 {
                strongSelf.deviceSelect.selectItem(at: 0)
                strongSelf.selectController(strongSelf.deviceSelect)
                strongSelf.resetData()
            } else {
                strongSelf.selectController(strongSelf.deviceSelect)
                strongSelf.resetData()
            }
            
            strongSelf.disconnectButton.isEnabled = (strongSelf.selectedController != nil)
        }
    }
    
    func resetData() {
        self.buttonTable.reloadData()
        self.leftStickX.stringValue = ""
        self.leftStickY.stringValue = ""
        self.rightStickX.stringValue = ""
        self.rightStickY.stringValue = ""
        self.accelX.stringValue = ""
        self.accelY.stringValue = ""
        self.accelZ.stringValue = ""
    }
}
