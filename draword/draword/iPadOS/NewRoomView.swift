//
//  NewRoomView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import SwiftUI

struct NewRoomView: View {
    @State var nop: Int
    
    var body: some View {
        ZStack {
            MainPadBackgroundView()
            
            
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

struct NewRoomView_Previews: PreviewProvider {
    static var previews: some View {
        NewRoomView(nop: 4)
    }
}
