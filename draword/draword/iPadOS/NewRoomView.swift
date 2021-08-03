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
        NewRoomView(nop: .constant(4), connectionManager: getConnectionManager())
    }
    
    static func getConnectionManager() -> ConnectionManager {
        let con = ConnectionManager()
        con.set(name: "Draword", code: code)
        return con
    }
}
