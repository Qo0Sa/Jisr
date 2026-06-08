//  BridgeView.swift
//  Jisr
//  Created by Sarah Alnasser on 10/05/2026.
//  All views for the Model page: ModelPage, NoLayersPopup, BuildingSceneView.
//  جميع واجهات صفحة الجسر

import SwiftUI
import SceneKit

// MARK: - ModelPage الصفحة الرئيسية للجسر

// Main page that shows the 3D bridge model and the user's building progress.
struct ModelPage: View {

    @EnvironmentObject var state: LayerState
    @Environment(\.dismiss) private var dismiss

    @State private var showNoLayersPopup = false

    var body: some View {
        ZStack(alignment: .bottom) {

            Color("Backgroundcolor").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // MARK: Navigation Header

                HStack {
                    // Back button matching ProfileView style | زر الرجوع بنفس أسلوب ProfileView
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("buttonColor"))
                    }

                    Spacer()

                    Text("Golden Gate Bridge")
                        .font(.custom("Ubuntu-Bold", size: 22))
                        .foregroundColor(Color("buttonColor"))

                    Spacer()

                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Progress Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("you have built using \(state.layerCount) \rrooms")
                        .font(.custom("Ubuntu-Bold", size: 18))
                        .foregroundColor(Color("buttonColor"))

                    // Motivational message from ViewModel
                    Text(state.motivationalText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color("buttonColor"))
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // MARK: 3D Model

                BuildingSceneView(layerCount: state.layerCount)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Spacer().frame(height: 100)
            }

            // MARK: Bottom Progress Bar

            ProgressBarCard(layerCount: state.layerCount, maxLayers: LayerState.maxLayers)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Show popup if user has no layers yet
            if state.layerCount == 0 { showNoLayersPopup = true }
        }
        .overlay {
            if showNoLayersPopup {
                NoLayersPopup(isPresented: $showNoLayersPopup)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: showNoLayersPopup)
            }
        }
    }
}

// MARK: - ProgressBarCard

// Bottom card showing segmented progress bar and layer count.
private struct ProgressBarCard: View {
    let layerCount: Int
    let maxLayers: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("building progress")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color("buttonColor"))

            HStack(alignment: .center, spacing: 12) {
                GeometryReader { geo in
                    let segmentSpacing: CGFloat = 3
                    let segmentWidth = (geo.size.width - segmentSpacing * CGFloat(maxLayers - 1)) / CGFloat(maxLayers)
                    let filledWidth  = segmentWidth * CGFloat(layerCount) + segmentSpacing * CGFloat(max(layerCount - 1, 0))

                    ZStack(alignment: .leading) {
                        // Empty segment track
                        HStack(spacing: segmentSpacing) {
                            ForEach(1...maxLayers, id: \.self) { _ in
                                Capsule()
                                    .fill(Color("gray20"))
                                    .frame(width: segmentWidth, height: 8)
                            }
                        }

                        // Filled bar that grows with progress
                        if layerCount > 0 {
                            Capsule()
                                .fill(Color("buttonColor"))
                                .frame(width: filledWidth, height: 8)
                        }
                    }
                }
                .frame(height: 8)

                Text("\(layerCount)/\(maxLayers)")
                    .font(.custom("Ubuntu-Bold", size: 22))
                    .foregroundColor(Color("buttonColor"))
                    .fixedSize()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color("fieldColor"), in: RoundedRectangle(cornerRadius: 16))
        .compositingGroup()
        .shadow(color: Color("buttonColor").opacity(0.9), radius: 0, x: 0, y: 6)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - NoLayersPopup

// Popup shown when the user hasn't earned any layers yet.
struct NoLayersPopup: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("No layers yet!")
                        .font(.UbuntuBold(size: 22))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text("Complete rooms with your friends to earn layers and start building your bridge")
                        .font(.Ubuntu(size: 15))
                        .foregroundColor(.black.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.top, 10)

                Button(action: { isPresented = false }) {
                    Text("Got it!")
                        .font(.UbuntuBold(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 99))
                }
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding(.horizontal, 36)
            .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 12)
        }
    }
}

// MARK: - BuildingSceneView | واجهة النموذج ثلاثي الأبعاد

// SceneKit view that renders the 3D bridge model and supports left/right drag rotation.
struct BuildingSceneView: UIViewRepresentable {

    var layerCount: Int

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {

        // MARK: Scene Setup
        let scnView = SCNView(frame: .zero)
        scnView.backgroundColor = .clear
        scnView.isOpaque = false
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = false   // rotation is handled by our gesture

        let scene = SCNScene()
        scnView.scene = scene

        guard let modelScene = SCNScene(named: "Jisr3Dv2.usdz") else {
            print("Failed to load Jisr3D.usdz | فشل تحميل النموذج")
            return scnView
        }

        // MARK: Node Hierarchy | تسلسل العقد
        //
        //  scene.rootNode
        //    └── rotationNode   ← user drag rotates this around Y | يدور بإيماءة المستخدم حول محور Y
        //          └── orientedNode  ← fixes Z-up USDZ to Y-up SceneKit | يصحح اتجاه الملف من Z-up إلى Y-up
        //                └── modelNode  ← raw USDZ geometry | هندسة USDZ الخام

        // Move all USDZ children into modelNode
        let modelNode = SCNNode()
        for child in modelScene.rootNode.childNodes {
            child.removeFromParentNode()
            modelNode.addChildNode(child)
        }

        // Center the model at its own origin using bounding box (computed in Z-up space)
        let (minVec, maxVec) = modelNode.boundingBox
        let center = SCNVector3(
            (minVec.x + maxVec.x) / 2,
            (minVec.y + maxVec.y) / 2,
            (minVec.z + maxVec.z) / 2
        )
        let maxDimension = max(maxVec.x - minVec.x, maxVec.y - minVec.y, maxVec.z - minVec.z)
        modelNode.position = SCNVector3(-center.x, -center.y, -center.z)

        // Rotate -90° on X to convert the USDZ's Z-up axis to SceneKit's Y-up axis
        let orientedNode = SCNNode()
        orientedNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        orientedNode.addChildNode(modelNode)

        // Wrapper node — only this rotates when the user swipes
        let rotationNode = SCNNode()
        rotationNode.addChildNode(orientedNode)
        scene.rootNode.addChildNode(rotationNode)

        // MARK: Camera

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 60

        // Position camera elevated and in front for a nice perspective view
        let fovRad   = Float(60) * Float.pi / 180
        let distance = (maxDimension / 2) / tan(fovRad / 2) * 1.6
        cameraNode.position = SCNVector3(0, distance * 0.4, distance)

        // Keep camera pointed at the model center regardless of position
        let lookAt = SCNLookAtConstraint(target: rotationNode)
        lookAt.isGimbalLockEnabled = true
        cameraNode.constraints = [lookAt]

        scene.rootNode.addChildNode(cameraNode)
        scnView.pointOfView = cameraNode

        // MARK: Layers | الطبقات

        // Find each named layer node and set initial visibility
        for i in 1...LayerState.maxLayers {
            let name = "layer_\(i)"
            if let layer = modelNode.childNode(withName: name, recursively: true) {
                context.coordinator.layers[i] = layer
                context.coordinator.originalPositions[i] = layer.position
                layer.isHidden = i > layerCount
            }
        }

        // Ground is always visible
        modelNode.childNode(withName: "ground", recursively: true)?.isHidden = false

        context.coordinator.rotationNode = rotationNode
        context.coordinator.currentLayerCount = layerCount

        // MARK: Gesture

        // Pan gesture for left/right model rotation
        let pan = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        scnView.addGestureRecognizer(pan)

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        context.coordinator.updateLayers(to: layerCount)
    }

    // MARK: - Coordinator | المنسق

    // Handles gesture-driven rotation and animated layer transitions.
    class Coordinator: NSObject {

        var layers: [Int: SCNNode] = [:]
        var originalPositions: [Int: SCNVector3] = [:]
        var currentLayerCount: Int = 0
        var rotationNode: SCNNode?

        private var lastPanX: CGFloat = 0

        // MARK: Rotation

        // Rotates the model around the Y axis as the user drags horizontally.
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            if gesture.state == .began { lastPanX = 0 }
            let translation = gesture.translation(in: gesture.view)
            let delta = Float(translation.x - lastPanX) * 0.008   // sensitivity
            lastPanX = translation.x
            rotationNode?.eulerAngles.y += delta
        }

        // MARK: Layer Animation

        // Shows or hides a single layer with a drop-in / drop-out animation.
        func updateLayers(to newCount: Int) {
            guard newCount != currentLayerCount else { return }

            if newCount > currentLayerCount {
                // Drop the new layer in from above
                let index = newCount
                if let layer = layers[index], let original = originalPositions[index] {
                    layer.isHidden = false
                    layer.position = SCNVector3(original.x, original.y + 0.2, original.z)
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.4
                    SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    layer.position = original
                    SCNTransaction.commit()
                }
            } else {
                // Drop the removed layer out downward
                let index = currentLayerCount
                if let layer = layers[index], let original = originalPositions[index] {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.4
                    SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    SCNTransaction.completionBlock = {
                        layer.isHidden = true
                        layer.position = original
                    }
                    layer.position = SCNVector3(original.x, original.y - 0.2, original.z)
                    SCNTransaction.commit()
                }
            }

            currentLayerCount = newCount
        }
    }
}

// MARK: - Preview

#Preview("18 layers (complete)") {
    NavigationStack {
        ModelPage()
            .environmentObject({ let s = LayerState(); s.layerCount = 18; return s }())
    }
}
