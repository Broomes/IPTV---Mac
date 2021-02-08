//
//  MainWindowController.swift
//  IPTV
//
//  Created by Granville Broomes on 6/27/19.
//  Copyright © 2019 CCSD. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    
    override var windowNibName: String? {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        NotificationCenter.default.post(name: Notification.Name("EnterFullscreen"), object: nil)
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        
    }
}
