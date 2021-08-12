//
//  ContentView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import SwiftUI

struct MainPadView: View {
    @Binding var displayView: DisplayView
    @Binding var nop: Int
    @ObservedObject var connectionManager: ConnectionManager = ConnectionManager()
    @ObservedObject var gameState: GameState = GameState()
    
    @State var nor: Int = DEFAULT_NUM_OF_ROUNDS
    
    var body: some View {
        VStack {
            Spacer()
                
            Text("DRAWORD")
                .font(.custom("ArialRoundedMTBold", size: 100))
                .foregroundColor(.drawordAccent)
                
            Text("By ALFCorp")
                .frame(width: 500, height: 30, alignment: .trailing)
                .font(.custom("ArialRoundedMTBold", size: 25))
                .foregroundColor(.drawordSecondary)
                
            Spacer()
                
            NumberSelectorView(text: "Number of players:", val: $nop, min: MIN_NUM_OF_PLAYERS, max: MAX_NUM_OF_PLAYERS)
                .padding()
            
            NumberSelectorView(text: "Number of rounds:", val: $nor, min: MIN_NUM_OF_ROUNDS, max: MAX_NUM_OF_ROUNDS)
                .padding()
                
            Button {
                numOfRounds = nor
                
                connectionManager.set(name: "Draword", code: random(digits: CODE_LENGTH))
                connectionManager.host()
                    
                displayView = .newRoom
            } label: {
                Text("Play")
                    .bold()
                    .frame(width: 400, height: 50)
                    .foregroundColor(.white)
                    .background(Color.drawordAccent)
                    .clipShape(Capsule())
                    .padding()
            }
                
            Spacer()
        }
    }
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
}

struct NumberSelectorView: View {
    public var text: String
    @Binding public var val: Int
    public var min: Int
    public var max: Int
    
    var body: some View {
        VStack {
            Text(text)
                .frame(width: 400, height: 50, alignment: .leading)
                .font(.title)
                .foregroundColor(.drawordAccent)
            HStack {
                Button {
                    val -= 1
                    if (val < min) {
                        val = min
                    }
                } label: {
                    Image(systemName: "chevron.left.circle")
                        .font(.system(size: 50.0).bold())
                        .foregroundColor(.drawordSecondary)
                }
                
                Button {
                    val += 1
                    if (val > max) {
                        val = min
                    }
                } label: {
                    Text("\(val)")
                        .bold()
                        .frame(width: 280, height: 50)
                        .foregroundColor(.white)
                        .background(Color.drawordSecondary)
                        .clipShape(Capsule())
                }
                
                Button {
                    val += 1
                    if (val > max) {
                        val = max
                    }
                } label: {
                    Image(systemName: "chevron.right.circle")
                        .font(.system(size: 50.0).bold())
                        .foregroundColor(.drawordSecondary)
                }
            }
        }
    }
}

// ==========================================

// Preview
struct ContentView_Previews: PreviewProvider {
    static let con: ConnectionManager = ConnectionManager()
    
    static var previews: some View {
        Group {
            MainPadView(displayView: .constant(DisplayView.main), nop: .constant(4), connectionManager: con)
                .preferredColorScheme(.light)
            MainPadView(displayView: .constant(DisplayView.main), nop: .constant(4), connectionManager: con)
                .preferredColorScheme(.dark)
        }
    }
}
