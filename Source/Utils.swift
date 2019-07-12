//
//  Utils.swift
//  JoyConSwift
//
//  Created by magicien on 2019/06/16.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import Foundation

func ReadInt16(from ptr: UnsafePointer<UInt8>) -> Int16 {
    return ptr.withMemoryRebound(to: Int16.self, capacity: 1) { $0.pointee }
}

func ReadUInt16(from ptr: UnsafePointer<UInt8>) -> UInt16 {
    return ptr.withMemoryRebound(to: UInt16.self, capacity: 1) { $0.pointee }
}

func ReadInt32(from ptr: UnsafePointer<UInt8>) -> Int32 {
    return ptr.withMemoryRebound(to: Int32.self, capacity: 1) { $0.pointee }
}

func ReadUInt32(from ptr: UnsafePointer<UInt8>) -> UInt32 {
    return ptr.withMemoryRebound(to: UInt32.self, capacity: 1) { $0.pointee }
}
