import SwiftUI
import PhotosUI

// Multi-image picker using PhotosUI
struct MultiImagePicker: View {
    @Binding var selectedImages: [UIImage]
    @State private var photosPickerItems: [PhotosPickerItem] = []
    
    var body: some View {
        PhotosPicker(
            selection: $photosPickerItems,
            maxSelectionCount: 10,
            matching: .images
        ) {
            HStack {
                Image(systemName: "photo.badge.plus")
                Text("Select Images")
            }
        }
        .onChange(of: photosPickerItems) { newItems in
            Task {
                selectedImages.removeAll()
                for item in newItems {
                    if let imageData = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: imageData) {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
}

struct EditOfferingView: View {
    let offeringViewModel: OfferingViewModel
    let editingOffering: OfferingModel?
    
    @StateObject private var viewModel: AddEditOfferingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    @State private var showingTimeSlotPicker = false
    @State private var showingCategoryPicker = false
    
    init(offeringViewModel: OfferingViewModel, editingOffering: OfferingModel? = nil) {
        self.offeringViewModel = offeringViewModel
        self.editingOffering = editingOffering
        self._viewModel = StateObject(wrappedValue: AddEditOfferingViewModel(offering: editingOffering, offeringViewModel: offeringViewModel))
    }
    
    var body: some View {
        NavigationView {
            Form {
                basicInformationSection
                pricingSection
                availabilitySection
                imagesSection
                variantsSection
            }
            .navigationTitle(editingOffering == nil ? "Add Offering" : "Edit Offering")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            if await viewModel.saveOffering() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isUploading)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Sections
    
    private var basicInformationSection: some View {
        Section("Basic Information") {
            TextField("Name*", text: $viewModel.name)
            
            TextField("Short Name", text: $viewModel.shortName)
            
            TextField("Description", text: $viewModel.description, axis: .vertical)
                .lineLimit(3...6)
            
            TextField("Barcode", text: $viewModel.barcode)
            
            HStack {
                Text("Category")
                Spacer()
                Button(viewModel.category.isEmpty ? "Select Category" : viewModel.category) {
                    showingCategoryPicker = true
                }
                .foregroundColor(.blue)
            }
            
            TextField("Supplier Category", text: $viewModel.supplierDefinedCategory)
            
            HStack {
                TextField("Unit Label", text: $viewModel.unitLabel)
                Text("(kg, liter, etc.)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                TextField("Crate Label", text: $viewModel.crateLabel)
                
                Spacer()
                
                Text("Capacity:")
                    .font(.caption)
                
                TextField("0", value: $viewModel.crateCapacity, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
            }
            
            Toggle("Public Offering", isOn: $viewModel.isPublic)
        }
    }
    
    private var pricingSection: some View {
        Section("Pricing") {
            HStack {
                Text("Base Price")
                Spacer()
                TextField("0.00", value: $viewModel.basePrice, format: .currency(code: "INR"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }
            
            HStack {
                Text("Sell Price*")
                Spacer()
                TextField("0.00", value: $viewModel.sellPrice, format: .currency(code: "INR"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }
            
            HStack {
                Text("Strike Price")
                Spacer()
                TextField("0.00", value: $viewModel.strikeThroughPrice, format: .currency(code: "INR"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }
            
            HStack {
                Text("Purchase Price")
                Spacer()
                TextField("0.00", value: $viewModel.purchasePrice, format: .currency(code: "INR"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }
            
            HStack {
                Text("Delivery (Per Order)")
                Spacer()
                TextField("0.00", value: $viewModel.deliveryChargePerOrder, format: .currency(code: "INR"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }
            
            HStack {
                Text("Delivery (Per Month)")
                Spacer()
                TextField("0.00", value: $viewModel.deliveryChargePerMonth, format: .currency(code: "INR"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }
        }
    }
    
    private var availabilitySection: some View {
        Section("Availability") {
            DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
            
            DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Available Time Slots")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(TimeSlot.allCases, id: \.self) { slot in
                        Button(action: {
                            viewModel.toggleTimeSlot(slot)
                        }) {
                            HStack {
                                Image(systemName: viewModel.isTimeSlotSelected(slot) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(viewModel.isTimeSlotSelected(slot) ? .blue : .gray)
                                
                                Text(slot.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                if !viewModel.availableTimeSlots.isEmpty {
                    Text("Selected: \(viewModel.availableTimeSlots.map { $0.displayName }.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(nil)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var imagesSection: some View {
        Section("Images") {
            if viewModel.totalImages > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<viewModel.selectedImages.count, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: viewModel.selectedImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Button(action: {
                                    viewModel.removeImage(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .offset(x: 4, y: -4)
                            }
                        }
                        
                        ForEach(0..<viewModel.uploadedImageIds.count, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "photo")
                                                .foregroundColor(.blue)
                                            Text("Uploaded")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                    )
                                
                                Button(action: {
                                    viewModel.removeImage(at: viewModel.selectedImages.count + index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            MultiImagePicker(selectedImages: $viewModel.selectedImages)
            
            if viewModel.hasUnsavedImages {
                Button(action: {
                    Task {
                        await viewModel.uploadImages()
                    }
                }) {
                    HStack {
                        if viewModel.isUploading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "icloud.and.arrow.up")
                        }
                        Text(viewModel.isUploading ? "Uploading..." : "Upload Images")
                    }
                }
                .disabled(viewModel.isUploading)
            }
        }
    }
    
    private var variantsSection: some View {
        Section("Variants") {
            ForEach(0..<viewModel.variants.count, id: \.self) { index in
                HStack {
                    TextField("Variant name", text: Binding(
                        get: { viewModel.variants[index].name },
                        set: { viewModel.updateVariant(at: index, name: $0) }
                    ))
                    
                    Button(action: {
                        viewModel.removeVariant(at: index)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            
            Button(action: {
                viewModel.addVariant()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                    Text("Add Variant")
                }
            }
        }
    }
}

// MARK: - Supporting Views

extension EditOfferingView {
    // Could add more complex views here if needed
}

#Preview {
    EditOfferingView(offeringViewModel: OfferingViewModel())
}