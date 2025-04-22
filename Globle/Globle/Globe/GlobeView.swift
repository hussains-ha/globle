//
//  GlobeView.swift
//  Globle
//
//  Created by Hussain Hassan on 4/20/25.
//

import Foundation
import SceneKit
import SwiftUI

struct GlobeView: UIViewRepresentable {
    var GlobeVM: GlobeViewModel

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()

        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .clear

        let globeNode = createGlobe()
        sceneView.scene?.rootNode.addChildNode(globeNode)
        GlobeVM.globeNode = globeNode

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 3.5)
        sceneView.scene?.rootNode.addChildNode(cameraNode)

        for node in GlobeVM.countryNodes {
            globeNode.addChildNode(node)
        }

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    func createGlobe() -> SCNNode {
        let sphere = SCNSphere(radius: 1.0)

        sphere.firstMaterial?.diffuse.contents = UIImage(named: "earth.png")
        sphere.firstMaterial?.isDoubleSided = true
        return SCNNode(geometry: sphere)
    }
}
