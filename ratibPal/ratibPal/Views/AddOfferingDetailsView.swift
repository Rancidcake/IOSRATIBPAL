//
//  AddOfferingDetailsView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 17/07/25.
//

import SwiftUI

struct AddOfferingDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    let categoryName: String
    
    // Form fields
    @State private var nationalRegional = ""
    @State private var offeringNameEnglish = ""
    @State private var offeringNameHindi = ""
    
    // Availability section
    @State private var availabilityType = "Calendar" // Calendar or Service plan
    @State private var everyType = "Day" // Day, Week, Month, Year
    @State private var limitedPeriodFrom = ""
    @State private var limitedPeriodTill = ""
    
    // Slot checkboxes
    @State private var slotAM = true
    @State private var slotNoon = false
    @State private var slotPM = false
    @State private var slotAlways = false
    @State private var slotASAP = false
    
    // Delivery options
    @State private var deliveryDoorstep = true
    @State private var deliveryPickup = false
    @State private var deliveryInStore = false
    
    // Accept Returns
    @State private var acceptReturns = false
    
    // Billing
    @State private var billingType = "Monthly" // Monthly or Daily (by PO)
    
    // Payment
    @State private var paymentType = "Post-paid" // Post-paid or Pre-paid
    
    // Price section
    @State private var fixedPer = "Unit" // Unit, Month, Term(m)
    @State private var variesBy = "" // Variety, Weekday, Actuals
    @State private var variesByVariety = false
    @State private var variesByWeekday = false
    @State private var variesByActuals = false
    @State private var hasTax = false
    @State private var hasPromotion = false
    @State private var hasPurchase = false
    
    // Tax fields
    @State private var taxCode = ""
    @State private var cgstPercentage = ""
    @State private var sgstPercentage = ""
    @State private var igstPercentage = ""
    
    // Pricing fields
    @State private var netSell = ""
    @State private var serviceCharge = ""
    @State private var perOrderOnDemand = ""
    @State private var perMonthSubscription = ""
    
    // Weekday pricing fields
    @State private var mondayPrice = ""
    @State private var tuesdayPrice = ""
    @State private var wednesdayPrice = ""
    @State private var thursdayPrice = ""
    @State private var fridayPrice = ""
    @State private var saturdayPrice = ""
    @State private var sundayPrice = ""
    
    // Base pricing fields (before tax)
    @State private var baseMondayPrice = ""
    @State private var baseTuesdayPrice = ""
    @State private var baseWednesdayPrice = ""
    @State private var baseThursdayPrice = ""
    @State private var baseFridayPrice = ""
    @State private var baseSaturdayPrice = ""
    @State private var baseSundayPrice = ""
    @State private var varietyOfSizeColourPack = false
    @State private var unit = ""
    @State private var container = ""
    @State private var capacityUnitsContainer = ""
    @State private var itemCodeBarcode = ""
    @State private var offeringShortName = ""
    
    // Variety fields
    @State private var size1 = ""
    @State private var size2 = ""
    @State private var size3 = ""
    @State private var colour1 = ""
    @State private var colour2 = ""
    @State private var colour3 = ""
    @State private var pack1 = ""
    @State private var pack2 = ""
    @State private var pack3 = ""
    @State private var plan1 = ""
    @State private var plan2 = ""
    @State private var plan3 = ""
    @State private var departmentSection = ""
    @State private var onlineVisible = true
    @State private var descriptionEnglish = ""
    @State private var descriptionHindi = ""
    
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
                    
                    Text("Add \(categoryName) offering")
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
                
                ScrollView {
                    VStack(spacing: 0) {
                        // National/regional field
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("National / regional - daily, weekly, monthly...", text: $nationalRegional)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        
                        // Offering Name in English
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Offering Name in English", text: $offeringNameEnglish)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        
                        // Offering Name in Hindi
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Offering Name in Hindi", text: $offeringNameHindi)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        
                        // Availability Section
                        VStack(spacing: 0) {
                            // Section Header
                            HStack {
                                Text("Availability")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            
                            // As per radio buttons
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("As per")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                HStack(spacing: 20) {
                                    OfferingRadioButton(title: "Calendar", isSelected: availabilityType == "Calendar") {
                                        availabilityType = "Calendar"
                                    }
                                    
                                    OfferingRadioButton(title: "Service plan", isSelected: availabilityType == "Service plan") {
                                        availabilityType = "Service plan"
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                            }
                            .background(Color.white)
                            
                            // Every radio buttons
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Every")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                HStack(spacing: 20) {
                                    OfferingRadioButton(title: "Day", isSelected: everyType == "Day") {
                                        everyType = "Day"
                                    }
                                    
                                    OfferingRadioButton(title: "Week", isSelected: everyType == "Week") {
                                        everyType = "Week"
                                    }
                                    
                                    OfferingRadioButton(title: "Month", isSelected: everyType == "Month") {
                                        everyType = "Month"
                                    }
                                    
                                    OfferingRadioButton(title: "Year", isSelected: everyType == "Year") {
                                        everyType = "Year"
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                            .background(Color.white)
                            
                            // Limited period
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Limited period")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 16) {
                                        HStack {
                                            Text("From (optional)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            
                                            Button(action: {
                                                // Show date picker
                                            }) {
                                                Image(systemName: "calendar")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        
                                        HStack {
                                            Text("Till (optional)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            
                                            Button(action: {
                                                // Show date picker
                                            }) {
                                                Image(systemName: "calendar")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            
                            // Slot checkboxes
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Slot")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 16) {
                                        OfferingCheckboxButton(title: "AM", isChecked: $slotAM)
                                        OfferingCheckboxButton(title: "Noon", isChecked: $slotNoon)
                                        OfferingCheckboxButton(title: "PM", isChecked: $slotPM)
                                        OfferingCheckboxButton(title: "Always", isChecked: $slotAlways)
                                        OfferingCheckboxButton(title: "ASAP", isChecked: $slotASAP)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            
                            // Delivery at checkboxes
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Delivery at")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 16) {
                                        OfferingCheckboxButton(title: "Doorstep", isChecked: $deliveryDoorstep)
                                        OfferingCheckboxButton(title: "Pickup", isChecked: $deliveryPickup)
                                        OfferingCheckboxButton(title: "In store", isChecked: $deliveryInStore)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            
                            // Accept Returns
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Accept Returns")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 16) {
                                        Text("N")
                                            .font(.body)
                                            .foregroundColor(.gray)
                                        
                                        Toggle("", isOn: $acceptReturns)
                                            .tint(.blue)
                                        
                                        Text("No")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            
                            // Billing
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Billing")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                HStack(spacing: 20) {
                                    OfferingRadioButton(title: "Monthly", isSelected: billingType == "Monthly") {
                                        billingType = "Monthly"
                                    }
                                    
                                    OfferingRadioButton(title: "Daily (by PO)", isSelected: billingType == "Daily (by PO)") {
                                        billingType = "Daily (by PO)"
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                            .background(Color.white)
                            
                            // Payment
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Payment")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                HStack(spacing: 20) {
                                    OfferingRadioButton(title: "Post-paid", isSelected: paymentType == "Post-paid") {
                                        paymentType = "Post-paid"
                                    }
                                    
                                    OfferingRadioButton(title: "Pre-paid", isSelected: paymentType == "Pre-paid") {
                                        paymentType = "Pre-paid"
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                            .background(Color.white)
                        }
                        
                        // Price / Salary / Charges / Fee Section
                        VStack(spacing: 0) {
                            // Section Header
                            HStack {
                                Text("Price / Salary / Charges / Fee")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            
                            // Fixed per
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Fixed per")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                HStack(spacing: 20) {
                                    OfferingRadioButton(title: "Unit", isSelected: fixedPer == "Unit") {
                                        fixedPer = "Unit"
                                    }
                                    
                                    OfferingRadioButton(title: "Month", isSelected: fixedPer == "Month") {
                                        fixedPer = "Month"
                                    }
                                    
                                    OfferingRadioButton(title: "Term(m)", isSelected: fixedPer == "Term(m)") {
                                        fixedPer = "Term(m)"
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                            .background(Color.white)
                            
                            // Varies by
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Varies by")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 16) {
                                        OfferingCheckboxButton(title: "Variety", isChecked: $variesByVariety)
                                        OfferingCheckboxButton(title: "Weekday", isChecked: $variesByWeekday)
                                        OfferingCheckboxButton(title: "Actuals", isChecked: $variesByActuals)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            
                            // Tax, Promotion, Purchase checkboxes
                            VStack(spacing: 12) {
                                HStack(spacing: 40) {
                                    OfferingCheckboxButton(title: "Tax", isChecked: $hasTax)
                                    OfferingCheckboxButton(title: "Promotion", isChecked: $hasPromotion)
                                    OfferingCheckboxButton(title: "Purchase", isChecked: $hasPurchase)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            
                            // Tax fields (conditional)
                            if hasTax {
                                VStack(spacing: 12) {
                                    // TAXCODE field
                                    VStack(alignment: .leading, spacing: 8) {
                                        TextField("TAXCODE", text: $taxCode)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 1)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    
                                    // Tax percentage fields
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("CGST %", text: $cgstPercentage)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("SGST %", text: $sgstPercentage)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("IGST %", text: $igstPercentage)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                }
                                .background(Color.white)
                            }
                            
                            // Net sell field
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Net sell", text: $netSell)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Weekday pricing fields (conditional)
                            if variesByWeekday {
                                VStack(spacing: 8) {
                                    // First row of weekdays
                                    HStack(spacing: 8) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Mon")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            TextField("", text: $mondayPrice)
                                                .font(.body)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Tue")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            TextField("", text: $tuesdayPrice)
                                                .font(.body)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Wed")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            TextField("", text: $wednesdayPrice)
                                                .font(.body)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Thu")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            TextField("", text: $thursdayPrice)
                                                .font(.body)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    // Second row of weekdays
                                    HStack(spacing: 8) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Fri")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            TextField("", text: $fridayPrice)
                                                .font(.body)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Sat")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            TextField("", text: $saturdayPrice)
                                                .font(.body)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Sun")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            TextField("", text: $sundayPrice)
                                                .font(.body)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }                            // Service charge field
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Service charge", text: $serviceCharge)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Base (before tax) section (conditional - appears when both Tax and Weekday are enabled)
                            if hasTax && variesByWeekday {
                                VStack(spacing: 0) {
                                    // Base section header
                                    HStack {
                                        Text("Base (before tax)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    
                                    // Base weekday pricing fields
                                    VStack(spacing: 8) {
                                        // First row of weekdays for base pricing
                                        HStack(spacing: 8) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Mon")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                TextField("", text: $baseMondayPrice)
                                                    .font(.body)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Tue")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                TextField("", text: $baseTuesdayPrice)
                                                    .font(.body)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Wed")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                TextField("", text: $baseWednesdayPrice)
                                                    .font(.body)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Thu")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                TextField("", text: $baseThursdayPrice)
                                                    .font(.body)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        
                                        // Second row of weekdays for base pricing
                                        HStack(spacing: 8) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Fri")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                TextField("", text: $baseFridayPrice)
                                                    .font(.body)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Sat")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                TextField("", text: $baseSaturdayPrice)
                                                    .font(.body)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Sun")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                TextField("", text: $baseSundayPrice)
                                                    .font(.body)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                }
                            }
                            
                            // Per order and per month fields
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    TextField("per order (on-demand)", text: $perOrderOnDemand)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    TextField("per month (subscription)", text: $perMonthSubscription)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Variety checkbox
                            VStack(spacing: 12) {
                                HStack {
                                    OfferingCheckboxButton(title: "Variety of size / colour / pack / plan", isChecked: $varietyOfSizeColourPack)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            
                            // Variety fields (conditional)
                            if varietyOfSizeColourPack {
                                VStack(spacing: 16) {
                                    // Size fields
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Size 1", text: $size1)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Size 2", text: $size2)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Size 3", text: $size3)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    // Color fields
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Colour 1", text: $colour1)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Colour 2", text: $colour2)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Colour 3", text: $colour3)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    // Pack fields
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Pack 1", text: $pack1)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Pack 2", text: $pack2)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Pack 3", text: $pack3)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    // Plan fields
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Plan 1", text: $plan1)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Plan 2", text: $plan2)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            TextField("Plan 3", text: $plan3)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            
                            // Unit field
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Unit", text: $unit)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Container and Capacity fields
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    TextField("Container", text: $container)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    TextField("Capacity (Units/Container)", text: $capacityUnitsContainer)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Item code with scan button
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    TextField("Item code / barcode (optional)", text: $itemCodeBarcode)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Button(action: {
                                        // Handle scan action
                                    }) {
                                        Text("Scan")
                                            .font(.body)
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Offering short name field
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Offering short name for prints (optional)", text: $offeringShortName)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Department section field
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Department / section (optional)", text: $departmentSection)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Online visible toggle
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Online visible")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $onlineVisible)
                                        .tint(.blue)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            
                            // Description in English field
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Description in English (Optional)", text: $descriptionEnglish)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Description in Hindi field
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Description in Hindi (Optional)", text: $descriptionHindi)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
                
                // Save Button
                Button(action: {
                    // Handle save action
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(0)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Offering Radio Button Component
struct OfferingRadioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                            .opacity(isSelected ? 1 : 0)
                    )
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Offering Checkbox Button Component
struct OfferingCheckboxButton: View {
    let title: String
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(isChecked ? Color.blue : Color.clear)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Rectangle()
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                            .opacity(isChecked ? 1 : 0)
                    )
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddOfferingDetailsView(categoryName: "Newspaper, Magazine")
}
