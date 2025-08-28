//
//  PhotoUploadView.swift
//  ratibPal
//
//  Created by AI Assistant on 28/08/25.
//

import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @ObservedObject var registrationManager: RegistrationFlowManager
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                HStack {
                    Button(action: {
                        registrationManager.previousStep()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Photo ID Upload")
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await registrationManager.skipPhotoID()
                        }
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                // Progress indicator
                ProgressView(value: 0.8)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 4)
            }
            .padding()
            
            Spacer()
            
            // Content
            VStack(spacing: 30) {
                // Icon
                Image(systemName: "doc.text.image")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                // Title and description
                VStack(spacing: 15) {
                    Text("Upload Photo ID")
                        .font(.title2)
                        .bold()
                    
                    Text("Please upload a clear photo of your ID document (Aadhaar, PAN, Driving License, etc.) for verification purposes.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                .padding(.horizontal, 30)
                
                // Image preview or upload area
                if let image = registrationManager.photoIDImage {
                    VStack(spacing: 15) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                        
                        Button(action: {
                            showingActionSheet = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Change Photo")
                            }
                            .foregroundColor(.blue)
                            .font(.subheadline)
                        }
                    }
                } else {
                    Button(action: {
                        showingActionSheet = true
                    }) {
                        VStack(spacing: 15) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                            
                            Text("Take Photo or Choose from Gallery")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                        )
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 15) {
                // Upload button (only show if image is selected)
                if registrationManager.photoIDImage != nil {
                    Button(action: {
                        Task {
                            await registrationManager.uploadPhotoID()
                        }
                    }) {
                        HStack {
                            if registrationManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Uploading...")
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "cloud.upload.fill")
                                Text("Upload Photo ID")
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .disabled(registrationManager.isLoading)
                }
                
                // Skip button
                Button(action: {
                    Task {
                        await registrationManager.skipPhotoID()
                    }
                }) {
                    Text(registrationManager.photoIDImage != nil ? "Skip for Now" : "Skip Photo Upload")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                .disabled(registrationManager.isLoading)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .toolbar(.hidden, for: .navigationBar)
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Select Photo"),
                buttons: [
                    .default(Text("Take Photo")) {
                        sourceType = .camera
                        showingImagePicker = true
                    },
                    .default(Text("Choose from Gallery")) {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(
                sourceType: sourceType,
                selectedImage: $registrationManager.photoIDImage
            )
        }
    }
}

#Preview {
    NavigationView {
        PhotoUploadView(registrationManager: RegistrationFlowManager())
    }
}
