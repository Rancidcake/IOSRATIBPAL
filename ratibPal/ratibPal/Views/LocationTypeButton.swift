import SwiftUI

struct LocationTypeButton: View {
    let code: String?
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    // Initializer for new registration flow (with code and icon)
    init(code: String, title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) {
        self.code = code
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    // Initializer for existing personal locations view (title only)
    init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.code = nil
        self.title = title
        self.icon = nil
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            if let icon = icon {
                // Registration flow style with icon
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .blue)
                    
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .blue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .cornerRadius(10)
            } else {
                // Personal locations style (text only)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    )
            }
        }
    }
}
