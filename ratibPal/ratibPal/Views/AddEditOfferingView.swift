import SwiftUI

struct AddEditOfferingView: View {
    let categoryName: String
    @ObservedObject var offeringViewModel: OfferingViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Basic Information
    @State private var offeringName: String = ""
    @State private var shortName: String = ""
    @State private var description: String = ""
    @State private var supplierDefinedCategory: String = ""
    @State private var unitOfMeasurement: String = ""
    @State private var barcode: String = ""
    @State private var crateLabel: String = ""
    @State private var crateCapacity: String = ""
    
    // Sections Visibility
    @State private var nameExpanded: Bool = false
    @State private var availabilityExpanded: Bool = false
    @State private var deliveryExpanded: Bool = false
    @State private var pricingExpanded: Bool = false
    
    // Checkboxes
    @State private var advancedOptions: Bool = false
    @State private var taxEnabled: Bool = false
    @State private var purchaseEnabled: Bool = false
    @State private var variantsEnabled: Bool = false
    @State private var returnsOk: Bool = false
    
    // Availability
    @State private var availabilityType: AvailabilityType = .calendar
    @State private var availabilityPeriod: AvailabilityPeriod = .everyday
    @State private var periodValue: String = "1"
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var selectedWeekdays: Set<Int> = [0, 1, 2, 3, 4, 5, 6] // All days selected by default
    
    // Delivery Slots & Locations
    @State private var slotMorning: Bool = true
    @State private var slotNoon: Bool = false
    @State private var slotEvening: Bool = false
    @State private var slotAlways: Bool = false
    @State private var slotASAP: Bool = false
    
    @State private var deliveryDoorstep: Bool = true
    @State private var deliveryPickup: Bool = false
    @State private var deliveryDineIn: Bool = false
    
    // Pricing
    @State private var pricingType: PricingType = .fixedPerUnit
    @State private var billingPeriod: BillingPeriod = .monthly
    @State private var paymentTiming: PaymentTiming = .postpaid
    @State private var termMonths: String = ""
    @State private var menuShowPrice: MenuPriceDisplay = .sellPrice
    
    // Price Fields
    @State private var basePrice: String = ""
    @State private var sellPrice: String = ""
    @State private var strikePrice: String = ""
    @State private var purchasePrice: String = ""
    @State private var deliveryChargePerOrder: String = ""
    @State private var deliveryChargePerMonth: String = ""
    
    // Tax Fields
    @State private var taxCode1: String = ""
    @State private var taxPercent1: String = ""
    @State private var taxCode2: String = ""
    @State private var taxPercent2: String = ""
    @State private var taxCode3: String = ""
    @State private var taxPercent3: String = ""
    @State private var taxCode4: String = ""
    @State private var taxPercent4: String = ""
    
    // Day-wise pricing (for VWD - Variable by Weekday)
    @State private var basePriceSun: String = ""
    @State private var basePriceMon: String = ""
    @State private var basePriceTue: String = ""
    @State private var basePriceWed: String = ""
    @State private var basePriceThu: String = ""
    @State private var basePriceFri: String = ""
    @State private var basePriceSat: String = ""
    
    @State private var sellPriceSun: String = ""
    @State private var sellPriceMon: String = ""
    @State private var sellPriceTue: String = ""
    @State private var sellPriceWed: String = ""
    @State private var sellPriceThu: String = ""
    @State private var sellPriceFri: String = ""
    @State private var sellPriceSat: String = ""
    
    // Variants
    @State private var variants: [VariantModel] = []
    
    // Alerts
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Date Pickers
    @State private var showingStartDatePicker = false
    @State private var showingEndDatePicker = false
    
    // Dropdown selections
    @State private var showingAvailabilityTypeMenu = false
    @State private var showingAvailabilityPeriodMenu = false
    @State private var showingPricingTypeMenu = false
    @State private var showingBillingPeriodMenu = false
    @State private var showingPaymentTimingMenu = false
    
    // MARK: - Enums
    enum AvailabilityType: String, CaseIterable {
        case calendar = "Calendar"
        case servicePlan = "Service Plan"
    }
    
    enum AvailabilityPeriod: String, CaseIterable {
        case everyday = "Every Day"
        case everyWeek = "Every Week"
        case everyMonth = "Every Month"
        case everyYear = "Every Year"
    }
    
    enum PricingType: String, CaseIterable {
        case fixedPerUnit = "Fixed Per Unit"
        case fixedPerMonth = "Fixed Per Month"
        case fixedPerTerm = "Fixed Per Term"
        case variableByVariant = "Variable By Variant"
        case variableByWeekday = "Variable By Weekday"
        case variableOnActual = "Variable On Actual"
    }
    
    enum BillingPeriod: String, CaseIterable {
        case monthly = "Monthly"
        case daily = "Per Order Day"
    }
    
    enum PaymentTiming: String, CaseIterable {
        case postpaid = "Postpaid"
        case prepaid = "Prepaid"
    }
    
    enum MenuPriceDisplay: String, CaseIterable {
        case sellPrice = "Sell Price"
        case basePlusTax = "Base + Tax"
    }
    
    var body: some View {
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
                
                Text("Add \(categoryName) offering")
                    .font(.system(size: 18, weight: .medium))
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
            
            ScrollView {
                VStack(spacing: 2) {
                    // Name & Description Section
                    nameDescriptionSection
                    
                    // Availability Section
                    availabilitySection
                    
                    // For Delivery Section
                    deliverySection
                    
                    // Pricing Section
                    pricingSection
                    
                    // Variants Section
                    variantsSection
                    
                    Spacer(minLength: 100) // Space for save button
                }
            }
            
            // Save Button
            Button(action: {
                saveOffering()
            }) {
                Text("Set Offering")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
            }
        }
        .navigationBarHidden(true)
        .alert("Validation Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingStartDatePicker) {
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
        }
        .sheet(isPresented: $showingEndDatePicker) {
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
        }
    }
    
    // MARK: - Section Views
    
    private var nameDescriptionSection: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    nameExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Name & Description")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        // Advanced Options Checkbox
                        Button(action: {
                            advancedOptions.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: advancedOptions ? "checkmark.square.fill" : "square")
                                    .foregroundColor(advancedOptions ? .blue : .gray)
                                    .font(.system(size: 16))
                                Text("Advanced options")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Image(systemName: nameExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.1))
            
            // Content
            if nameExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Supplier Defined Category
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Supplier defined category")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("Enter category", text: $supplierDefinedCategory)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Offering Name
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name (English) *")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("Enter offering name", text: $offeringName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Short name and Unit of Measurement
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Short name")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField("", text: $shortName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unit of Measurement")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField("", text: $unitOfMeasurement)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("Enter description", text: $description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    // Advanced fields
                    if advancedOptions {
                        VStack(alignment: .leading, spacing: 16) {
                            // Barcode
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Barcode")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                TextField("Enter barcode", text: $barcode)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // Crate info
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Crate/Container Label")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    TextField("", text: $crateLabel)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Crate Capacity")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    TextField("", text: $crateCapacity)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
            }
        }
    }
    
    private var availabilitySection: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    availabilityExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Available")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(getAvailabilityDescription())
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: availabilityExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.1))
            
            // Content
            if availabilityExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Availability Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Availability Type")
                            .font(.system(size: 14, weight: .medium))
                        
                        HStack(spacing: 20) {
                            ForEach(AvailabilityType.allCases, id: \.self) { type in
                                Button(action: {
                                    availabilityType = type
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: availabilityType == type ? "largecircle.fill.circle" : "circle")
                                            .foregroundColor(availabilityType == type ? .blue : .gray)
                                        Text(type.rawValue)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }
                    
                    if availabilityType == .servicePlan {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Every N periods")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField("1", text: $periodValue)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    } else {
                        // Availability Period
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Availability")
                                .font(.system(size: 14, weight: .medium))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(AvailabilityPeriod.allCases, id: \.self) { period in
                                    Button(action: {
                                        availabilityPeriod = period
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: availabilityPeriod == period ? "largecircle.fill.circle" : "circle")
                                                .foregroundColor(availabilityPeriod == period ? .blue : .gray)
                                            Text(period.rawValue)
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Weekday selection for "Every Week"
                        if availabilityPeriod == .everyWeek {
                            weekdaySelectionView
                        }
                    }
                    
                    // Date Range
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date Range")
                            .font(.system(size: 14, weight: .medium))
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Start Date")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Button(action: {
                                    showingStartDatePicker = true
                                }) {
                                    Text(DateFormatter.displayDate.string(from: startDate))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("End Date")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Button(action: {
                                    showingEndDatePicker = true
                                }) {
                                    Text(DateFormatter.displayDate.string(from: endDate))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
            }
        }
    }
    
    private var weekdaySelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Weekdays")
                .font(.system(size: 14, weight: .medium))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(0..<7) { dayIndex in
                    let dayName = Calendar.current.weekdaySymbols[dayIndex]
                    Button(action: {
                        if selectedWeekdays.contains(dayIndex) {
                            selectedWeekdays.remove(dayIndex)
                        } else {
                            selectedWeekdays.insert(dayIndex)
                        }
                    }) {
                        Text(String(dayName.prefix(3)))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(selectedWeekdays.contains(dayIndex) ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedWeekdays.contains(dayIndex) ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
    
    private var deliverySection: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    deliveryExpanded.toggle()
                }
            }) {
                HStack {
                    Text("For Delivery")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(getDeliveryDescription())
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: deliveryExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.1))
            
            // Content
            if deliveryExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Delivery Slots
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Slots")
                            .font(.system(size: 14, weight: .medium))
                        
                        VStack(spacing: 8) {
                            CheckboxRow(title: "Morning (AM)", isChecked: $slotMorning)
                            CheckboxRow(title: "Noon", isChecked: $slotNoon)
                            CheckboxRow(title: "Evening (PM)", isChecked: $slotEvening)
                            CheckboxRow(title: "Always", isChecked: $slotAlways)
                            CheckboxRow(title: "ASAP", isChecked: $slotASAP)
                        }
                    }
                    
                    // Delivery Locations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Delivery Locations")
                            .font(.system(size: 14, weight: .medium))
                        
                        VStack(spacing: 8) {
                            CheckboxRow(title: "Doorstep Delivery", isChecked: $deliveryDoorstep)
                            CheckboxRow(title: "Store Pickup", isChecked: $deliveryPickup)
                            CheckboxRow(title: "Dine-in", isChecked: $deliveryDineIn)
                        }
                    }
                    
                    // Returns OK (for goods)
                    if categoryName.lowercased().contains("goods") || categoryName.lowercased().contains("product") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Returns")
                                .font(.system(size: 14, weight: .medium))
                            
                            Toggle("Returns OK", isOn: $returnsOk)
                                .toggleStyle(SwitchToggleStyle())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    pricingExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Pricing")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(getPricingDescription())
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: pricingExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.1))
            
            // Content
            if pricingExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Billing Options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Billing & Payment")
                            .font(.system(size: 14, weight: .medium))
                        
                        // Billing Period
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bill on")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            HStack(spacing: 20) {
                                ForEach(BillingPeriod.allCases, id: \.self) { period in
                                    Button(action: {
                                        billingPeriod = period
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: billingPeriod == period ? "largecircle.fill.circle" : "circle")
                                                .foregroundColor(billingPeriod == period ? .blue : .gray)
                                            Text(period.rawValue)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Payment Timing
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pay at")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            HStack(spacing: 20) {
                                ForEach(PaymentTiming.allCases, id: \.self) { timing in
                                    Button(action: {
                                        paymentTiming = timing
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: paymentTiming == timing ? "largecircle.fill.circle" : "circle")
                                                .foregroundColor(paymentTiming == timing ? .blue : .gray)
                                            Text(timing.rawValue)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Pricing Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pricing Type")
                            .font(.system(size: 14, weight: .medium))
                        
                        ForEach(PricingType.allCases, id: \.self) { type in
                            Button(action: {
                                pricingType = type
                                if type == .variableByVariant {
                                    variantsEnabled = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: pricingType == type ? "largecircle.fill.circle" : "circle")
                                        .foregroundColor(pricingType == type ? .blue : .gray)
                                    Text(type.rawValue)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // Term field for Fixed Per Term
                    if pricingType == .fixedPerTerm {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Term (months)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField("Enter term in months", text: $termMonths)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    // Checkboxes for additional features
                    VStack(spacing: 8) {
                        CheckboxRow(title: "Tax", isChecked: $taxEnabled)
                        CheckboxRow(title: "Purchase Price", isChecked: $purchaseEnabled)
                    }
                    
                    // Menu Price Display (when tax is enabled)
                    if taxEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("On menu show")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            HStack(spacing: 20) {
                                ForEach(MenuPriceDisplay.allCases, id: \.self) { display in
                                    Button(action: {
                                        menuShowPrice = display
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: menuShowPrice == display ? "largecircle.fill.circle" : "circle")
                                                .foregroundColor(menuShowPrice == display ? .blue : .gray)
                                            Text(display.rawValue)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Price Fields
                    if pricingType != .variableByVariant {
                        priceFieldsView
                    }
                    
                    // Tax Fields
                    if taxEnabled {
                        taxFieldsView
                    }
                    
                    // Day-wise pricing (for Variable by Weekday)
                    if pricingType == .variableByWeekday {
                        dayWisePricingView
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
            }
        }
    }
    
    private var priceFieldsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pricing")
                .font(.system(size: 14, weight: .medium))
            
            VStack(spacing: 12) {
                // Base Price (when tax is enabled)
                if taxEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Base Price")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("0.00", text: $basePrice)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .onChange(of: basePrice) { oldValue, newValue in
                                updateSellPriceFromBase()
                            }
                    }
                }
                
                // Sell Price
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sell Price")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    TextField("0.00", text: $sellPrice)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .onChange(of: sellPrice) { oldValue, newValue in
                            updateBasePriceFromSell()
                        }
                }
                
                // Strike Price (advanced)
                if advancedOptions {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Strike Through Price")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("0.00", text: $strikePrice)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
                
                // Purchase Price
                if purchaseEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Purchase Price")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("0.00", text: $purchasePrice)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
                
                // Delivery Charges
                if pricingType != .fixedPerMonth && pricingType != .fixedPerTerm {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Delivery per order")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField("0.00", text: $deliveryChargePerOrder)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Delivery per month")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField("0.00", text: $deliveryChargePerMonth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
                }
            }
        }
    }
    
    private var taxFieldsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tax Codes")
                .font(.system(size: 14, weight: .medium))
            
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tax Code 1")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("Code", text: $taxCode1)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Percentage 1")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("0.00", text: $taxPercent1)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .onChange(of: taxPercent1) { oldValue, newValue in
                                updatePricesFromTax()
                            }
                    }
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tax Code 2")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("Code", text: $taxCode2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Percentage 2")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("0.00", text: $taxPercent2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .onChange(of: taxPercent2) { oldValue, newValue in
                                updatePricesFromTax()
                            }
                    }
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tax Code 3")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("Code", text: $taxCode3)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Percentage 3")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("0.00", text: $taxPercent3)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .onChange(of: taxPercent3) { oldValue, newValue in
                                updatePricesFromTax()
                            }
                    }
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tax Code 4")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("Code", text: $taxCode4)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Percentage 4")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        TextField("0.00", text: $taxPercent4)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .onChange(of: taxPercent4) { oldValue, newValue in
                                updatePricesFromTax()
                            }
                    }
                }
            }
        }
    }
    
    private var dayWisePricingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Day-wise Pricing")
                .font(.system(size: 14, weight: .medium))
            
            Text("Note: Prices will be applied to selected weekdays")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                // Headers
                HStack {
                    Text("Day")
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 60, alignment: .leading)
                    if taxEnabled {
                        Text("Base")
                            .font(.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity)
                    }
                    Text("Sell")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 8)
                
                // Days
                ForEach(0..<7) { dayIndex in
                    if selectedWeekdays.contains(dayIndex) {
                        let dayName = Calendar.current.shortWeekdaySymbols[dayIndex]
                        HStack {
                            Text(dayName)
                                .font(.system(size: 12))
                                .frame(width: 60, alignment: .leading)
                            
                            if taxEnabled {
                                TextField("0.00", text: getDayBasePriceBinding(for: dayIndex))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 12))
                            }
                            
                            TextField("0.00", text: getDaySellPriceBinding(for: dayIndex))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .font(.system(size: 12))
                        }
                    }
                }
            }
        }
    }
    
    private var variantsSection: some View {
        VStack(spacing: 0) {
            // Header with checkbox
            HStack {
                Button(action: {
                    variantsEnabled.toggle()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: variantsEnabled ? "checkmark.square.fill" : "square")
                            .foregroundColor(variantsEnabled ? .blue : .gray)
                            .font(.system(size: 16))
                        Text("Variants: size / colour / pack / plan")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.1))
            
            // Variants list (when enabled)
            if variantsEnabled {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(variants.indices, id: \.self) { index in
                        VariantRowView(
                            variant: variants[index],
                            index: index,
                            showAdvanced: advancedOptions,
                            showPricing: pricingType == .variableByVariant,
                            showTax: taxEnabled,
                            showPurchase: purchaseEnabled,
                            onDelete: {
                                variants.remove(at: index)
                            },
                            onUpdate: { index, updatedVariant in
                                variants[index] = updatedVariant
                            }
                        )
                    }
                    
                    // Add Variant Button
                    Button(action: {
                        addNewVariant()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                            Text("Add Variant")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getAvailabilityDescription() -> String {
        if availabilityType == .servicePlan {
            return "Service Plan"
        } else {
            return availabilityPeriod.rawValue.lowercased()
        }
    }
    
    private func getDeliveryDescription() -> String {
        var slots: [String] = []
        if slotMorning { slots.append("AM") }
        if slotNoon { slots.append("Noon") }
        if slotEvening { slots.append("PM") }
        if slotAlways { slots.append("Always") }
        if slotASAP { slots.append("ASAP") }
        return slots.joined(separator: ", ")
    }
    
    private func getPricingDescription() -> String {
        return pricingType.rawValue
    }
    
    private func updateSellPriceFromBase() {
        guard let base = Double(basePrice), base > 0 else { return }
        let taxRate = getTotalTaxPercentage()
        let sell = base * (1 + taxRate / 100)
        sellPrice = String(format: "%.2f", sell)
    }
    
    private func updateBasePriceFromSell() {
        guard let sell = Double(sellPrice), sell > 0 else { return }
        let taxRate = getTotalTaxPercentage()
        let base = sell / (1 + taxRate / 100)
        basePrice = String(format: "%.2f", base)
    }
    
    private func updatePricesFromTax() {
        if !basePrice.isEmpty {
            updateSellPriceFromBase()
        } else if !sellPrice.isEmpty {
            updateBasePriceFromSell()
        }
    }
    
    private func getTotalTaxPercentage() -> Double {
        let tax1 = Double(taxPercent1) ?? 0
        let tax2 = Double(taxPercent2) ?? 0
        let tax3 = Double(taxPercent3) ?? 0
        let tax4 = Double(taxPercent4) ?? 0
        return tax1 + tax2 + tax3 + tax4
    }
    
    private func getDayBasePriceBinding(for dayIndex: Int) -> Binding<String> {
        switch dayIndex {
        case 0: return $basePriceSun
        case 1: return $basePriceMon
        case 2: return $basePriceTue
        case 3: return $basePriceWed
        case 4: return $basePriceThu
        case 5: return $basePriceFri
        case 6: return $basePriceSat
        default: return $basePriceSun
        }
    }
    
    private func getDaySellPriceBinding(for dayIndex: Int) -> Binding<String> {
        switch dayIndex {
        case 0: return $sellPriceSun
        case 1: return $sellPriceMon
        case 2: return $sellPriceTue
        case 3: return $sellPriceWed
        case 4: return $sellPriceThu
        case 5: return $sellPriceFri
        case 6: return $sellPriceSat
        default: return $sellPriceSun
        }
    }
    
    private func addNewVariant() {
        let newVariant = VariantModel(
            vid: UUID().uuidString,
            name: "",
            barcode: nil,
            imageIds: [],
            crateLabel: nil,
            crateCapacity: 0,
            isPublic: true,
            sequence: Int32(variants.count)
        )
        variants.append(newVariant)
    }
    
    private func validateForm() -> Bool {
        if offeringName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Please enter offering name"
            showingAlert = true
            return false
        }
        
        let selectedSlots = [slotMorning, slotNoon, slotEvening, slotAlways, slotASAP]
        if !selectedSlots.contains(true) {
            alertMessage = "Please select at least one delivery slot"
            showingAlert = true
            return false
        }
        
        let selectedLocations = [deliveryDoorstep, deliveryPickup, deliveryDineIn]
        if !selectedLocations.contains(true) {
            alertMessage = "Please select at least one delivery location"
            showingAlert = true
            return false
        }
        
        if pricingType == .fixedPerTerm && termMonths.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Please enter term in months"
            showingAlert = true
            return false
        }
        
        if pricingType != .variableByVariant && sellPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Please enter sell price"
            showingAlert = true
            return false
        }
        
        if variantsEnabled && variants.isEmpty {
            alertMessage = "Please add at least one variant or disable variants"
            showingAlert = true
            return false
        }
        
        return true
    }
    
    private func saveOffering() {
        guard validateForm() else { return }
        
        // Create price model
        let price = PriceModel(
            id: nil,
            variantId: nil,
            applicableDate: Int32(Date().timeIntervalSince1970),
            termMonths: Int32(termMonths) ?? 0,
            basePrice: Double(basePrice) ?? 0.0,
            sellPrice: Double(sellPrice) ?? 0.0,
            strikeThroughPrice: Double(strikePrice) ?? 0.0,
            purchasePrice: purchaseEnabled ? (Double(purchasePrice) ?? 0.0) : 0.0,
            deliveryChargePerOrder: Double(deliveryChargePerOrder) ?? 0.0,
            deliveryChargePerMonth: Double(deliveryChargePerMonth) ?? 0.0,
            dayWiseBasePrices: getDayWiseBasePrices(),
            dayWiseSellPrices: getDayWiseSellPrices(),
            dayWiseStrikePrices: nil,
            dayWisePurchasePrices: nil,
            taxCodes: getTaxCodes()
        )
        
        // Create offering model
        let offering = OfferingModel(
            gid: UUID().uuidString,
            name: offeringName.trimmingCharacters(in: .whitespacesAndNewlines),
            shortName: shortName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : shortName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            barcode: barcode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : barcode.trimmingCharacters(in: .whitespacesAndNewlines),
            imageIds: [],
            unitLabel: unitOfMeasurement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : unitOfMeasurement.trimmingCharacters(in: .whitespacesAndNewlines),
            crateLabel: crateLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : crateLabel.trimmingCharacters(in: .whitespacesAndNewlines),
            crateCapacity: Int32(crateCapacity) ?? 0,
            isPublic: true,
            availableSlots: getAvailableSlots(),
            startDate: Int32(startDate.timeIntervalSince1970),
            endDate: Int32(endDate.timeIntervalSince1970),
            category: categoryName,
            supplierDefinedCategory: supplierDefinedCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : supplierDefinedCategory.trimmingCharacters(in: .whitespacesAndNewlines),
            variants: variantsEnabled ? variants : [],
            prices: [price],
            sources: []
        )
        
        // Save through ViewModel
        Task {
            await offeringViewModel.createOffering(offering)
            await MainActor.run {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func getAvailableSlots() -> String {
        var slots: [String] = []
        if slotMorning { slots.append("A") }
        if slotNoon { slots.append("N") }
        if slotEvening { slots.append("P") }
        if slotAlways { slots.append("L") }
        if slotASAP { slots.append("S") }
        return slots.joined()
    }
    
    private func getDayWiseBasePrices() -> [String: Double]? {
        if pricingType != .variableByWeekday || !taxEnabled { return nil }
        
        var prices: [String: Double] = [:]
        for dayIndex in selectedWeekdays.sorted() {
            let dayName = Calendar.current.shortWeekdaySymbols[dayIndex]
            let priceText = getDayBasePriceBinding(for: dayIndex).wrappedValue
            prices[dayName] = Double(priceText) ?? 0.0
        }
        return prices.isEmpty ? nil : prices
    }
    
    private func getDayWiseSellPrices() -> [String: Double]? {
        if pricingType != .variableByWeekday { return nil }
        
        var prices: [String: Double] = [:]
        for dayIndex in selectedWeekdays.sorted() {
            let dayName = Calendar.current.shortWeekdaySymbols[dayIndex]
            let priceText = getDaySellPriceBinding(for: dayIndex).wrappedValue
            prices[dayName] = Double(priceText) ?? 0.0
        }
        return prices.isEmpty ? nil : prices
    }
    
    private func getTaxCodes() -> [String]? {
        if !taxEnabled { return nil }
        
        var codes: [String] = []
        if !taxCode1.isEmpty && !taxPercent1.isEmpty {
            codes.append("\(taxCode1)@\(taxPercent1)")
        }
        if !taxCode2.isEmpty && !taxPercent2.isEmpty {
            codes.append("\(taxCode2)@\(taxPercent2)")
        }
        if !taxCode3.isEmpty && !taxPercent3.isEmpty {
            codes.append("\(taxCode3)@\(taxPercent3)")
        }
        if !taxCode4.isEmpty && !taxPercent4.isEmpty {
            codes.append("\(taxCode4)@\(taxPercent4)")
        }
        return codes.isEmpty ? nil : codes
    }
}

// MARK: - Supporting Views

struct CheckboxRow: View {
    let title: String
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack(spacing: 8) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .blue : .gray)
                    .font(.system(size: 16))
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
}

struct VariantRowView: View {
    let variant: VariantModel
    let index: Int
    let showAdvanced: Bool
    let showPricing: Bool
    let showTax: Bool
    let showPurchase: Bool
    let onDelete: () -> Void
    let onUpdate: (Int, VariantModel) -> Void
    
    @State private var variantName: String = ""
    @State private var containerLabel: String = ""
    @State private var containerCapacity: String = ""
    @State private var barcode: String = ""
    @State private var basePrice: String = ""
    @State private var sellPrice: String = ""
    @State private var purchasePrice: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Variant \(index + 1)")
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                Button("Delete", role: .destructive) {
                    onDelete()
                }
                .font(.system(size: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Variant name *", text: $variantName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: variantName) { _, newValue in
                        updateVariant()
                    }
                
                if showAdvanced {
                    HStack(spacing: 16) {
                        TextField("Container label", text: $containerLabel)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: containerLabel) { _, newValue in
                                updateVariant()
                            }
                        
                        TextField("Capacity", text: $containerCapacity)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .onChange(of: containerCapacity) { _, newValue in
                                updateVariant()
                            }
                    }
                    
                    TextField("Barcode", text: $barcode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: barcode) { _, newValue in
                            updateVariant()
                        }
                }
                
                if showPricing {
                    HStack(spacing: 16) {
                        if showTax {
                            TextField("Base price", text: $basePrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        
                        TextField("Sell price", text: $sellPrice)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        
                        if showPurchase {
                            TextField("Purchase price", text: $purchasePrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .onAppear {
            variantName = variant.name
            containerLabel = variant.crateLabel ?? ""
            containerCapacity = variant.crateCapacity > 0 ? String(variant.crateCapacity) : ""
            barcode = variant.barcode ?? ""
        }
    }
    
    private func updateVariant() {
        let updatedVariant = VariantModel(
            vid: variant.vid,
            name: variantName,
            barcode: barcode.isEmpty ? nil : barcode,
            imageIds: variant.imageIds,
            crateLabel: containerLabel.isEmpty ? nil : containerLabel,
            crateCapacity: Int32(containerCapacity) ?? 0,
            isPublic: variant.isPublic,
            sequence: variant.sequence
        )
        onUpdate(index, updatedVariant)
    }
}



#Preview {
    AddEditOfferingView(categoryName: "Paper, Magazine", offeringViewModel: OfferingViewModel())
}