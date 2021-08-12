//
//  ConnectionManager.swift
//  draword
//
//  Created by Lorenzo Sonnino on 02/08/2021.
//
// Based on:
//  https://developer.apple.com/documentation/multipeerconnectivity/mcadvertiserassistant
//

import MultipeerConnectivity

let SERVICE_NAME: String = "alf-draword"
var peerID: MCPeerID?

class ConnectionManager: NSObject, ObservableObject {
    var code: String = ""
    var name: String = ""
    
    @Published var session: MCSession? = nil
    @Published var peers: [MCPeerID] = []
    @Published var usernames: [String] = []
    @Published var connectionStates: [MCSessionState] = []
    
    private var browser: MCNearbyServiceBrowser? // Only used by iPad
    private var advertiser: MCNearbyServiceAdvertiser? // Only used by iPhone
    var callback: (() -> Void)!
    var messageCallback: ((Message) -> Void)!
    
    func set(name: String, code: String) {
        self.name = name
        self.code = code
        peerID = MCPeerID(displayName: self.name)
        
        self.session = MCSession(
            peer: peerID!,
            securityIdentity: nil,
            encryptionPreference: .none
        )
        self.session?.delegate = self
    }
    
    func host() { // Called by the iPad
        browser = MCNearbyServiceBrowser(peer: peerID!, serviceType: SERVICE_NAME)
        browser!.delegate = self
        
        browser!.startBrowsingForPeers()
    }
    func join(callback: (() -> Void)!) { // Called by the iPhone
        let info = ["Code": self.code]
        advertiser = MCNearbyServiceAdvertiser(peer: peerID!, discoveryInfo: info, serviceType: SERVICE_NAME)
        advertiser!.delegate = self
        
        self.callback = callback
        
        advertiser!.startAdvertisingPeer()
    }
    
    func getNumberOfConnectedPeers() -> Int {
        self.connectionStates.filter { $0 == .connected }.count
    }
    
    //func stopConnecting() {
    //    if (browser != nil) {
    //        browser!.stopBrowsingForPeers()
    //    }
    //    if (advertiser != nil) {
    //        advertiser!.stopAdvertisingPeer()
    //    }
    //}
    
    func sendGame() {
        var message = Message()
        message.type = .game
        
        do {
            try self.session?.send(Message.encode(message: message), toPeers: self.peers, with: .reliable)
        }
        catch let error {
            print("Failed to send \(message.type.rawValue): \(error)")
        }
    }
    func submitWord(submit word: String) {
        var message = Message()
        message.type = .submit
        message.text = word
        
        do {
            try self.session?.send(Message.encode(message: message), toPeers: self.peers, with: .reliable)
        }
        catch {
            print("Failed to send \(message.type.rawValue): \(error)")
        }
    }
    func sendAttempt(attempt: String) {
        var message = Message()
        message.type = .attempt
        message.text = attempt
        
        do {
            try self.session?.send(Message.encode(message: message), toPeers: self.peers, with: .reliable)
        }
        catch {
            print("Failed to send \(message.type.rawValue): \(error)")
        }
    }
    func boradcastAttempt(boradcast attempt: String, from user: MCPeerID) {
        var message = Message()
        message.type = .broadcastAttempt
        message.text = attempt
        message.user = user.displayName
        
        for index in (0 ... self.peers.count-1) {
            if (self.peers[index] != user) {
                do {
                    try self.session?.send(Message.encode(message: message), toPeers: [self.peers[index]], with: .reliable)
                }
                catch {
                    print("Failed to send \(message.type.rawValue): \(error)")
                }
            }
        }
    }
    func sendPoint(to winner: Int) {
        var message = Message()
        message.type = .point
        message.text = self.usernames[winner]
        
        for index in (0 ... self.usernames.count-1) {
            if (index == winner) {
                message.val = 1
            }
            else {
                message.val = 0
            }
            
            do {
                try self.session?.send(Message.encode(message: message), toPeers: [self.peers[index]], with: .reliable)
            }
            catch {
                print("Failed to send \(message.type.rawValue): \(error)")
            }
        }
    }
    func sendDraw(to index: Int) {
        var message = Message()
        message.type = .draw
        
        do {
            try self.session?.send(Message.encode(message: message), toPeers: [self.peers[index]], with: .reliable)
        }
        catch {
            print("Failed to send \(message.type.rawValue): \(error)")
        }
    }
    func sendEndGame(gameState: GameState) {
        var message = Message()
        message.type = .endGame
        message.text = self.usernames[gameState.getWinner()[0]]
        
        for index in (0 ... self.usernames.count-1) {
            message.val = UInt8(gameState.points[index])
            
            do {
                try self.session?.send(Message.encode(message: message), toPeers: self.peers, with: .reliable)
            }
            catch {
                print("Failed to send \(message.type.rawValue): \(error)")
            }
        }
    }
    
    func disconnect() {
        self.session!.disconnect()
    }
}

extension ConnectionManager: MCNearbyServiceBrowserDelegate {
    // Called when a peer is found
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Check if the peer is not already connected
        if (self.peers.contains(peerID)) { return }
        
        // Check the code
        guard let infoCheck = info else { return }
        guard let infoCode = infoCheck["Code"] else { return }
        if (infoCode != self.code) {
            print("Refused code \(infoCode)")
            return
        }
        
        // Connect the peer
        browser.invitePeer(peerID, to: self.session!, withContext: nil, timeout: 0)
        // note: timeout: 0 uses the default timeout (30 seconds)
        // Add him to the list
        DispatchQueue.main.async {
            self.peers.append(peerID)
            self.usernames.append(peerID.displayName)
        }
        
        // Callback
        self.callback()
    }
    
    // Called when a peer is lost
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // Check if the peer was connected
        if (self.peers.contains(peerID)) {
            // Remove him
            DispatchQueue.main.async {
                var index = self.peers.firstIndex(of: peerID)
                if (index != nil) {
                    self.peers.remove(at: index!)
                    self.connectionStates.remove(at: index!)
                }
                index = self.usernames.firstIndex(of: peerID.displayName)
                if (index != nil) {
                    self.usernames.remove(at: index!)
                }
            }
        }
    }
}

extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    // Called when an invitation to join is received
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Accept the invitation
        invitationHandler(true, self.session)
        
        self.peers.append(peerID)
        
        self.callback()
    }
}

extension ConnectionManager: MCSessionDelegate {
    // Called when the connection state changes with a peer
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard let index = self.peers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            if (index >= 0 && index < self.connectionStates.count) {
                self.connectionStates[index] = state
            }
            else {
                self.connectionStates.append(state)
            }
        }
        
        switch state {
        case .connected:
            print("Connection for peer \(peerID.displayName) passed to state: connected")
        case .connecting:
            print("Connection for peer \(peerID.displayName) passed to state: connecting")
        case .notConnected:
            print("Connection for peer \(peerID.displayName) passed to state: not connected")
        default:
            print("Connection for peer \(peerID.displayName) passed to state: unknown")
        }
        
        DispatchQueue.main.async {
            self.callback()
        }
    }
    
    // Called when data is received
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        var message = Message.decode(from: data)
        
        // If it is an attempt
        if (message.type == .attempt) {
            // Broadcast it
            self.boradcastAttempt(boradcast: message.text, from: peerID)
            
            // Set who sent it for the iPad
            message.userIndex = self.peers.firstIndex(of: peerID) ?? -1
        }
        
        DispatchQueue.main.async {
            self.messageCallback(message)
        }
    }
    
    // Called when a stream is received
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // do nothing
    }
    
    // Called when a resource is beeing received
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // do nothing
    }
    // Called when a resource finished receiving
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // do nothing
    }
}
