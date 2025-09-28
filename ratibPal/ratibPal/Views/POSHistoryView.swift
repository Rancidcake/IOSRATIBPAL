import SwiftUI

struct POSHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        // Search action
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.blue)
                
                // Store info
                HStack {
                    Text("In store")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text("1")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                // Table Header
                HStack {
                    Text("Items")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Count")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 60)
                    
                    Text("Price")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 60)
                    
                    Text("Bill Total")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 80)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                
                // Empty cart content
                VStack {
                    Spacer()
                    
                    Text("Cart is empty")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom section - POS History popup
                VStack(spacing: 0) {
                    // POS History Header
                    HStack {
                        Text("POS history")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    
                    // POS History Table Header
                    HStack {
                        Text("Bill #")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(width: 60, alignment: .leading)
                        
                        Text("Paid")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(width: 60, alignment: .center)
                        
                        Text("Bill Total")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    
                    // Empty history content
                    VStack {
                        Spacer()
                        
                        Text("No history available")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                }
                .frame(height: 200)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    POSHistoryView()
}
