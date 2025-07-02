import SwiftUI

struct PurchaseView: View {
    var body: some View {
        NavigationView {
            PayablesView()
                .navigationTitle("Purchase")
        }
    }
}