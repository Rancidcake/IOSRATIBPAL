//
//  ContentView.swift
//  RatibPalv2
//
//  Created by Faheemuddin Sayyed on 27/06/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLoadingView = false
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if showingLoadingView {
                    LoadingView()
                        .onAppear {
                            // Simulate loading time
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showingLoadingView = false
                            }
                        }
                } else {
                    MainTabView()
                        .environmentObject(authViewModel)
                }
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
            if newValue && !oldValue {
                showingLoadingView = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
