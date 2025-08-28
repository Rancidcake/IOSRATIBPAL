//
//  ContentView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NetworkStatusView {
            AuthenticationView()
        }
    }
}

#Preview {
    ContentView()
}
