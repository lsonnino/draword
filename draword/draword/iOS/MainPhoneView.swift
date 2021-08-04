//
//  MainPhoneView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import SwiftUI
import Combine

struct MainPhoneView: View {
    @Binding var displayView: DisplayView
    @ObservedObject var connectionManager: ConnectionManager = ConnectionManager()
    @State var username: String = ""
    @State var code: String = ""
    
    var body: some View {
        VStack {
            Spacer()
                
            Text("DRAWORD")
                .font(.custom("ArialRoundedMTBold", size: 40))
                .foregroundColor(.drawordAccent)
                
            Text("By ALFCorp")
                .frame(width: 200, height: 30, alignment: .trailing)
                .font(.custom("ArialRoundedMTBold", size: 15))
                .foregroundColor(.drawordSecondary)
                
            Spacer()
                
            switch displayView {
            case .phoneWaitParticipants:
                WaitingSubView()
            default:
                ConnectSubView(displayView: $displayView, username: $username, code: $code, connectionManager: connectionManager)
            }
                
            Spacer()
        }
    }
}

struct ConnectSubView: View {
    @Binding var displayView: DisplayView
    @Binding var username: String
    @Binding var code: String
    @ObservedObject var connectionManager: ConnectionManager
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200, height: 50, alignment: .center)
            TextField("Room", text: $code)
                .keyboardType(.numberPad)
                .onReceive(Just(code)) { _ in limitCodeLength() }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200, height: 50, alignment: .center)
            
            Button {
                if (!username.isEmpty && code.count == CODE_LENGTH) {
                    print("Play pressed")
                    
                    connectionManager.set(name: username, code: code)
                    connectionManager.join(callback: {
                        // An invite has been received and accepted
                        connectionManager.stopConnecting()
                        
                        // TODO: Set display view
                        displayView = .phoneWaitParticipants
                        
                        connectionManager.messageCallback = onGameStart
                    })
                }
            } label: {
                Text("Play")
                    .bold()
                    .frame(width: 200, height: 50)
                    .foregroundColor(.white)
                    .background(Color.drawordAccent)
                    .clipShape(Capsule())
                    .padding()
            }
        }
    }
    
    func limitCodeLength() {
        if code.count > CODE_LENGTH {
            code = String(code.prefix(CODE_LENGTH))
        }
    }
    
    func onGameStart(message: Message) {
        displayView = .game
    }
}

struct WaitingSubView: View {
    var body: some View {
        VStack {
            Text("Waiting for other participants to join...")
                .font(.custom("ArialRoundedMTBold", size: 30))
                .foregroundColor(.drawordAccent)
            Text("Grab a coffee or press your friends, the game will start soon !")
                .font(.custom("ArialRoundedMTBold", size: 25).monospacedDigit())
                .foregroundColor(.drawordSecondary)
                .frame(height: 150)
        }
        .padding()
    }
}

struct MainPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        MainPhoneView(displayView: .constant(.main))
    }
}
