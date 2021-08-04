//
//  NewRoomView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import SwiftUI
import MultipeerConnectivity

struct NewRoomView: View {
    @Binding var nop: Int
    @ObservedObject var connectionManager: ConnectionManager
    @ObservedObject var gameState: GameState = GameState()
    @Binding var displayView: DisplayView
    
    var body: some View {
        ZStack {
            MainPadBackgroundView()
            
            VStack {
                Spacer()
                
                Text("Tell your friends:")
                    .font(.system(size: 30))
                    .foregroundColor(.drawordSecondary)
                Text(connectionManager.code)
                    .font(.custom("ArialRoundedMTBold", size: 70))
                    .foregroundColor(.drawordAccent)
                
                Spacer()
                
                Text("Connected:")
                    .font(.system(size: 30))
                    .frame(width: 300, height: 50, alignment: .leading)
                    .foregroundColor(.drawordSecondary)
                ForEach((1...nop), id: \.self) {
                    if ($0 <= connectionManager.usernames.count) {
                        UsernameView(text: "\($0). " + connectionManager.usernames[$0 - 1])
                    }
                    else {
                        UsernameView(text: "\($0). waiting ...")
                    }
                }
                
                Spacer()
            }
        }
        .onAppear(perform: {
            connectionManager.callback = check
        })
    }
    
    func check() {
        // An invite has been sent
        if (connectionManager.usernames.count == nop) {
            print("All connections have been made")
            gameState.set(connectionManager: connectionManager)
            
            connectionManager.sendGame()
            
            // Change display view
            displayView = .game
        }
        else {
            print("Only \(connectionManager.usernames.count)/\(nop)")
        }
    }
}

struct UsernameView: View {
    @State var text: String
    
    var body: some View {
        Text(text)
            .font(.custom("ArialRoundedMTBold", size: 30))
            .foregroundColor(.drawordAccent)
    }
}

struct NewRoomView_Previews: PreviewProvider {
    public static let code: String = "1234"
    
    static var previews: some View {
        NewRoomView(nop: .constant(4), connectionManager: getConnectionManager(), displayView: .constant(.newRoom))
    }
    
    static func getConnectionManager() -> ConnectionManager {
        let con = ConnectionManager()
        con.set(name: "Draword", code: code)
        return con
    }
}
