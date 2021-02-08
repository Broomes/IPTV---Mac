//
//  Utils.swift
//  IPTV
//
//  Created by Granville Broomes on 8/8/19.
//  Copyright © 2019 CCSD. All rights reserved.
//

import Foundation
import Network

let monitor = NWPathMonitor(requiredInterfaceType: .wiredEthernet)


func getIPAddress() -> String {
    var addresses = [String]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return "" }
    guard let firstAddr = ifaddr else { return "" }
    
    // For each interface ...
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let flags = Int32(ptr.pointee.ifa_flags)
        let addr = ptr.pointee.ifa_addr.pointee
        
        // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
        if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
            if addr.sa_family == UInt8(AF_INET)  {
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                    let address = String(cString: hostname)
                    addresses.append(address)
                }
            }
        }
    }
    freeifaddrs(ifaddr)
    let result = addresses
    var temp = ""
    for ip in result{
        temp += ip
    }
    let subnet = temp.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: true)
    return String(subnet[1])
}


