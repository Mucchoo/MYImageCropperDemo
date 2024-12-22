//
//  ImageCropView.swift
//  SwiftUIImageCropper
//
//  Created by Musa Yazici on 12/22/24.
//

import SwiftUI

struct ImageCropView: View {
    @StateObject private var viewModel: ImageCropViewModel

    init(viewModel: ImageCropViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFit()
                .scaleEffect(viewModel.scale)
                .offset(viewModel.offset)
                .opacity(0.5)

            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFit()
                .scaleEffect(viewModel.scale)
                .offset(viewModel.offset)
                .mask(
                    Rectangle()
                        .frame(width: viewModel.maskSize.width, height: viewModel.maskSize.height)
                )

            VStack {
                Text("Select Crop Area")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 100)
                    .foregroundStyle(Color.white)

                Spacer()

                HStack {
                    Button {
                        viewModel.onCancelButton()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.white)
                    }

                    Spacer()

                    Button {
                        viewModel.onSaveButton()
                    } label: {
                        Text("Save").font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
                .padding(40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .contentShape(Rectangle())
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    viewModel.magnify(value.magnitude)
                }
                .onEnded { _ in
                    viewModel.updateLastValues()
                }
        )
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    viewModel.drag(value.translation)
                }
                .onEnded { _ in
                    viewModel.updateLastValues()
                }
        )
    }
}
