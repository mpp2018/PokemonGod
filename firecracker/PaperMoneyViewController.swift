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
    
    var paper: SCNNode?
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    var isHit = false
    
    var papers = Set<SCNNode>()
    
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
        sceneView.scene.physicsWorld.contactDelegate = self
        #if DEBUG
        // Show debug UI to view performance metrics (e.g. frames per second).
        sceneView.showsStatistics = true
        #endif
        
        let tapGesture = UITapGestureRecognizer()
        
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        sceneView.addGestureRecognizer(tapGesture)
        
        tapGesture.addTarget(self, action: #selector(didTap(recognizer:)))
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
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func setupPaper() {
        let scene = SCNScene(named: "sticky note.scn")!
        paper = scene.rootNode.childNode(withName: "note", recursively: true)
        paper?.simdPosition = float3(0, 0, -0.5)
        paper?.physicsBody = .dynamic()
        paper?.physicsBody?.isAffectedByGravity = true
        paper?.physicsBody?.allowsResting = true
        paper?.physicsBody?.collisionBitMask = 0
        if let apaper = paper {
            papers.insert(apaper)
        }
    }
    
    @objc func didTap(recognizer:UITapGestureRecognizer) {
        
        setupPaper()

        guard let aPaper = paper else {
            return
        }
        
        guard let currentTransform = session.currentFrame?.camera.transform else { return }
        
        
        var translation = matrix_identity_float4x4
        
        //Change The X Value
        translation.columns.3.x = 0
        
        //Change The Y Value
        translation.columns.3.y = 0
        
        //Change The Z Value
        translation.columns.3.z = 0
        
        //model to view matrix
        aPaper.simdTransform = currentTransform * translation * (paper?.simdTransform)!
        sceneView.scene.rootNode.addChildNode(aPaper)
        
        let forceScale = Float(2)
        let angle = Float(30.0 / 180 * Double.pi)
        let relatedForce = currentTransform * simd_float4x4(SCNMatrix4Rotate(SCNMatrix4Identity, Float.pi / 2, 0, 0, 1)) * float4(0, forceScale*sin(angle), -forceScale*cos(angle), 1)
        
        aPaper.physicsBody?.applyForce(SCNVector3(relatedForce.x , relatedForce.y, relatedForce.z), asImpulse: true)
    }
}

extension PaperMoneyViewController:ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.y)
        
        if sceneView.scene.rootNode.childNode(withName: "plane", recursively: true) == nil {
            let plane = SCNPlane(width: width, height: height)
            plane.firstMaterial?.diffuse.contents = UIColor.clear
            let planeNode = SCNNode(geometry: plane)
            
            let position = SCNVector3(planeAnchor.center.x,
                                      planeAnchor.center.y,
                                      planeAnchor.center.z)
            planeNode.name = "plane"
            planeNode.position = position
            node.addChildNode(planeNode)
            
            let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 0.3)
            let bucket = SCNNode(geometry: box)
            bucket.name = "bucket"
            bucket.simdPosition = float3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z - 0.5)
            bucket.physicsBody = SCNPhysicsBody.kinematic()
            bucket.physicsBody?.categoryBitMask = 2
            bucket.physicsBody?.collisionBitMask = 0
            bucket.physicsBody?.contactTestBitMask = 1
            
            guard let fire = SCNParticleSystem(named: "fire", inDirectory: nil) else {
                assert(false)
            }
            
            bucket.addParticleSystem(fire)
            node.addChildNode(bucket)
        }
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
        
        guard let planeNode = sceneView.scene.rootNode.childNode(withName: "plane", recursively: true) else { return }
        if paper?.parent != nil && (paper?.presentation.simdWorldPosition.y)! < planeNode.presentation.simdWorldPosition.y {
            paper?.physicsBody?.velocity = SCNVector3Zero
            paper?.physicsBody?.isAffectedByGravity = false
        }
        
        if paper?.parent != nil && paper!.presentation.simdWorldPosition.y < -2 {
            paper!.removeFromParentNode()
            papers.remove(paper)
        }
    }
}

extension PaperMoneyViewController:ARSessionDelegate {
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
}

extension PaperMoneyViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        guard let bucket = sceneView.scene.rootNode.childNode(withName: "bucket", recursively: true) else {
            return
        }
        
        DispatchQueue.main.async {
            if contact.nodeA == bucket{
                contact.nodeB.removeFromParentNode()
                self.papers.remove(contact.nodeB)
            }
            else {
                contact.nodeA.removeFromParentNode()
                self.papers.remove(contact.nodeA)
            }
        }
    }
}
