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

/// The manager class to handle controller connection/disconnection events
public class JoyConManager {
    static let vendorID: Int32 = 0x057E
    static let joyConLID: Int32 = 0x2006 // Joy-Con (L)
    static let joyConRID: Int32 = 0x2007 // Joy-Con (R)
    static let proConID: Int32 = 0x2009 // Pro Controller
    
    private let manager: IOHIDManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
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
        let productIDRef = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as! CFNumber
        var productID: Int32 = 0
        CFNumberGetValue(productIDRef, CFNumberType.longType, &productID);

        var _controller: Controller? = nil
        switch productID {
        case JoyConManager.joyConLID:
            _controller = JoyConL(device: device)
            break
        case JoyConManager.joyConRID:
            _controller = JoyConR(device: device)
            break
        case JoyConManager.proConID:
            _controller = ProController(device: device)
            break
        default:
            break
        }
        guard let controller = _controller else { return }
        self.controllers[device] = controller
        controller.isConnected = true
        controller.readInitializeData { [weak self] in
            self?.connectHandler?(controller)
        }
    }
    
    func handleInput(result: IOReturn, sender: UnsafeMutableRawPointer?, value: IOHIDValue) {
        guard let sender = sender else { return }
        let device = Unmanaged<IOHIDDevice>.fromOpaque(sender).takeUnretainedValue();
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
        let criteria = [joyConLCriteria, joyConRCriteria, proConCriteria]
        
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
