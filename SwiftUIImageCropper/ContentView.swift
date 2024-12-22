//
//  ContentView.swift
//  SwiftUIImageCropper
//
//  Created by Musa Yazici on 12/22/24.
//

import SwiftUI
import MYImageCropper

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var croppedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isImageCropperPresented = false
    
    var body: some View {
        VStack {
            if let croppedImage {
                Image(uiImage: croppedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
            } else if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .background(Color.gray.opacity(0.3))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 300)
            }
            
            Button {
                isImagePickerPresented = true
            } label: {
                Text("Pick an image")
                    .frame(maxWidth: .infinity)
                    .font(.title)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(20)
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage, isPresented: $isImagePickerPresented, isImageCropperPresented: $isImageCropperPresented)
        }
        .fullScreenCover(isPresented: $isImageCropperPresented) {
            if let image = selectedImage {
                ImageCropView(viewModel: ImageCropViewModel(
                    image: image,
                    type: .square,
                    ondismiss: {
                        isImageCropperPresented = false
                    },
                    onSave: { croppedImage in
                        if let croppedImage {
                            selectedImage = croppedImage
                        }
                        isImageCropperPresented = false
                    }
                ))
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    ContentView()
}
