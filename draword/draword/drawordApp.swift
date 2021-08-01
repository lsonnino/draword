//
//  drawordApp.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import SwiftUI

@main
struct drawordApp: App {
    var body: some Scene {
        WindowGroup {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                MainPadView()
            }
            else {
                MainPhoneView()
            }
        }
    }
}
