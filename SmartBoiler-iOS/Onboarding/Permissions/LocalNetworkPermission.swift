//
//  LocalNetworkPermission.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 3/12/25.
//

import Foundation
import Network

/// This class is used to request permission to access the local network.
class LocalNetworkPermission: NSObject, NetServiceDelegate {
    private var browser: NWBrowser?
    private var netService: NetService?
    private var completion: ((Bool) -> Void)?
    
    // iOS doesn't ask for permission to access the local network until the app tries to access it.
    // So we simulate a connection to the local network to prompt the user to give permission.
    func requestPermission(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        
        let nwParameters = NWParameters()
        nwParameters.includePeerToPeer = true
        
        browser = NWBrowser(for: .bonjour(type: "_bonjour._tcp", domain: nil), using: nwParameters)
        browser?.stateUpdateHandler = { state in
            switch state {
            case .failed(let error):
                print("Browser failed with error: \(error)")
            case .ready, .cancelled:
                break
            case .waiting(let error):
                print("Local network permission has been denied: \(error)")
                self.reset()
                completion(false)
            default:
                break
            }
        }
        
        netService = NetService(domain: "local.", type:"_lnp._tcp.", name: "KiLLLocalNetwork", port: 1100)
        netService?.delegate = self
        
        browser?.start(queue: .main)
        netService?.publish()
    }
    
    /// Reset the browser and netService.
    func reset() {
        browser?.cancel()
        browser = nil
        netService?.stop()
        netService = nil
    }
    
    /// NetService did publish. This means that the user has granted permission to access the local network.
    func netServiceDidPublish(_ sender: NetService) {
        print("Local network permission has been granted.")
        reset()
        completion?(true)
    }
}
