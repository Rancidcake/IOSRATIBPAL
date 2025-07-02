import SwiftUI

struct CustomerDetail: Identifiable {
    let id = UUID()
    let name: String
    let phone: String
    let address: String
    let group: String
    let affiliate: String
}

struct RecurrenceOption: Identifiable {
    let id = UUID()
    let title: String
    var isSelected: Bool
}

struct AddCustomerView: View {
    @Environment(\.dismiss) private var dismiss
    let groups: [String]
    let affiliates: [String]
    let onCreate: (CustomerDetail) -> Void

    @State private var inlineSelection = "Default line"
    @State private var belowSelection = "Test"
    @State private var nickname = ""
    @State private var mobileNumber = ""
    @State private var addFollowingOrder = false
    @State private var offeringSelection = ""
    @State private var count = 1
    @State private var slotSelection = "AM"
    @State private var deliveryAtSelection = "Doorstep"
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var subscribe = false
    @State private var deliveredTillToday = false
    @State private var recurrenceType = "Calendar"
    @State private var everyValue = 1
    @State private var recurrenceUnit = "Day"
    @State private var weekdays: [RecurrenceOption] = ["S","M","T","W","T","F","S"].map { RecurrenceOption(title: $0, isSelected: false) }
    @State private var sellPrice = ""
    @State private var variance = ""
    @State private var orderPrice = ""
    @State private var charges = ""
    @State private var defaultQuantity = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Inline / Below
                    HStack {
                        Picker("Inline", selection: $inlineSelection) {
                            Text(inlineSelection).tag(inlineSelection)
                        }
                        .pickerStyle(MenuPickerStyle())
                        Spacer()
                        Picker("Below", selection: $belowSelection) {
                            Text(belowSelection).tag(belowSelection)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    // Nickname
                    HStack {
                        TextField("Nickname (House / shop)", text: $nickname)
                        Image(systemName: "lock.fill").foregroundColor(.gray)
                    }
                    .padding(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))

                    // Mobile & ERP
                    HStack {
                        TextField("Mobile Number", text: $mobileNumber).keyboardType(.phonePad)
                        Text("ERP user id").foregroundColor(.secondary)
                    }
                    .padding(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))

                    Toggle("Add following order", isOn: $addFollowingOrder)

                    // Offering & count
                    HStack {
                        Picker("Offering", selection: $offeringSelection) {
                            Text("Select").tag("")
                        }
                        .pickerStyle(MenuPickerStyle())
                        Spacer()
                        HStack(spacing: 8) {
                            Button(action: { if count>1 { count-=1 } }) {
                                Image(systemName: "minus.circle")
                            }
                            Text("\(count)")
                            Button(action: { count+=1 }) {
                                Image(systemName: "plus.circle")
                            }
                        }
                    }

                    // Slot & Delivery
                    HStack(spacing: 12) {
                        ForEach(["AM","Noon","PM","Always","ASAP"], id: \.self) { slot in
                            RadioButton(label: slot, selected: slotSelection==slot) { slotSelection = slot }
                        }
                    }
                    HStack(spacing: 12) {
                        ForEach(["Doorstep","Pickup","In store"], id: \.self) { opt in
                            RadioButton(label: opt, selected: deliveryAtSelection==opt) { deliveryAtSelection=opt }
                        }
                    }

                    // Dates
                    HStack {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date (Optional)", selection: $endDate, displayedComponents: .date)
                    }

                    Toggle("Subscribe", isOn: $subscribe)
                    Toggle("Delivered till today", isOn: $deliveredTillToday)

                    // Recurrence
                    VStack(alignment: .leading) {
                        Text("Recurrence")
                        Picker("", selection: $recurrenceType) {
                            Text("Calendar").tag("Calendar")
                            Text("Service plan").tag("Service plan")
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        HStack {
                            Stepper("Every \(everyValue)", value: $everyValue, in: 1...12)
                            Picker("Unit", selection: $recurrenceUnit) {
                                ForEach(["Day","Week","Month","Year"], id: \.self) { Text($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }

                        HStack(spacing: 12) {
                            ForEach($weekdays) { $day in
                                Button(action: { day.isSelected.toggle() }) {
                                    Text(day.title)
                                        .frame(width:24, height:24)
                                        .background(day.isSelected ? Color.blue : Color.clear)
                                        .clipShape(Circle())
                                        .foregroundColor(day.isSelected ? .white : .primary)
                                }
                            }
                        }
                    }

                    // Pricing + defaults
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            PriceField(placeholder: "Sell Price ₹ per unit", text: $sellPrice)
                            PriceField(placeholder: "+/- Variance ₹", text: $variance)
                        }
                        HStack {
                            PriceField(placeholder: "Order price ₹", text: $orderPrice)
                            PriceField(placeholder: "Charges ₹", text: $charges)
                        }
                        HStack {
                            PriceField(placeholder: "Default quantity", text: $defaultQuantity)
                        }
                        // Footer labels
                        HStack {
                            FooterLabel(text: "Holidays / month")
                            Spacer()
                            FooterLabel(text: "Deposit ₹")
                            Spacer()
                            FooterLabel(text: "Service charge ₹")
                        }
                    }

                    // Save
                    Button("Save") {
                        let newCustomer = CustomerDetail(name: nickname, phone: mobileNumber, address: "", group: inlineSelection, affiliate: belowSelection)
                        onCreate(newCustomer)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Add New Customer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } } }
        }
    }
}

// MARK: - Reusable Components
struct RadioButton: View {
    let label: String
    let selected: Bool
    let action: ()->Void
    var body: some View {
        Button(action: action) {
            HStack { Circle().stroke(selected ? Color.blue : Color.gray, lineWidth: 2).frame(width: 20, height: 20)
                     Text(label)
            }
        }
        .foregroundColor(.primary)
    }
}

struct PriceField: View {
    let placeholder: String
    @Binding var text: String
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(.decimalPad)
            .padding(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
    }
}

struct FooterLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

struct AddCustomerView_Previews: PreviewProvider {
    static var previews: some View {
        AddCustomerView(groups: ["G1"], affiliates: ["A1"]) { _ in }
    }
}
