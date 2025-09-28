import SwiftUI
import Network

struct NetworkStatusView<Content: View>: View {
    let content: Content
    @StateObject private var networkMonitor = NetworkMonitor()
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
            
            // Show network status banner when offline
            if !networkMonitor.isConnected {
                VStack {
                    HStack {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.white)
                        Text("No Internet Connection")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red)
                    
                    Spacer()
                }
                .transition(.move(edge: .top))
                .zIndex(1)
            }
        }
    }
}

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
