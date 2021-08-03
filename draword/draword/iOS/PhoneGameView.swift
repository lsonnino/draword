//
//  PhoneGameView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 03/08/2021.
//

import SwiftUI

struct PhoneGameView: View {
    @ObservedObject var gameState: GameState = GameState()
    @Binding var displayView: DisplayView
    @ObservedObject var connectionManager: ConnectionManager = ConnectionManager()
    @State var points: Int = 0
    
    var body: some View {
        VStack {
            PointsBannerView(points: $points)
            
            Spacer()
        }
    }
}

struct PhoneGameView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneGameView(displayView: .constant(.game))
    }
}

struct PointsBannerView: View {
    @Binding var points: Int
    
    var body: some View {
        HStack {
            Text("Your points: ")
                .font(.custom("ArialRoundedMTBold", size: 30))
                .foregroundColor(.drawordAccent)
            
            Spacer()
            
            Text("\(points)")
                .font(.custom("ArialRoundedMTBold", size: 30))
                .foregroundColor(.drawordSecondary)
        }
        .padding()
    }
}
