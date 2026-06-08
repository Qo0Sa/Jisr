//
//  CameraBackground.swift
//  testcam
//
//  Shared camera background components used by both CameraView (live feed)
//  and PhotoPreviewView (static photo). Both produce the same visual:
//  a blurred full-screen background with a clear rounded square in the center.
//

import SwiftUI
import AVFoundation

// MARK: - Shared geometry

/// Width of the viewfinder square given a screen width.
/// Matches the horizontal card padding (24 pt on each side).
func viewfinderSize(for screenWidth: CGFloat) -> CGFloat {
    screenWidth - 48
}

// MARK: - Live camera background (CameraView)

struct BlurredCameraView: UIViewRepresentable {
    let session: AVCaptureSession
    let viewfinderRect: CGRect

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> LayoutView {
        let container = LayoutView()
        container.backgroundColor = .black
        container.clipsToBounds = true

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        if let connection = previewLayer.connection,
           connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
        }
        container.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        container.addSubview(blurView)
        context.coordinator.blurView = blurView

        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        blurView.layer.mask = maskLayer
        context.coordinator.maskLayer = maskLayer

        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        container.addSubview(overlay)
        context.coordinator.overlay = overlay

        let coordinator = context.coordinator
        container.onLayout = { bounds in
            coordinator.updateLayout(bounds: bounds, viewfinderRect: viewfinderRect)
        }
        return container
    }

    func updateUIView(_ uiView: LayoutView, context: Context) {
        uiView.onLayout = { [coordinator = context.coordinator] bounds in
            coordinator.updateLayout(bounds: bounds, viewfinderRect: viewfinderRect)
        }
        if uiView.bounds != .zero {
            context.coordinator.updateLayout(bounds: uiView.bounds, viewfinderRect: viewfinderRect)
        }
    }

    class LayoutView: UIView {
        var onLayout: ((CGRect) -> Void)?
        override func layoutSubviews() {
            super.layoutSubviews()
            onLayout?(bounds)
        }
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
        var blurView: UIVisualEffectView?
        var maskLayer: CAShapeLayer?
        var overlay: UIView?

        func updateLayout(bounds: CGRect, viewfinderRect: CGRect) {
            previewLayer?.frame = bounds
            blurView?.frame = bounds
            overlay?.frame = bounds

            let fullPath = UIBezierPath(rect: bounds)
            let hole = UIBezierPath(roundedRect: viewfinderRect, cornerRadius: 20)
            fullPath.append(hole)
            fullPath.usesEvenOddFillRule = true
            maskLayer?.path = fullPath.cgPath
        }
    }
}

// MARK: - Static photo background (PhotoPreviewView)

/// Mirrors the camera view's look for a captured photo:
/// blurred full-screen image with a clear rounded square showing
/// exactly what was visible inside the viewfinder when the shot was taken.
struct PhotoBackground: View {
    let image: UIImage
    @State private var cropped: UIImage?

    var body: some View {
        GeometryReader { geo in
            let sqSize = viewfinderSize(for: geo.size.width)

            ZStack {
                // Blurred full-frame background
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .blur(radius: 22)
                    .overlay(Color.black.opacity(0.28))

                // Clear viewfinder crop, centered
                if let cropped {
                    Image(uiImage: cropped)
                        .resizable()
                        .scaledToFill()
                        .frame(width: sqSize, height: sqSize)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
            .onAppear {
                let size = geo.size
                Task.detached(priority: .userInitiated) {
                    let result = cropToViewfinder(image: image, screenSize: size)
                    await MainActor.run { cropped = result }
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Crop helper

/// Crops `image` to the region that was visible inside the camera viewfinder
/// when the photo was taken, accounting for the preview layer's resizeAspectFill mapping.
func cropToViewfinder(image: UIImage, screenSize: CGSize) -> UIImage {
    let imgSize = image.size  // Respects imageOrientation; scale=1 for camera photos
    let squarePts = screenSize.width - 48
    let imgAspect = imgSize.width / imgSize.height
    let scrAspect = screenSize.width / screenSize.height

    // Replicate resizeAspectFill: which dimension drives the scale?
    let scale: CGFloat
    var offX: CGFloat = 0
    var offY: CGFloat = 0

    if imgAspect > scrAspect {
        // Image wider than screen → scale by height, crop left/right
        scale = imgSize.height / screenSize.height
        offX = (imgSize.width - screenSize.width * scale) / 2
    } else {
        // Image taller than screen → scale by width, crop top/bottom
        scale = imgSize.width / screenSize.width
        offY = (imgSize.height - screenSize.height * scale) / 2
    }

    // Viewfinder square in image pixel space
    let cropX = offX + 24 * scale
    let cropY = offY + (screenSize.height - squarePts) / 2 * scale
    let cropSz = squarePts * scale

    // Render the crop — image.draw respects imageOrientation automatically
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let renderer = UIGraphicsImageRenderer(
        size: CGSize(width: cropSz, height: cropSz),
        format: format
    )
    return renderer.image { _ in
        image.draw(at: CGPoint(x: -cropX, y: -cropY))
    }
}
