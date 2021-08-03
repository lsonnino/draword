//
//  drawordApp.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import SwiftUI

@main
struct drawordApp: App {
    @State var displayView: DisplayView = DisplayView.main
    @State var nop: Int = DEFAULT_NUM_OF_PLAYERS
    @StateObject var connectionManager: ConnectionManager = ConnectionManager()
    
    var body: some Scene {
        WindowGroup {
            
            
            // === IPAD PART ========================
            
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                switch displayView {
                case DisplayView.newRoom:
                    NewRoomView(nop: $nop, connectionManager: connectionManager)
                default: // main
                    MainPadView(displayView: $displayView, nop: $nop, connectionManager: connectionManager)
                }
            }
            
            
            // === IPHONE PART ========================
            
            else {
                switch displayView {
                default: // main or phoneWaitParticipants
                    MainPhoneView(displayView: $displayView, connectionManager: connectionManager)
                }
            }
            
            // ========================================
        }
    }
}
