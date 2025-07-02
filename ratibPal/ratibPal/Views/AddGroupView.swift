import SwiftUI

struct AddGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var groupName = ""
    let onCreate: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Name")) {
                    TextField("Enter group name", text: $groupName)
                }
            }
            .navigationTitle("Add Group")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(groupName)
                        dismiss()
                    }
                    .disabled(groupName.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}