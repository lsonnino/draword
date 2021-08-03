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
    
    var body: some View {
        ZStack {
            MainPadBackgroundView()
            
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
                
                PlayerNumberSelectorView(nop: $nop)
                    .padding()
                
                Button {
                    connectionManager.set(name: "Draword", code: random(digits: CODE_LENGTH))
                    connectionManager.host(callback: {
                        // An invite has been sent
                        if (connectionManager.usernames.count == nop) {
                            print("All connections have been made")
                            
                            // Change display view
                        }
                    })
                    
                    displayView = DisplayView.newRoom
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
    }
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
}

struct PlayerNumberSelectorView: View {
    @Binding public var nop: Int
    
    var body: some View {
        VStack {
            Text("Number of players:")
                .frame(width: 400, height: 50, alignment: .leading)
                .font(.title)
                .foregroundColor(.drawordAccent)
            HStack {
                Button {
                    nop -= 1
                    if (nop < MIN_NUM_OF_PLAYERS) {
                        nop = MIN_NUM_OF_PLAYERS
                    }
                } label: {
                    Image(systemName: "chevron.left.circle")
                        .font(.system(size: 50.0).bold())
                        .foregroundColor(.drawordSecondary)
                }
                
                Button {
                    nop += 1
                    if (nop > MAX_NUM_OF_PLAYERS) {
                        nop = MIN_NUM_OF_PLAYERS
                    }
                } label: {
                    Text("\(nop)")
                        .bold()
                        .frame(width: 280, height: 50)
                        .foregroundColor(.white)
                        .background(Color.drawordSecondary)
                        .clipShape(Capsule())
                }
                
                Button {
                    nop += 1
                    if (nop > MAX_NUM_OF_PLAYERS) {
                        nop = MAX_NUM_OF_PLAYERS
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
