//
//  ImageCropViewModel.swift
//  SwiftUIImageCropper
//
//  Created by Musa Yazici on 12/22/24.
//


import UIKit
import CoreGraphics

class ImageCropViewModel: ObservableObject {
    
    let image: UIImage
    private let type: ImageAspectRatioType
    private let imageSize: CGSize
    private let onDismiss: () -> Void
    private let onSave: (UIImage?) -> Void

    @Published private(set) var maskSize: CGSize = .zero
    @Published private(set) var scale: CGFloat = 1.0
    @Published private(set) var lastScale: CGFloat = 1.0
    @Published private(set) var offset: CGSize = .zero
    @Published private(set) var lastOffset: CGSize = .zero
    
    init(
        image: UIImage,
        type: ImageAspectRatioType,
        ondismiss: @escaping () -> Void,
        onSave: @escaping (UIImage?) -> Void
    ) {
        self.image = image
        self.type = type
        self.onDismiss = ondismiss
        self.onSave = onSave
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let screenWidth = UIScreen.main.bounds.width
        let displayHeight = (screenWidth * imageHeight) / imageWidth
        self.imageSize = CGSize(width: screenWidth, height: displayHeight)

        if imageSize.width / imageSize.height > type.aspectRatio {
            let height = imageSize.height
            let width = height * type.aspectRatio
            maskSize = CGSize(width: width, height: height)
        } else {
            let width = imageSize.width
            let height = width / type.aspectRatio
            maskSize = CGSize(width: width, height: height)
        }
    }

    private func maxX() -> CGFloat { (imageSize.width * scale - maskSize.width) * 0.5 }
    private func minX() -> CGFloat { (imageSize.width * scale - maskSize.width) * -0.5 }
    private func maxY() -> CGFloat { (imageSize.height * scale - maskSize.height) * 0.5 }
    private func minY() -> CGFloat { (imageSize.height * scale - maskSize.height) * -0.5 }

    func magnify(_ magnitude: CGFloat) {
        scale = min(max(
            magnitude * lastScale, max(
                maskSize.width / imageSize.width,
                maskSize.height / imageSize.height
            )
        ), 4.0)
        offset = constrainPositionToAllowedArea(x: offset.width, y: offset.height)
        lastOffset = offset
    }

    func drag(_ translation: CGSize) {
        let newX = translation.width + lastOffset.width
        let newY = translation.height + lastOffset.height
        offset  = constrainPositionToAllowedArea(x: newX, y: newY)
    }

    private func constrainPositionToAllowedArea(x: CGFloat, y: CGFloat) -> CGSize {
        var newX = x
        var newY = y

        if newX > maxX() {
            newX = maxX()
        } else if newX < minX() {
            newX = minX()
        }

        if newY > maxY() {
            newY = maxY()
        } else if newY < minY() {
            newY = minY()
        }

        return CGSize(width: newX, height: newY)
    }

    func updateLastValues() {
        lastScale = scale
        lastOffset = offset
    }

    func onCancelButton() {
        onDismiss()
    }
    
    func onSaveButton() {
        let croppedImage = crop(image)
        onSave(croppedImage)
    }

    /// Crops the input image based on the current view's mask size, scale, and offset.
    ///
    /// This function handles the following operations:
    /// 1. Corrects the image orientation
    /// 2. Calculates the actual crop dimensions accounting for resolution differences
    /// 3. Determines the crop position based on center point and offset
    /// 4. Performs the actual image cropping
    ///
    /// - Parameters:
    ///   - image: The source UIImage to be cropped
    ///   - imageSize: The size of the image as displayed in the view
    ///   - maskSize: The size of the mask/crop area in the view
    ///   - scale: The current zoom scale factor
    ///   - offset: The offset from the center position in the view
    ///
    /// - Returns: A cropped UIImage, or nil if cropping fails
    private func crop(_ image: UIImage) -> UIImage? {
        // Ensure image is correctly oriented
        guard let upwardImage = image.upwardOriented else { return nil }

        // Calculate resolution difference between file size and display size
        // This factor is used to convert view coordinates to image coordinates
        let resolutionFactor = upwardImage.size.width / imageSize.width

        // Calculate the center point of the image
        // This serves as the reference point for crop positioning
        let center = CGPoint(x: upwardImage.size.width / 2, y: upwardImage.size.height / 2)

        // Calculate the actual crop size in image coordinates
        // 1. Convert mask size from view coordinates to image coordinates using resolutionFactor
        // 2. Adjust for current zoom scale to get final crop dimensions
        let cropSize = CGSize(
            width: (maskSize.width * resolutionFactor) / scale,
            height: (maskSize.height * resolutionFactor) / scale
        )

        // Calculate the starting point for cropping
        // 1. Convert view offset to image coordinates
        // 2. Adjust center point by crop size and offset to get top-left origin
        let offsetX = offset.width * resolutionFactor / scale
        let offsetY = offset.height * resolutionFactor / scale
        let cropRectX = (center.x - cropSize.width / 2) - offsetX
        let cropRectY = (center.y - cropSize.height / 2) - offsetY

        // Perform the actual image cropping using Core Graphics
        guard let cgImage = upwardImage.cgImage,
              let result = cgImage.cropping(
                to: CGRect(
                    origin: CGPoint(x: cropRectX, y: cropRectY),
                    size: cropSize
                )
              ) else {
            return nil
        }

        return UIImage(cgImage: result)
    }
}

private extension UIImage {
    var upwardOriented: UIImage? {
        if imageOrientation == .up { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
