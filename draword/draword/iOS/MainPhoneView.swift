//
//  MainPhoneView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import SwiftUI
import Combine

struct MainPhoneView: View {
    @State var code: String = ""
    
    var body: some View {
        ZStack {
            MainPhoneBackgroundView()
            
            VStack {
                Spacer()
                
                Text("DRAWORD")
                    .font(.custom("ArialRoundedMTBold", size: 40))
                    .foregroundColor(.drawordAccent)
                
                Text("By ALFCorp")
                    .frame(width: 200, height: 30, alignment: .trailing)
                    .font(.custom("ArialRoundedMTBold", size: 15))
                    .foregroundColor(.drawordSecondary)
                
                Spacer()
                
                TextField("Room", text: $code)
                    .keyboardType(.numberPad)
                    .onReceive(Just(code)) { _ in limitCodeLength() }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200, height: 50, alignment: .center)
                
                Button {
                    print("Pressed")
                } label: {
                    Text("Play")
                        .bold()
                        .frame(width: 200, height: 50)
                        .foregroundColor(.white)
                        .background(Color.drawordAccent)
                        .clipShape(Capsule())
                        .padding()
                }
                
                Spacer()
            }
        }
    }
    
    func limitCodeLength() {
        if code.count > CODE_LENGTH {
            code = String(code.prefix(CODE_LENGTH))
        }
    }
}

struct MainPhoneBackgroundView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                QuarterCircle(radius: 200,
                              from: 180,
                              to: 270)
                    .fill(Color(UIColor.systemFill))
                    .frame(width: 1, height: 1)
            }
            
            Spacer()
            
            HStack {
                QuarterCircle(radius: 250,
                              from: 0,
                              to: 270)
                    .fill(Color(.secondaryLabel))
                    .frame(width: 1, height: 1)
                
                Spacer()
                
                QuarterCircle(radius: 150,
                              from: 270,
                              to: 180)
                    .fill(Color(.label))
                    .frame(width: 1, height: 1)
            }
        }
        .ignoresSafeArea()
    }
}

struct MainPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        MainPhoneView()
    }
}
