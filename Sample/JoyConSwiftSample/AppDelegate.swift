//
//  AppDelegate.swift
//  JoyConSwiftSample
//
//  Created by magicien on 2019/07/07.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import Cocoa
import JoyConSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
