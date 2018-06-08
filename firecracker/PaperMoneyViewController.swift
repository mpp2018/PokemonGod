//
//  PaperMoneyViewController.swift
//  firecracker
//
//  Created by Huaiyu.Lin on 2018/6/6.
//  Copyright © 2018 Huaiyu Lin. All rights reserved.
//

import ARKit
import UIKit

class PaperMoneyViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        #if DEBUG
        // Show debug UI to view performance metrics (e.g. frames per second).
        sceneView.showsStatistics = true
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Creates a new AR configuration to run on the `session`.
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension PaperMoneyViewController:ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.y)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)

        let planeNode = SCNNode(geometry: plane)
        
        let position = SCNVector3(planeAnchor.center.x,
                                  planeAnchor.center.y,
                                  planeAnchor.center.z)
        planeNode.name = "plane"
        planeNode.position = position
        planeNode.eulerAngles.x = -.pi/2
        
        let planeGeometry = SCNBox(width: width, height: 0.01, length: height, chamferRadius: 0)
        let physicalBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        physicalBody.isAffectedByGravity = false
        planeNode.physicsBody = physicalBody
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // Plane estimation may also extend planes, or remove one plane to merge its extent into another.
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }
}

extension PaperMoneyViewController:ARSessionDelegate {
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        print("Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        print("Session interruption ended")
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        print("Session failed: \(error.localizedDescription)")
        resetTracking()
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("Adding anchor")
    }
}
