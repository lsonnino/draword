//
//  PadGameView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 03/08/2021.
//

import SwiftUI

struct PadGameView: View {
    @ObservedObject var gameState: GameState = GameState()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PadGameView_Previews: PreviewProvider {
    static var previews: some View {
        PadGameView()
    }
}
