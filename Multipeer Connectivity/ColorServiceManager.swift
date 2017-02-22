//
//  ColorServiceManager.swift
//  Multipeer Connectivity
//
//  Created by Slbd on 2/16/17.
//  Copyright © 2017 Slbd. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ColorServiceManagerDelegate {
    
    func connectedDevicesChanged(manager : ColorServiceManager, connectedDevices: [String])
    func colorChanged(manager : ColorServiceManager, colorString: String)
    
}

class ColorServiceManager: NSObject {
    private let ColorServiceType = "bbal-color"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    
    private let serviceBrowser: MCNearbyServiceBrowser
    var delegate : ColorServiceManagerDelegate?
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .Required)
        session.delegate = self
        return session
    }()
    
    
    
    
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ColorServiceType)
        super.init()
 
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func send(colorName : String) {
        NSLog("%@", "sendColor: \(colorName) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                //try self.session.send(colorName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
                try self.session.sendData(colorName.dataUsingEncoding(NSUTF8StringEncoding)!, toPeers: session.connectedPeers, withMode: .Reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }

    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
}

extension ColorServiceManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}

extension ColorServiceManager: MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "foundPeer: \(peerID)")
    }
}

extension ColorServiceManager : MCSessionDelegate {
 
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        self.delegate?.connectedDevicesChanged(self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str  = String(data: data, encoding: NSUTF8StringEncoding)
        self.delegate?.colorChanged(self, colorString: str!)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
         NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")

    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
}


