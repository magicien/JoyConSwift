//
//  SubCommand.swift
//  JoyConSwift
//
//  Created by magicien on 2019/06/28.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import Foundation

/// Bluetooth HID subcommands
class Subcommand {
    enum CommandType: UInt8 {
        case getControllerState = 0x00
        case manualPairing = 0x01
        case getDeviceInfo = 0x02
        case setInputMode = 0x03
        case getTriggerTime = 0x04
        case getPageListState = 0x05
        case setHCIState = 0x06
        case resetParingInfo = 0x07
        case setLowPowerState = 0x08
        case getSPIFlash = 0x10
        case setSPIFlash = 0x11
        case eraseSPISector = 0x12
        case resetNFCIR = 0x20
        case setNFCIRConfig = 0x21
        case setNFCIRState = 0x22
        case setPlayerLights = 0x30
        case getPlayerLights = 0x31
        case setHomeLight = 0x38
        case enableIMU = 0x40
        case setIMUSensitivity = 0x41
        case setIMURegisters = 0x42
        case getIMURegisters = 0x43
        case enableVibration = 0x48
        case getRegulatedVoltage = 0x50
        case setGPIOValue = 0x51
        case getGPIOValue = 0x52
    }
    
    let type: CommandType
    let data: [UInt8]
    var responseHandler: ((_ value: IOHIDValue?) -> Void)?
    var timer: Timer?
    
    init(type: CommandType, data: [UInt8], responseHandler: ((_ value: IOHIDValue?) -> Void)?) {
        self.type = type
        self.data = data
        self.responseHandler = responseHandler
    }
}
