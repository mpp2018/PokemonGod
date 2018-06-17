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
    private var sceneView:ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)
        // Set the view's delegate
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        setupScene()
        setupButtons()
        addSwipeGesturesToSceneView()
    }
    
    func setupScene() {
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        self.view.addSubview(sceneView)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
//         explodeBuddon setup
        explodeButton.setTitle("Explode", for: .normal)
        explodeButton.setTitleColor(.white, for: .normal)
        explodeButton.backgroundColor = UIColor(red: 207/255,
                                                green: 30/255,
                                                blue: 80/255,
                                                alpha: 0.6)
        explodeButton.frame.size = CGSize(width: 120, height: 60)
        explodeButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.1)
        explodeButton.layer.cornerRadius = 10
        explodeButton.isEnabled = true
        explodeButton.addTarget(self, action: #selector(explodeButtonDidClick(_:)), for: .touchUpInside)
        
        let bottomCenter = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.9)
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
        explodeButton.isHidden = true
        self.view.addSubview(explodeButton)
//        self.view.addSubview(stopButton)
        self.view.addSubview(planeToggle)
    }
    
    @objc func planeToggleDidClick(_ sender: Any) {
        changePlaneColor()
    }
    
    @objc func explodeButtonDidClick(_ sender: Any) {
        explodeButton.isHidden = true;
    }
    
    @objc func stopButtonDidClick(_ sender:Any) {
        
    }
    
    
    func changePlaneColor() {
        if planeToggle.isOn {
            planeColor = UIColor.clear
            sceneView.showsStatistics = false
            planeToggle.isOn = false
            sceneView.debugOptions = []
        } else {
            planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)
            sceneView.showsStatistics = true
            planeToggle.isOn = true
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        }
        for node in planes {
            node.geometry?.materials.first?.diffuse.contents = planeColor
        }
        
    }
    func getMoonBlockResult() -> String {
        
        var resultText = "沒筊"
        
        guard let rightOmni = rightBlock.childNode(withName: "omni", recursively: true), let rightDirection = rightBlock.childNode(withName: "direction", recursively: true), let leftOmni = leftBlock.childNode(withName: "omni", recursively: true), let leftDirection = leftBlock.childNode(withName: "direction", recursively: true) else {
            return resultText
        }
        
        var leftResult  = 0
        var rightResult = 0
        
        if rightOmni.presentation.simdWorldPosition.y > rightDirection.presentation.simdWorldPosition.y {
           rightResult = 1
        } else if rightOmni.presentation.simdWorldPosition.y < rightDirection.presentation.simdWorldPosition.y {
            rightResult = -1
        }
        
        if leftOmni.presentation.simdWorldPosition.y > leftDirection.presentation.simdWorldPosition.y {
           leftResult = 1
        } else if leftOmni.presentation.simdWorldPosition.y < leftDirection.presentation.simdWorldPosition.y {
           leftResult = -1
        }
        
        let result = leftResult + rightResult
        
        if result == 2 {
            resultText = "陰筊"
        } else if result == 0 {
            resultText = "聖筊"
        } else if result == -2 {
            resultText = "笑筊"
        } else {
            resultText = "立筊"
        }
        
        return resultText
    }
    
    func addMoonBlock() {
        let moonBlockScene = SCNScene(named: "CrescentMoon.scn")!
        
        rightBlock = moonBlockScene.rootNode.childNode(withName: "right_block", recursively: true)!
        
        let rightShape = SCNPhysicsShape(geometry: (rightBlock.geometry)!, options:nil)
        rightBlock.physicsBody = SCNPhysicsBody(type: .static, shape: rightShape)
        
        leftBlock = moonBlockScene.rootNode.childNode(withName: "left_block", recursively: true)!
        
        let leftShape = SCNPhysicsShape(geometry: (leftBlock.geometry)!, options:nil)
        leftBlock.physicsBody = SCNPhysicsBody(type: .static, shape: leftShape)
        
        
        sceneView.scene.rootNode.addChildNode(rightBlock)
        sceneView.scene.rootNode.addChildNode(leftBlock)
    }
    
    @objc func throwMoonBlock(withGestureRecognizer recognizer: UIGestureRecognizer){
        let currentTransform = sceneView.session.currentFrame?.camera.transform
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
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.rightBlock.physicsBody = SCNPhysicsBody.static()
                self.leftBlock.physicsBody = SCNPhysicsBody.static()
                
                let resultText = self.getMoonBlockResult()
                self.explodeButton.setTitle(resultText, for: .normal)
                self.explodeButton.isHidden = false
                print(resultText)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
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
        sceneView.addGestureRecognizer(swipeUpGestureRecognizer)
        
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
        planeNode.name = "plane"
        
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
            rightBlock.scale = SCNVector3(0.002, 0.002, 0.002)
            rightBlock.eulerAngles.x = rightBlock.eulerAngles.x + .pi / 2
            leftBlock.transform = transform
            leftBlock.scale = SCNVector3(0.002, 0.002, 0.002)
            leftBlock.eulerAngles.x = leftBlock.eulerAngles.x - .pi / 2
            self.explodeButton.isHidden = true
        }
    }
    
    func update(_ node: inout SCNNode, withGeometry geometry: SCNGeometry, type: SCNPhysicsBodyType) {
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        let physicsBody = SCNPhysicsBody(type: type, shape: shape)
        node.physicsBody = physicsBody
    }
}
extension MoonBlockViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            
            return true
    }
}

extension MoonBlockViewController:SCNPhysicsContactDelegate {
    
}
