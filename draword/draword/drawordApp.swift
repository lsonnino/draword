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
    @StateObject var gameState: GameState = GameState()
    
    var body: some Scene {
        WindowGroup {
            
            
            // === IPAD PART ========================
            
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                ZStack {
                    MainPadBackgroundView()
                    
                    switch displayView {
                    case .game:
                        PadGameView(gameState: gameState)
                    case DisplayView.newRoom:
                        NewRoomView(nop: $nop, connectionManager: connectionManager)
                    default: // main
                        MainPadView(displayView: $displayView, nop: $nop, connectionManager: connectionManager, gameState: gameState)
                    }
                }
            }
            
            
            // === IPHONE PART ========================
            
            else {
                ZStack {
                    MainPhoneBackgroundView()
                    
                    switch displayView {
                    case .game, .guess:
                        PhoneGameView(gameState: gameState, displayView: $displayView, connectionManager: connectionManager)
                    default: // main or phoneWaitParticipants
                        MainPhoneView(displayView: $displayView, connectionManager: connectionManager)
                    }
                }
            }
            
            // ========================================
        }
    }
}

struct MainPadBackgroundView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                QuarterCircle(radius: 400,
                              from: 180,
                              to: 270)
                    .fill(Color(UIColor.systemFill))
                    .frame(width: 1, height: 1)
            }
            
            Spacer()
            
            HStack {
                QuarterCircle(radius: 500,
                              from: 0,
                              to: 270)
                    .fill(Color(.secondaryLabel))
                    .frame(width: 1, height: 1)
                
                Spacer()
                
                QuarterCircle(radius: 300,
                              from: 270,
                              to: 180)
                    .fill(Color(.label))
                    .frame(width: 1, height: 1)
            }
        }
        .ignoresSafeArea()
    }
}

struct MainPhoneBackgroundView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                QuarterCircle(radius: 200,
                              from: 180,
                              to: 270)
                    .fill(Color(UIColor.systemFill))
                    .frame(width: 1, height: 1)
            }
            
            Spacer()
            
            HStack {
                QuarterCircle(radius: 250,
                              from: 0,
                              to: 270)
                    .fill(Color(.secondaryLabel))
                    .frame(width: 1, height: 1)
                
                Spacer()
                
                QuarterCircle(radius: 150,
                              from: 270,
                              to: 180)
                    .fill(Color(.label))
                    .frame(width: 1, height: 1)
            }
        }
        .ignoresSafeArea()
    }
}
