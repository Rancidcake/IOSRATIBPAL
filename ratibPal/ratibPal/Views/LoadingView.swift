//
//  LoadingView.swift
//  ratibPal
//
//  Created by Malhar Borse on 20/07/25.
//
import SwiftUI

struct LoadingView: View {
    var onLoadingComplete: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("RatibPalLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
              
            
            Text("goods, services & utilities")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 10)

            
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            // Navigate to login after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onLoadingComplete()
            }
        }
    }
}

#Preview {
    LoadingView {
        print("Loading complete")
    }
}
