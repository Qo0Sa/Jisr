//
//  BridgeView.swift
//  aaa
//
//  Created by Sarah Alnasser on 10/05/2026.
//

import SwiftUI
import RealityKit
import Combine

final class LayerState: ObservableObject {
    @Published var layerCount: Int {
        didSet { UserDefaults.standard.set(layerCount, forKey: "layerCount") }
    }

    private let lastAddedKey    = "lastLayerAddedDate"
    private let creditedRoomsKey = "creditedRoomCodes"
    private let expiryInterval: TimeInterval = 3 * 24 * 3600

    init() {
        self.layerCount = UserDefaults.standard.integer(forKey: "layerCount")
        checkWeeklyExpiry(maxLayers: 18)
    }

    // Called whenever rooms change — credits each completed room exactly once
    func syncWithRooms(_ rooms: [Room], maxLayers: Int) {
        var credited = Set(UserDefaults.standard.stringArray(forKey: creditedRoomsKey) ?? [])
        var changed = false

        for room in rooms {
            let photoCount = room.photos?.count ?? 0
            guard room.maxPhotos > 0,
                  photoCount >= room.maxPhotos,
                  !credited.contains(room.code) else { continue }

            if layerCount < maxLayers {
                layerCount += 1
                UserDefaults.standard.set(Date(), forKey: lastAddedKey)
            }
            credited.insert(room.code)
            changed = true
        }

        if changed {
            UserDefaults.standard.set(Array(credited), forKey: creditedRoomsKey)
        }
    }

    func checkWeeklyExpiry(maxLayers: Int) {
        guard layerCount > 0, layerCount < maxLayers else { return }
        guard let lastDate = UserDefaults.standard.object(forKey: lastAddedKey) as? Date else {
            UserDefaults.standard.set(Date(), forKey: lastAddedKey)
            return
        }
        if Date().timeIntervalSince(lastDate) >= expiryInterval {
            layerCount = Swift.max(0, layerCount - 1)
            UserDefaults.standard.set(Date(), forKey: lastAddedKey)
        }
    }
}

struct ModelPage: View {
    @EnvironmentObject var state: LayerState
    private let maxLayers = 18

    var motivationalText: String {
        switch state.layerCount {
        case 0: return "Start building!"
        case 1...4: return "Great start!"
        case 5...11: return "Keep up the good work!"
        case 12...17: return "Almost there!"
        default: return "You did it!"
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Backgroundcolor")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header text
                VStack(alignment: .leading, spacing: 4) {
                    Text("you have built using \(state.layerCount) \rrooms")
                        .font(.custom("Ubuntu-Bold", size: 18))
                        .foregroundColor(Color("buttonColor"))
                    Text(motivationalText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color("buttonColor"))
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // 3D model
                BuildingRealityView(layerCount: state.layerCount)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Spacer for bottom bar
                Spacer().frame(height: 100)
            }

            // Bottom progress bar
            VStack(alignment: .leading, spacing: 8) {
                Text("building progress")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color("buttonColor"))

                HStack(alignment: .center, spacing: 12) {
                    GeometryReader { geo in
                        let spacing: CGFloat = 3
                        let totalSpacing = spacing * CGFloat(maxLayers - 1)
                        let segmentWidth = (geo.size.width - totalSpacing) / CGFloat(maxLayers)
                        let filledWidth = segmentWidth * CGFloat(state.layerCount) + spacing * CGFloat(max(state.layerCount - 1, 0))

                        ZStack(alignment: .leading) {
                            // Empty segments
                            HStack(spacing: spacing) {
                                ForEach(1...maxLayers, id: \.self) { _ in
                                    Capsule()
                                        .fill(Color("gray20"))
                                        .frame(width: segmentWidth, height: 8)
                                }
                            }
                            // Single connected filled bar
                            if state.layerCount > 0 {
                                Capsule()
                                    .fill(Color("buttonColor"))
                                    .frame(width: filledWidth, height: 8)
                            }
                        }
                    }
                    .frame(height: 8)

                    Text("\(state.layerCount)/\(maxLayers)")
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Golden Gate Bridge")
                    .font(.custom("Ubuntu-Bold", size: 22))
                    .foregroundColor(Color("buttonColor"))
            }
        }
    }
}

struct BuildingRealityView: UIViewRepresentable {
    var layerCount: Int

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.environment.background = .color(.clear)
        arView.backgroundColor = .clear
        arView.isOpaque = false

        let anchor = AnchorEntity(world: [0, 0, -2.8])
        arView.scene.addAnchor(anchor)

        do {
            let building = try Entity.load(named: "Jisr3D")
            building.scale = [0.3, 0.3, 0.3]
            building.orientation *= simd_quatf(angle: +.pi / 18, axis: [1, 0, 0])
            anchor.addChild(building)

            context.coordinator.building = building

            for i in 1...18 {
                let name = "layer_\(i)"
                if let layer = building.findEntity(named: name) {
                    context.coordinator.layers[i] = layer
                    context.coordinator.originalTransforms[i] = layer.transform
                    layer.isEnabled = i <= layerCount
                } else {
                    print("Layer not found: \(name)")
                }
            }

            // ground stays visible all the time
            if let ground = building.findEntity(named: "ground") {
                ground.isEnabled = true
            }

            context.coordinator.currentLayerCount = layerCount

        } catch {
            print("Failed to load model: \(error)")
        }

        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {
        context.coordinator.updateLayers(to: layerCount)
    }

    class Coordinator: NSObject {
        var building: Entity?
        var layers: [Int: Entity] = [:]
        var originalTransforms: [Int: Transform] = [:]
        var currentLayerCount: Int = 1

        func updateLayers(to newCount: Int) {
            guard newCount != currentLayerCount else { return }

            if newCount > currentLayerCount {
                let addedLayer = newCount
                if let layer = layers[addedLayer],
                   let original = originalTransforms[addedLayer] {
                    layer.isEnabled = true
                    var startTransform = original
                    startTransform.translation.y += 0.2
                    layer.transform = startTransform
                    layer.move(
                        to: original,
                        relativeTo: layer.parent,
                        duration: 0.4,
                        timingFunction: .easeInOut
                    )
                }
            } else {
                let removedLayer = currentLayerCount
                if let layer = layers[removedLayer],
                   let original = originalTransforms[removedLayer] {
                    var downTransform = original
                    downTransform.translation.y -= 0.2
                    layer.move(
                        to: downTransform,
                        relativeTo: layer.parent,
                        duration: 0.4,
                        timingFunction: .easeInOut
                    )
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        layer.isEnabled = false
                        layer.transform = original
                    }
                }
            }

            currentLayerCount = newCount
        }
    }
}

#Preview("0 layers") {
    NavigationStack {
        ModelPage()
            .environmentObject({ let s = LayerState(); s.layerCount = 0; return s }())
    }
}

#Preview("5 layers") {
    NavigationStack {
        ModelPage()
            .environmentObject({ let s = LayerState(); s.layerCount = 5; return s }())
    }
}

#Preview("18 layers (complete)") {
    NavigationStack {
        ModelPage()
            .environmentObject({ let s = LayerState(); s.layerCount = 18; return s }())
    }
}
