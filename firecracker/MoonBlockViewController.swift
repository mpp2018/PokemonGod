//
//  MoonBlockViewController.swift
//  firecracker
//
//  Created by Huaiyu.Lin on 2018/6/6.
//  Copyright © 2018 Huaiyu Lin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class MoonBlockViewController: UIViewController, ARSKViewDelegate, ARSessionDelegate{
    
    let basketballNodeName = "basketball"
    var rightBlock = SCNNode()
    var leftBlock = SCNNode()
    var setup = true
    var throwing = false
    var ARView:ARSCNView!
    
//    @IBOutlet weak var ARView: ARSCNView!
    func setupScene() {
        ARView = ARSCNView(frame: self.view.bounds)
        ARView.showsStatistics = true
        ARView.delegate = self
        ARView.session.delegate = self
        // Run the view's session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        ARView.session.run(configuration)
        ARView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.view.addSubview(ARView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        // Create a session configuration
        setupScene()
        // Run the view's session
        addSwipeGesturesToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        ARView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    func addBasketball(x: Float = 0.0, y: Float = 0, z: Float = -2, plane node: SCNNode) {
        let ballScene = SCNScene(named: "CrescentMoon.scn")!
        rightBlock = ballScene.rootNode.childNode(withName: "right_block", recursively: true)!
        let rightShape = SCNPhysicsShape(geometry: (rightBlock.geometry)!, options: [.type: SCNPhysicsShape.ShapeType.convexHull])
        rightBlock.physicsBody = SCNPhysicsBody(type: .static, shape: rightShape)
        leftBlock = ballScene.rootNode.childNode(withName: "left_block", recursively: true)!
        let leftShape = SCNPhysicsShape(geometry: (leftBlock.geometry)!, options: [.type: SCNPhysicsShape.ShapeType.convexHull])
        leftBlock.physicsBody = SCNPhysicsBody(type: .static, shape: leftShape)
        
        //basketballNode.addChildNode(rightBlock!)
        //basketballNode.addChildNode(leftBlock!)
        //basketballNode.position = SCNVector3(0, 0, -0.3)
        //basketballNode.scale = SCNVector3(0.001, 0.001, 0.001)
        //basketballNode.name = basketballNodeName
        //basketballNode
        //ballScene.rootNode.addChildNode(self.basketballNode)
        ARView.scene.rootNode.addChildNode(rightBlock)
        ARView.scene.rootNode.addChildNode(leftBlock)
        //node.addChildNode(self.basketballNode)
    }
    @objc func throwBasketball(withGestureRecognizer recognizer: UIGestureRecognizer){
        let currentTransform = ARView.session.currentFrame?.camera.transform
        //guard recognizer.state == .ended else { return }
        if(!throwing){
            throwing = true
            //rightBlock.physicsBody?.isAffectedByGravity = true
            rightBlock.physicsBody = SCNPhysicsBody.dynamic()
            leftBlock.physicsBody = SCNPhysicsBody.dynamic()
            
            let forceScale = Float(1)
            let angle = Float(30.0 / 180 * Double.pi)
            let relatedForce = currentTransform! * simd_float4x4(SCNMatrix4Rotate(SCNMatrix4Identity, Float.pi / 2, 0, 0, 1)) * float4(0, forceScale*sin(angle), -forceScale*cos(angle), 1)
            
            rightBlock.physicsBody?.applyForce(SCNVector3(relatedForce.x , relatedForce.y, relatedForce.z), asImpulse: true)
            leftBlock.physicsBody?.applyForce(SCNVector3(relatedForce.x , relatedForce.y, relatedForce.z), asImpulse: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                self.throwing = false
                self.rightBlock.physicsBody = SCNPhysicsBody.static()
                self.leftBlock.physicsBody = SCNPhysicsBody.static()
            })
        }
        
    }
    
    func addSwipeGesturesToSceneView() {
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MoonBlockViewController.throwBasketball(withGestureRecognizer:)))
        swipeUpGestureRecognizer.direction = .up
        ARView.addGestureRecognizer(swipeUpGestureRecognizer)
        
    }
}

extension MoonBlockViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor){
        
        guard let planeAnchor = anchor as? ARPlaneAnchor ,setup else {return}
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.lightGray
        
        var planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        update(&planeNode, withGeometry: plane, type: .static)
        
        node.addChildNode(planeNode)
        addBasketball(x: planeAnchor.center.x,y: 0.5,z: planeAnchor.center.z,plane: node)
        setup = false
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            var planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        
        planeNode.position = SCNVector3(x, y, z)
        
        update(&planeNode, withGeometry: plane, type: .static)
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        var transform = SCNMatrix4Rotate(SCNMatrix4Identity, Float.pi / 2, 0, 0, 1)
        transform  = SCNMatrix4Translate(transform, 0, 0, -0.3)
        let cameraTransform = SCNMatrix4(frame.camera.transform)
        transform = SCNMatrix4Mult(transform, cameraTransform)
        //let position = SCNVector3(pos.columns.3.x, pos.columns.3.y, pos.columns.3.z - 0.3)
        if (!throwing){
            rightBlock.transform = transform
            rightBlock.scale = SCNVector3(0.001, 0.001, 0.001)
            rightBlock.eulerAngles.x = rightBlock.eulerAngles.x + .pi / 2
            leftBlock.transform = transform
            leftBlock.scale = SCNVector3(0.001, 0.001, 0.001)
            leftBlock.eulerAngles.x = leftBlock.eulerAngles.x - .pi / 2
        }
    }
    
    func update(_ node: inout SCNNode, withGeometry geometry: SCNGeometry, type: SCNPhysicsBodyType) {
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        let physicsBody = SCNPhysicsBody(type: type, shape: shape)
        node.physicsBody = physicsBody
    }
}
