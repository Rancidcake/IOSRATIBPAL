import SwiftUI

// Wrapper view for backward compatibility
struct AddOfferingView: View {
    @StateObject private var offeringViewModel = OfferingViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        AddEditOfferingView(offeringViewModel: offeringViewModel)
            .onAppear {
                // Load categories and prepare for adding new offering
                offeringViewModel.loadMyOfferings()
            }
    }
}

// Legacy support - keeping the original structure for any references
struct LegacyAddOfferingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var showAddOfferingDetails = false
    @State private var selectedCategoryName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Select offering category")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible placeholder to center the title
                    Image(systemName: "arrow.left")
                        .opacity(0)
                        .font(.title2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.blue)
                
                // Tab Bar
                HStack(spacing: 0) {
                    // Redirect to new AddEditOfferingView
                    // This maintains backward compatibility
                    Text("Redirecting to new offering form...")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    AddOfferingView()
}
