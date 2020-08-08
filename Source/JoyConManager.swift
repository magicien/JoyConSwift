//
//  JoyConManager.swift
//  JoyConSwift
//
//  Created by magicien on 2019/06/16.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import Foundation
import IOKit
import IOKit.hid

let controllerTypeOutputReport: [UInt8] = [
    JoyCon.OutputType.subcommand.rawValue, // type
    0x0f, // packet counter
    0x00, 0x01, 0x00, 0x40, 0x00, 0x01, 0x00, 0x40, // rumble data
    Subcommand.CommandType.getSPIFlash.rawValue, // subcommand type
    0x12, 0x60, 0x00, 0x00, // address
    0x01, // data length
]

/// The manager class to handle controller connection/disconnection events
public class JoyConManager {
    static let vendorID: Int32 = 0x057E
    static let joyConLID: Int32 = 0x2006 // Joy-Con (L)
    static let joyConRID: Int32 = 0x2007 // Joy-Con (R), Famicom Controller 1&2
    static let proConID: Int32 = 0x2009 // Pro Controller
    static let snesConID: Int32 = 0x2017 // SNES Controller
    
    static let joyConLType: UInt8 = 0x01
    static let joyConRType: UInt8 = 0x02
    static let proConType: UInt8 = 0x03
    static let famicomCon1Type: UInt8 = 0x07
    static let famicomCon2Type: UInt8 = 0x08
    static let snesConType: UInt8 = 0x0B

    private let manager: IOHIDManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    private var matchingControllers: [IOHIDDevice] = []
    private var controllers: [IOHIDDevice: Controller] = [:]
    private var runLoop: RunLoop? = nil
        
    /// Handler for a controller connection event
    public var connectHandler: ((_ controller: Controller) -> Void)? = nil
    /// Handler for a controller disconnection event
    public var disconnectHandler: ((_ controller: Controller) -> Void)? = nil
    
    /// Initialize a manager
    public init() {}
    
    let handleMatchCallback: IOHIDDeviceCallback = { (context, result, sender, device) in
        let manager: JoyConManager = unsafeBitCast(context, to: JoyConManager.self)
        manager.handleMatch(result: result, sender: sender, device: device)
    }
    
    let handleInputCallback: IOHIDValueCallback = { (context, result, sender, value) in
        let manager: JoyConManager = unsafeBitCast(context, to: JoyConManager.self)
        manager.handleInput(result: result, sender: sender, value: value)
    }
    
    let handleRemoveCallback: IOHIDDeviceCallback = { (context, result, sender, device) in
        let manager: JoyConManager = unsafeBitCast(context, to: JoyConManager.self)
        manager.handleRemove(result: result, sender: sender, device: device)
    }
    
    func handleMatch(result: IOReturn, sender: UnsafeMutableRawPointer?, device: IOHIDDevice) {
        if (self.controllers.contains { (dev, ctrl) in dev == device }) {
            return
        }
        
        self.matchingControllers.append(device)
        let result = IOHIDDeviceSetReport(device, kIOHIDReportTypeOutput, CFIndex(0x01), controllerTypeOutputReport, controllerTypeOutputReport.count);
        if (result != kIOReturnSuccess) {
            print(String(format: "IOHIDDeviceSetReport error: %d", result))
            return
        }
    }
    
    func handleControllerType(device: IOHIDDevice, result: IOReturn, value: IOHIDValue) {
        guard self.matchingControllers.contains(device) else { return }
        let ptr = IOHIDValueGetBytePtr(value)
        let address = ReadUInt32(from: ptr+14)
        let length = Int((ptr+18).pointee)
        guard address == 0x6012, length == 1 else { return }
        let buffer = UnsafeBufferPointer(start: ptr+19, count: length)
        let data = Array(buffer)
        
        var _controller: Controller? = nil
        switch data[0] {
        case JoyConManager.joyConLType:
            _controller = JoyConL(device: device)
            break
        case JoyConManager.joyConRType:
            _controller = JoyConR(device: device)
            break
        case JoyConManager.proConType:
            _controller = ProController(device: device)
            break
        case JoyConManager.famicomCon1Type:
            _controller = FamicomController1(device: device)
            break
        case JoyConManager.famicomCon2Type:
            _controller = FamicomController2(device: device)
            break
        case JoyConManager.snesConType:
            _controller = SNESController(device: device)
            break
        default:
            break
        }
        
        guard let controller = _controller else { return }
        self.matchingControllers.removeAll { $0 == device }
        self.controllers[device] = controller
        controller.isConnected = true
        controller.readInitializeData { [weak self] in
            self?.connectHandler?(controller)
        }
    }
    
    func handleInput(result: IOReturn, sender: UnsafeMutableRawPointer?, value: IOHIDValue) {
        guard let sender = sender else { return }
        let device = Unmanaged<IOHIDDevice>.fromOpaque(sender).takeUnretainedValue();
        
        if self.matchingControllers.contains(device) {
            self.handleControllerType(device: device, result: result, value: value)
            return
        }
        
        guard let controller = self.controllers[device] else { return }
        if (result == kIOReturnSuccess) {
            controller.handleInput(value: value)
        } else {
            controller.handleError(result: result, value: value)
        }
    }
    
    func handleRemove(result: IOReturn, sender: UnsafeMutableRawPointer?, device: IOHIDDevice) {
        guard let controller = self.controllers[device] else { return }
        controller.isConnected = false
        
        self.controllers.removeValue(forKey: device)
        controller.cleanUp()
        
        self.disconnectHandler?(controller)
    }
    
    private func registerDeviceCallback() {
        IOHIDManagerRegisterDeviceMatchingCallback(self.manager, self.handleMatchCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        IOHIDManagerRegisterDeviceRemovalCallback(self.manager, self.handleRemoveCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        IOHIDManagerRegisterInputValueCallback(self.manager, self.handleInputCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
    }
    
    private func unregisterDeviceCallback() {
        IOHIDManagerRegisterDeviceMatchingCallback(self.manager, nil, nil)
        IOHIDManagerRegisterDeviceRemovalCallback(self.manager, nil, nil)
        IOHIDManagerRegisterInputValueCallback(self.manager, nil, nil)
    }
    
    private func cleanUp() {
        self.controllers.values.forEach { controller in
            controller.cleanUp()
        }
        self.controllers.removeAll()
    }
        
    /// Start waiting for controller connection/disconnection events in the current thread.
    /// If you don't want to stop the current thread, use `runAsync()` instead.
    /// - Returns: kIOReturnSuccess if succeeded. IOReturn error value if failed.
    public func run() -> IOReturn {
        let joyConLCriteria: [String: Any] = [
            kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey: kHIDUsage_GD_GamePad,
            kIOHIDVendorIDKey: JoyConManager.vendorID,
            kIOHIDProductIDKey: JoyConManager.joyConLID,
        ]
        let joyConRCriteria: [String: Any] = [
            kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey: kHIDUsage_GD_GamePad,
            kIOHIDVendorIDKey: JoyConManager.vendorID,
            kIOHIDProductIDKey: JoyConManager.joyConRID,
        ]
        let proConCriteria: [String: Any] = [
            kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey: kHIDUsage_GD_GamePad,
            kIOHIDVendorIDKey: JoyConManager.vendorID,
            kIOHIDProductIDKey: JoyConManager.proConID,
        ]
        let snesConCriteria: [String: Any] = [
            kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey: kHIDUsage_GD_GamePad,
            kIOHIDVendorIDKey: JoyConManager.vendorID,
            kIOHIDProductIDKey: JoyConManager.snesConID,
        ]
        let criteria = [joyConLCriteria, joyConRCriteria, proConCriteria, snesConCriteria]
        
        let runLoop = RunLoop.current
        
        IOHIDManagerSetDeviceMatchingMultiple(self.manager, criteria as CFArray)
        IOHIDManagerScheduleWithRunLoop(self.manager, runLoop.getCFRunLoop(), CFRunLoopMode.defaultMode.rawValue)
        let ret = IOHIDManagerOpen(self.manager, IOOptionBits(kIOHIDOptionsTypeSeizeDevice))
        if (ret != kIOReturnSuccess) {
            print("Failed to open HID manager")
            return ret
        }
        
        self.registerDeviceCallback()
        
        self.runLoop = runLoop
        self.runLoop?.run()
 
        IOHIDManagerClose(self.manager, IOOptionBits(kIOHIDOptionsTypeSeizeDevice))
        IOHIDManagerUnscheduleFromRunLoop(self.manager, runLoop.getCFRunLoop(), CFRunLoopMode.defaultMode.rawValue)

        return kIOReturnSuccess
    }
    
    /// Start waiting for controller connection/disconnection events in a new thread.
    /// If you want to wait for the events synchronously, use `run()` instead.
    /// - Returns: kIOReturnSuccess if succeeded. IOReturn error value if failed.
    public func runAsync() -> IOReturn {
        DispatchQueue.global().async { [weak self] in
            _ = self?.run()
        }
        return kIOReturnSuccess
    }
    
    /// Stop waiting for controller connection/disconnection events
    public func stop() {
        if let currentLoop = self.runLoop?.getCFRunLoop() {
            CFRunLoopStop(currentLoop)
        }

        self.unregisterDeviceCallback()
        self.cleanUp()
    }
}
