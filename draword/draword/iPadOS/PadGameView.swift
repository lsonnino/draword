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
    
    @State var drawing: Int = 0
    @State var timeRemaining = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        VStack {
            PointsView(nop: $nop, drawing: $drawing, gameState: gameState, connectionManager: connectionManager)
            
            CanvasView(canvasView: $canvasView)
            
            FooterView(canvasView: $canvasView, timeRemaining: $timeRemaining)
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                    else {
                        print("Timer ended")
                    }
                }
        }
        .onAppear(perform: {
            connectionManager.messageCallback = {(message) in onReceive(message: message)}
        })
    }
    
    func onReceive(message: Message) {
        switch message.type {
        default:
            print("Unsupported message type \(message.type.rawValue)")
        }
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
        canvasView.tool = PKInkingTool(.pen, color: .gray, width: 10)
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
            
            Button {
                
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
        PadGameView(nop: .constant(users.count), gameState: getGameState(), connectionManager: getConnectionManager())
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
