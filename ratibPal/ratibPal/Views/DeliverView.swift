import SwiftUI

struct BillingView: View {
    var body: some View {
        NavigationView {
            ExpenseDiaryView()
                .navigationTitle("Billing")
        }
    }
}
