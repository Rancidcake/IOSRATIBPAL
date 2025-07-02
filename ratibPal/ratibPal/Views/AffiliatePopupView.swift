import SwiftUI

struct AffiliatePopupView: View {
    @Environment(\.dismiss) private var dismiss
    let affiliates: [String]
    let onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Text("All Lines")
                        .font(.headline)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)

                // Content
                Text("Add or edit affiliates")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.top, 8)
                Form {
                    Section(header: Text("Affiliate Details")) {
                        HStack {
                            TextField("Affiliate name", text: .constant(""))
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.gray)
                        }
                        HStack {
                            TextField("Mobile Number", text: .constant(""))
                                .keyboardType(.phonePad)
                            TextField("ERP user id", text: .constant(""))
                                .foregroundColor(.secondary)
                        }
                    }
                    Section(header: Text("Permissions")) {
                        Toggle("Home", isOn: .constant(false))
                        Toggle("Purchase", isOn: .constant(false))
                        Toggle("Delivery", isOn: .constant(false))
                        Toggle("Billing", isOn: .constant(false))
                    }
                }

                Button("Update") {
                    // handle update
                    dismiss()
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()

                Button(action: {}) {
                    Text("Assigned affiliates")
                        .font(.caption)
                        .underline()
                        .foregroundColor(.blue)
                }
                .padding(.bottom)
            }
        }
    }
}
