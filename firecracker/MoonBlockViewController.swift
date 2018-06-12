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
    var rightBlock = SCNNode()
    var leftBlock = SCNNode()
    var setup = true
    var throwing = false
    private var planeToggle = UISwitch()
    private var explodeButton = UIButton()
    private var stopButton = UIButton()
    private var planeColor:UIColor!
    private var planes:[SCNNode] = []
    
    @IBOutlet weak var ARView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)
        // Set the view's delegate
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        setupButtons()
        ARView.delegate = self
        ARView.showsStatistics = true
        ARView.session.delegate = self
        ARView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Run the view's session
        ARView.session.run(configuration)
        addSwipeGesturesToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        ARView.session.run(configuration)
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
    
    func setupButtons() {
        // explodeBuddon setup
//        explodeButton.setTitle("Explode", for: .normal)
//        explodeButton.setTitleColor(.white, for: .normal)
//        explodeButton.backgroundColor = UIColor(red: 207/255,
//                                                green: 30/255,
//                                                blue: 80/255,
//                                                alpha: 0.6)
//        explodeButton.frame.size = CGSize(width: 80, height: 40)
//        explodeButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.85)
//        explodeButton.layer.cornerRadius = 10
//        explodeButton.isEnabled = true
//        explodeButton.addTarget(self, action: #selector(explodeButtonDidClick(_:)), for: .touchUpInside)
        let bottomCenter = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.85)
        // planeToggle setup
        planeToggle = UISwitch()
        planeToggle.isOn = true
        planeToggle.tintColor = UIColor(red: 180/255, green: 160/255, blue: 210/255, alpha: 0.8)
        planeToggle.onTintColor = UIColor(red: 180/255, green: 160/255, blue: 210/255, alpha: 0.8)
        planeToggle.frame.size = CGSize(width: 80, height: 40)
        planeToggle.center = CGPoint(x: bottomCenter.x - 100,
                                     y: bottomCenter.y)
        planeToggle.addTarget(self, action: #selector(planeToggleDidClick(_:)), for: .valueChanged)
//
//
//        // stopButton setup
//        stopButton.setTitle("Stop", for: .normal)
//        stopButton.setTitleColor(UIColor.white, for: .normal)
//        stopButton.isEnabled = true
//        stopButton.backgroundColor = UIColor(red: 252/255, green: 88/255, blue: 60/255, alpha: 0.8)
//        stopButton.layer.cornerRadius = 10;
//        stopButton.addTarget(
//            self,
//            action: #selector(FirecrackerViewController.stopButtonDidClick),
//            for: .touchUpInside)
//        stopButton.frame.size.height = 40
//        stopButton.frame.size.width = 80
//        stopButton.center = CGPoint(
//            x: explodeButton.center.x + 100,
//            y: explodeButton.center.y)
//
        
//        self.view.addSubview(explodeButton)
//        self.view.addSubview(stopButton)
        self.view.addSubview(planeToggle)
    }
    
    @objc func planeToggleDidClick(_ sender: Any) {
        changePlaneColor()
    }
    
    @objc func explodeButtonDidClick(_ sender: Any) {
        
    }
    
    @objc func stopButtonDidClick(_ sender:Any) {
        
    }
    
    func getMoonBlock() {
        
        guard let centerPoint = ARView.pointOfView else {
            return
        }
        
        let cameraTransform = centerPoint.transform
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        
        
        let cameraPosition = SCNVector3Make(
            cameraLocation.x + cameraOrientation.x,
            cameraLocation.y + cameraOrientation.y,
            cameraLocation.z + cameraOrientation.z)
        
        print(cameraLocation)
        print(cameraOrientation)
        print(cameraPosition)
        
        let moonBlockScene = SCNScene(named: "CrescentMoon.scn")!
        rightBlock = moonBlockScene.rootNode.childNode(withName: "right_block", recursively: true)!
        let rightShape = SCNPhysicsShape(geometry: (rightBlock.geometry)!, options: [.type: SCNPhysicsShape.ShapeType.convexHull])
        rightBlock.physicsBody = SCNPhysicsBody(type: .static, shape: rightShape)
        leftBlock = moonBlockScene.rootNode.childNode(withName: "left_block", recursively: true)!
        let leftShape = SCNPhysicsShape(geometry: (leftBlock.geometry)!, options: [.type: SCNPhysicsShape.ShapeType.convexHull])
        leftBlock.physicsBody = SCNPhysicsBody(type: .static, shape: leftShape)
        
        //add light
        let light = moonBlockScene.rootNode.childNode(withName: "omni",recursively: true)!
        light.position = SCNVector3(0, 20, 0)
        
        ARView.scene.rootNode.addChildNode(rightBlock)
        ARView.scene.rootNode.addChildNode(leftBlock)
        
        rightBlock.transform = SCNMatrix4Mult(SCNMatrix4MakeTranslation(0, 5, 0), cameraTransform)
        leftBlock.transform = SCNMatrix4Mult(SCNMatrix4MakeTranslation(0, -5, 0), cameraTransform)
//
//        let forceVector:Float = 5
//        ballNode.physicsBody?.applyForce(SCNVector3(x: cameraOrientation.x * forceVector, y: cameraOrientation.y * forceVector, z: cameraOrientation.z * forceVector), asImpulse: true)
//        BallNodesArray.append(ballNode)
//        sceneView.scene.rootNode.addChildNode(ballNode)
    }
    
    func changePlaneColor() {
        if !planeToggle.isOn {
            planeColor = UIColor.clear
            planeToggle.isOn = false
        } else {
            planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)
            planeToggle.isOn = true
        }
        for node in planes {
            node.geometry?.materials.first?.diffuse.contents = planeColor
        }
        
    }
    
    func addMoonBlock() {
        let moonBlockScene = SCNScene(named: "CrescentMoon.scn")!
        rightBlock = moonBlockScene.rootNode.childNode(withName: "right_block", recursively: true)!
        let rightShape = SCNPhysicsShape(geometry: (rightBlock.geometry)!, options: [.type: SCNPhysicsShape.ShapeType.convexHull])
        rightBlock.physicsBody = SCNPhysicsBody(type: .static, shape: rightShape)
        leftBlock = moonBlockScene.rootNode.childNode(withName: "left_block", recursively: true)!
        let leftShape = SCNPhysicsShape(geometry: (leftBlock.geometry)!, options: [.type: SCNPhysicsShape.ShapeType.convexHull])
        leftBlock.physicsBody = SCNPhysicsBody(type: .static, shape: leftShape)
        
        //add light
        let light = moonBlockScene.rootNode.childNode(withName: "omni",recursively: true)!
        light.position = SCNVector3(0, 20, 0)
        
        ARView.scene.rootNode.addChildNode(rightBlock)
        ARView.scene.rootNode.addChildNode(leftBlock)
    }
    
    @objc func throwMoonBlock(withGestureRecognizer recognizer: UIGestureRecognizer){
        let currentTransform = ARView.session.currentFrame?.camera.transform
        //guard recognizer.state == .ended else { return }
        if(!throwing){
            throwing = true
            rightBlock.physicsBody?.isAffectedByGravity = true
            leftBlock.physicsBody?.isAffectedByGravity = true
            rightBlock.physicsBody = SCNPhysicsBody.dynamic()
            leftBlock.physicsBody = SCNPhysicsBody.dynamic()
            
            let forceScale = Float(1)
            let angle = Float(30.0 / 180 * Double.pi)
            let relatedForce = currentTransform! * simd_float4x4(SCNMatrix4Rotate(SCNMatrix4Identity, Float.pi / 2, 0, 0, 1)) * float4(0, forceScale*sin(angle), -forceScale*cos(angle), 1)
            
            rightBlock.physicsBody?.applyForce(SCNVector3(relatedForce.x , relatedForce.y, relatedForce.z), asImpulse: true)
            leftBlock.physicsBody?.applyForce(SCNVector3(relatedForce.x , relatedForce.y, relatedForce.z), asImpulse: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                self.rightBlock.physicsBody = SCNPhysicsBody.static()
                self.leftBlock.physicsBody = SCNPhysicsBody.static()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                    self.rightBlock.physicsBody?.isAffectedByGravity = false
                    self.leftBlock.physicsBody?.isAffectedByGravity = false
                    self.throwing = false
                })
            })
        }
        
    }
    
    func addSwipeGesturesToSceneView() {
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MoonBlockViewController.throwMoonBlock(withGestureRecognizer:)))
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
        
        plane.materials.first?.diffuse.contents = planeColor
        
        var planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        update(&planeNode, withGeometry: plane, type: .static)
        
        node.addChildNode(planeNode)
        planes.append(planeNode)
        addMoonBlock()
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
