//
//  RatibPalv2App.swift
//  RatibPalv2
//
//  Created by Faheemuddin Sayyed on 27/06/25.
//

import SwiftUI

@main
struct RatibPalv2App: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
