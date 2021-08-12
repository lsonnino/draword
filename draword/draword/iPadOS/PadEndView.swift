//
//  PadEndView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 05/08/2021.
//

import SwiftUI

struct PadEndView: View {
    @Binding var nop: Int
    @Binding var nor: Int
    @Binding var displayView: DisplayView
    @ObservedObject var connectionManager: ConnectionManager = ConnectionManager()
    @ObservedObject var gameState: GameState = GameState()
    
    @State var textOpacity = 0.0
    
    var body: some View {
        VStack {
            Divider()
                .padding()
            Text("CONGRATULATIONS !")
                .font(.custom("ArialRoundedMTBold", size: 70))
                .foregroundColor(.drawordAccent)
            Divider()
                .padding()
            
            Spacer()
            
            Text("Tap to go back to main menu")
                .font(.custom("ArialRoundedMTBold", size: 30))
                .foregroundColor(.drawordSecondary)
                .opacity(textOpacity)
                .onAppear(perform: {
                    withAnimation(.easeIn(duration: 1.0).delay(1.0)) {
                        textOpacity = 1.0
                    }
                })
                .frame(height: 150, alignment: .bottom)
            
            HStack (spacing: 20) {
                ForEach (0 ..< gameState.usernames.count, id: \.self) { index in
                    BarView(text: gameState.usernames[index], value: gameState.points[index], winner: gameState.getWinner().contains(index), scaleFactor: getBarScaleFactor())
                }
            }
            .padding()
            
            Divider()
                .padding()
        }
        .padding()
        .contentShape(Rectangle()) // Can tap on the whole area
        .onTapGesture {
            if (textOpacity == 1.0) {
                connectionManager.reset()
                gameState.reset()
                displayView = .main
            }
        }
    }
    
    func getBarScaleFactor() -> CGFloat {
        let max = nop * nor + nor
        return CGFloat(max) / CGFloat(gameState.points.max() ?? max)
    }
}

struct BarView: View {
    @State var text: String
    @State var value: Int = 5
    @State var winner: Bool = false
    @State var scaleFactor: CGFloat
    
    @State var initial: Bool = true
    @State var finished: Bool = false
    @State var shownValue: Int = 0
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 30.0)
                        .foregroundColor(finished && winner ? .drawordAccent : .drawordSecondary)
                        .frame(width: 100)
                        .frame(height: initial ? 5 : CGFloat(value) * 40 * scaleFactor, alignment: .bottom)
                        .animation(.linear(duration: Double(value) / 10))
                }
                
                VStack {
                    Spacer()
                    
                    Text("\(shownValue)")
                        .font(.custom("ArialRoundedMTBold", size: 30))
                        .foregroundColor(.white)
                        .padding()
                }
            }
            
            
            Text(text)
                .font(.custom("ArialRoundedMTBold", size: 30))
                .foregroundColor(finished && winner ? .drawordAccent : .drawordSecondary)
        }
        .onAppear(perform: {
            if (initial) {
                animate()
            }
            initial = false
        })
    }
    
    // From:
    // https://unwrappedbytes.com/2020/10/18/learn-how-to-create-a-swiftui-rolling-number-animation-that-will-amaze-your-users/
    func animate() {
        withAnimation {
            // Decide on the number of animation steps
            let animationDuration = value * 100 // milliseconds
            let steps = value
            let stepDuration = (animationDuration / steps)
            
            // add the remainder of our entered num from the steps
            shownValue = 0
            // For each step
            (0..<steps).forEach { step in
                // create the period of time when we want to update the number
                let updateTimeInterval = DispatchTimeInterval.milliseconds(step * stepDuration)
                let deadline = DispatchTime.now() + updateTimeInterval
                
                // tell dispatch queue to run task after the deadline
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    // Add piece of the entire entered number to our total
                    shownValue += 1
                }
            }
            
            finished = true
        }
    }
}

struct PadEndView_Previews: PreviewProvider {
    static let users: [String] = ["Lorenzo", "Alberto", "Laura", "Ysaline"]
    
    static var previews: some View {
        PadEndView(nop: .constant(users.count), nor: .constant(3), displayView: .constant(.end), gameState: getGameState())
    }
    
    static func getGameState() -> GameState {
        let gs = GameState()
        
        gs.usernames = users
        gs.points = [6, 8, 6, 4]
        
        return gs
    }
}
