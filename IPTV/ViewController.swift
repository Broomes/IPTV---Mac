//
//  ViewController.swift
//  IPTV
//
//  Created by Granville Broomes on 6/24/19.
//  Copyright © 2019 CCSD. All rights reserved.
//

import Cocoa
import SystemConfiguration
import Network

var count = 0
class ViewController: NSViewController, NSWindowDelegate {
    
    var sidebarToggle = true
    private var channelItems: [channel] = []
    let currentChannel = ""
    
    let monitor = NWPathMonitor(requiredInterfaceType: .wiredEthernet)

    let thePlayer: VLCMediaPlayer = {
        let player = VLCMediaPlayer()
        player.audio.volume = 75
        return player
    }()
    
    @IBOutlet weak var theplayerview: NSView!
    @IBOutlet weak var scrollableView: NSView!
    @IBOutlet weak var ethernetErrorView: NSImageView!
    @IBOutlet weak var controlBarView: NSView!
    @IBAction func sibebarButton(_ sender: Any) {
        closeSidebar()
    }
    
    @IBOutlet weak var sidebar: NSView!
    
    override func viewDidAppear() {
        view.window?.delegate = self
    }
    
    func windowDidResize(_ notification: Notification) {
        self.scrollableView.frame = NSRect(x:0 , y:0, width: 114, height: count + 10)
    }
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        if sidebarToggle == true{
            self.closeSidebar()
        }
    }
    
    func windowWillExitFullScreen(_ notification: Notification) {
        if sidebarToggle == false{
            self.closeSidebar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        self.scrollableView.scroll(CGPoint(x: 0, y: self.scrollableView.frame.height))
        self.checkEthernet()
    }
    
    private func fetchData()
    {
        let ipAddress = getIPAddress()
        var channels: [channel]?
        let channelParser = ChannelParser()
        channelParser.parseXML(){(listItems) in
            channels = listItems
            
            if Int(ipAddress)! > 10 {
                channels?.insert(channel(channelName: "school broadcast", channelAddress: "udp://@225.168.3." + ipAddress + ":1234/"), at: 0)
                
                self.setMedia(address: "udp://@225.168.3." + ipAddress + ":1234/")
                
                channels?.insert(channel(channelName: "school cable", channelAddress: "udp://@225.168.4." + ipAddress + ":1234/"), at: 1)
            }
            
            // DispatchQueue.main.async wrapper to avoid debugging error (it can be removed)
            DispatchQueue.main.async {
                for channel in channels?.reversed() ?? [channel(channelName: "test",channelAddress: "test")] {
                    let channelButton = NSButton(frame: NSRect(x: 0, y: 10 + count, width: 104, height: 104))
                    
                    channelButton.isBordered = false
                    channelButton.title = ""
                    
                    var name = channel.channelName
                    name = name.replacingOccurrences(of: " ", with: "%20")
                    name = "http://iptv.cobbk12.org/GB/resources/" + name + ".png"
                    name = String(name.filter{!" \n\t\r".contains($0)})

                    let url = URL(string: String(name)) ?? URL(string: "http://iptv.cobbk12.org/GB/resources/school%20cable.png")!

                    channelButton.image = NSImage(contentsOf: url)
                    channelButton.image?.size = NSSize(width: 104, height: 104)
                    
                    channelButton.alternateTitle = channel.channelAddress
                    channelButton.target = self
                    channelButton.action = #selector(ViewController.playMedia)
                    self.scrollableView.addSubview(channelButton)
                    count = count + 104
                }
            }
        }
    }
    
    @objc func playMedia(button: NSButton){
        thePlayer.stop()
        setMedia(address: button.alternateTitle)
    }
    
    func setMedia(address: String){
        if let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let udpAddress = URL(string: encoded){
            thePlayer.media = VLCMedia(url: udpAddress)
            thePlayer.drawable = theplayerview
            thePlayer.play()
        }
    }

    @IBAction func volumeSlider(_ sender: NSSlider) {
        let volume = sender.intValue
        thePlayer.audio.volume = volume
    }
    
    //Displays Ethernet Error Image over everything if false
    func checkEthernet() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.ethernetErrorView.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                    self.ethernetErrorView.isHidden = false
                }
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    // If sidebarToggle = true then close scrollableView and expand playerview / controlbar
    @objc private func closeSidebar(){
        if sidebarToggle{
            self.scrollableView.isHidden.toggle()
            self.scrollableView.scroll(CGPoint(x: 0, y: self.scrollableView.frame.height))
            self.sidebar.isHidden.toggle()
            self.theplayerview.frame = NSRect(x:0, y:24, width: view.frame.width, height: view.frame.height)
            self.controlBarView.frame = NSRect(x:0, y:0, width: view.frame.width, height: view.frame.height)
            sidebarToggle.toggle()
        }
        else{
            self.scrollableView.isHidden.toggle()
            self.scrollableView.scroll(CGPoint(x: 0, y: self.scrollableView.frame.height))
            self.sidebar.isHidden.toggle()
            self.theplayerview.frame = NSRect(x:114, y:24, width: (view.frame.width - 114), height: view.frame.height)
            self.controlBarView.frame = NSRect(x:114, y:0, width: (view.frame.width - 114), height: view.frame.height)
            sidebarToggle.toggle()
        }
    }
    
    // Double click for playerView to fullscreen
    @IBAction func doubleClickFunction(_ sender: Any) {
        view.window?.toggleFullScreen(self)
    }
}

