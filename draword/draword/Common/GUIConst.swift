//
//  GUIConst.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import SwiftUI

extension Color {
    static let drawordAccent = Color("AccentColor")
    static let drawordSecondary = Color("SecondaryAccentColor")
}

enum DisplayView {
    // Common iPhone and iPad
    case main
    case newRoom
    case game
    // iPhone only
    case phoneWaitParticipants
    case guess
}
