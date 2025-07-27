//
//  SideMenuView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var showSideMenu: Bool
    @Binding var showSettings: Bool
    @Binding var showPointOfSale: Bool
    @Binding var showFieldTeamTracker: Bool
    
    private let menuItems = [
        ("point.topleft.down.curvedto.point.bottomright.up", "Point of Sale"),
        ("person.2", "Field team tracker"),
        ("gearshape", "Settings"),
        ("rectangle.portrait.and.arrow.right", "Logout")
    ]
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showSideMenu = false
                    }
                }
            
            // Side menu
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    // User Profile Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            // User Avatar
                            ZStack {
                                Circle()
                                    .fill(.blue.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                
                                Text("S")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                        }
                        
                        Text("Mayank Hete")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                    
                    // Supply chain section header
                    Text("Supply chain")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                    
                    // Menu Items
                    VStack(spacing: 0) {
                        ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                            Button(action: {
                                handleMenuAction(for: item.1)
                            }) {
                                HStack(spacing: 15) {
                                    Image(systemName: item.0)
                                        .font(.system(size: 18))
                                        .foregroundColor(.primary)
                                        .frame(width: 25)
                                    
                                    Text(item.1)
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if index < menuItems.count - 1 {
                                Divider()
                                    .padding(.leading, 65)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: 280)
                .background(Color(.systemBackground))
                .shadow(radius: 10)
                .offset(x: showSideMenu ? 0 : -280)
                .animation(.easeInOut(duration: 0.3), value: showSideMenu)
                
                Spacer()
            }
        }
    }
    
    private func handleMenuAction(for item: String) {
        print("DEBUG: Menu item tapped: \(item)")
        withAnimation {
            showSideMenu = false
        }
        
        switch item {
        case "Settings":
            print("DEBUG: Opening Settings")
            showSettings = true
        case "Logout":
            // Handle logout
            print("Logout tapped")
        case "Point of Sale":
            print("DEBUG: Opening Point of Sale")
            showPointOfSale = true
        case "Field team tracker":
            print("DEBUG: Opening Field Team Tracker")
            showFieldTeamTracker = true
        default:
            print("DEBUG: Unknown menu item: \(item)")
            break
        }
    }
}