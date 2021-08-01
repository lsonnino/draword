//
//  ContentView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import SwiftUI

struct MainPadView: View {
    @State private var nop: Int = DEFAULT_NUM_OF_PLAYERS
    
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
                    print("\(nop)")
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
    static var previews: some View {
        Group {
            MainPadView()
                .preferredColorScheme(.light)
            MainPadView()
                .preferredColorScheme(.dark)
        }
    }
}
