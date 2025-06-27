import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var loadingProgress = 0.0
    @State private var statusText = "Authenticating..."
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Logo with Animation
            VStack(spacing: 20) {
                Image(systemName: "truck.box")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("Ratib Pal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            // Progress Section
            VStack(spacing: 16) {
                ProgressView(value: loadingProgress, total: 100.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 200)
                
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(Int(loadingProgress))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .onAppear {
            startLoadingAnimation()
        }
    }
    
    private func startLoadingAnimation() {
        isAnimating = true
        
        // Simulate loading progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if loadingProgress < 100 {
                loadingProgress += 2
                
                // Update status text based on progress
                if loadingProgress < 30 {
                    statusText = "Authenticating..."
                } else if loadingProgress < 60 {
                    statusText = "Loading profile..."
                } else if loadingProgress < 90 {
                    statusText = "Syncing data..."
                } else {
                    statusText = "Almost ready..."
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    LoadingView()
}