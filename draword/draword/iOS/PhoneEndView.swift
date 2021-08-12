//
//  PhoneEndView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 05/08/2021.
//

import SwiftUI

struct PhoneEndView: View {
    @Binding var displayView: DisplayView
    @ObservedObject var gameState: GameState = GameState()
    
    @State var textOpacity = 0.0
    
    var body: some View {
        VStack {
            Text("Good job !")
                .font(.custom("ArialRoundedMTBold", size: 50))
                .foregroundColor(Color.drawordAccent)
                .padding()
                .padding()
            
            Spacer()
            
            Text("The winner is " + (gameState.usernames.last ?? "unknown.."))
                .fontWeight(.semibold)
                .font(.title)
                .padding()
            
            Text("Tap to go back to main menu")
                .font(.custom("ArialRoundedMTBold", size: 20))
                .foregroundColor(.drawordSecondary)
                .opacity(textOpacity)
                .contentShape(Rectangle()) // Can tap on the whole area
                .onAppear(perform: {
                    withAnimation(.easeIn(duration: 1.0).delay(1.0)) {
                        textOpacity = 1.0
                    }
                })
            
            Spacer()
        }
        .onTapGesture {
            if (textOpacity == 1.0) {
                gameState.reset()
                displayView = .main
            }
        }
    }
}

struct PhoneEndView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneEndView(displayView: .constant(.end), gameState: getGameState())
    }
    
    static func getGameState() -> GameState {
        let gs = GameState()
        
        gs.usernames = ["Alberto", "Lorenzo"]
        gs.points = [6, .max]
        
        return gs
    }
}
