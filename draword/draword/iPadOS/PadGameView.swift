//
//  PadGameView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 03/08/2021.
//

import SwiftUI
import PencilKit
import MultipeerConnectivity

struct PadGameView: View {
    @Binding var nop: Int
    @ObservedObject var gameState: GameState = GameState()
    @ObservedObject var connectionManager: ConnectionManager = ConnectionManager()
    @Binding var displayView: DisplayView
    
    @State var drawing: Int = 0
    @State var word: String = ""
    @State var submitted: Bool = false
    @State var timeRemaining = TIMER_LENGTH
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var round: Int = 1
    
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        VStack (spacing: 0) {
                PointsView(nop: $nop, drawing: $drawing, gameState: gameState, connectionManager: connectionManager)
                
                ZStack {
                    VStack {
                        CanvasView(canvasView: $canvasView)
                        
                        FooterView(canvasView: $canvasView, timeRemaining: $timeRemaining)
                            .onReceive(timer) { _ in
                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                }
                                else {
                                    nextPlayer()
                                }
                            }
                    }
                    
                    if (!submitted) {
                        Text("Waiting for \(connectionManager.usernames[drawing]) to choose a word")
                            .font(.custom("ArialRoundedMTBold", size: 80))
                            .bold()
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.white)
                            .background(Color.drawordAccent)
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear(perform: {
                connectionManager.callback = { return }
                connectionManager.messageCallback = {(message) in onReceive(message: message)}
            })
    }
    
    func onReceive(message: Message) {
        switch message.type {
        case .submit:
            submitted = true
            word = message.text
        case .attempt:
            // note: the broadcast is automatic
            if (word == message.text && message.userIndex >= 0) { // The user guessed
                // Notify that someone guessed
                connectionManager.sendPoint(to: message.userIndex)
                gameState.points[message.userIndex] += 1
                gameState.points[drawing] += 1
                
                // Next player
                nextPlayer()
            }
        default:
            print("Unsupported message type \(message.type.rawValue)")
        }
    }
    
    func nextPlayer() {
        // Reset the timer
        timeRemaining = TIMER_LENGTH
        
        // Pass to the next player
        drawing += 1
        if (drawing >= nop) {
            drawing = drawing % nop
            round += 1
            
            if (round > numOfRounds) {
                // Game ended
                connectionManager.sendEndGame(gameState: gameState)
                displayView = .end
                connectionManager.disconnect()
                return
            }
        }
        
        // Notify the other players
        connectionManager.sendGame()
        connectionManager.sendDraw(to: drawing)
        canvasView.drawing = PKDrawing()
    }
}

struct PointsView: View {
    @Binding var nop: Int
    @Binding var drawing: Int
    @ObservedObject var gameState: GameState
    @ObservedObject var connectionManager: ConnectionManager
    
    var body: some View {
        HStack (spacing: 0) {
            ForEach((0..<nop), id: \.self) { ind in
                HStack {
                    Text(connectionManager.usernames[ind] + ": ")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("\(gameState.points[ind])")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(getColor(isDrawing: drawing == ind, state: connectionManager.connectionStates[ind]))
            }
        }
    }
    
    func getColor(isDrawing drawing: Bool, state: MCSessionState) -> Color {
        if (state == .notConnected) {
            return Color(.secondaryLabel)
        }
        else if (drawing) {
            return Color.drawordAccent
        }
        else {
            return Color.drawordSecondary
        }
    }
}

struct CanvasView {
  @Binding var canvasView: PKCanvasView
}
extension CanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        let toolPicker = PKToolPicker.init()
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
        #endif
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

struct FooterView: View {
    @Binding var canvasView: PKCanvasView
    @Binding var timeRemaining: Int
    
    var body: some View {
        HStack {
            HStack {
                Spacer()
                
                Text("Remaining time: ")
                    .font(.custom("ArialRoundedMTBold", size: 30))
                    .bold()
                    .foregroundColor(.white)
                Text("\(timeRemaining)")
                    .font(.custom("ArialRoundedMTBold", size: 30))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color.drawordAccent)
            .cornerRadius(30, corners: [.topRight, .bottomRight])
            
            Button {
                canvasView.drawing = PKDrawing()
            } label: {
                Image(systemName: "trash.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: .infinity)
                    .foregroundColor(.drawordSecondary)
                    .padding()
            }
            .frame(width: 200, height: 100)
        }
    }
}

struct PadGameView_Previews: PreviewProvider {
    static let users: [String] = ["Lorenzo", "Alberto", "Laura", "Ysaline"]
    
    static var previews: some View {
        PadGameView(nop: .constant(users.count), gameState: getGameState(), connectionManager: getConnectionManager(), displayView: .constant(.game), submitted: true)
    }
    
    static func getGameState() -> GameState {
        let gs = GameState()
        
        gs.usernames = users
        gs.points = [4, 2, 3, 1]
        
        return gs
    }
    static func getConnectionManager() -> ConnectionManager {
        let con = ConnectionManager()
        
        // Setup the only variables needed to display a graphical interface
        con.usernames = users
        con.connectionStates = [.connected, .connected, .notConnected, .connecting]
        
        return con
    }
}
