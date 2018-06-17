//
//  ViewController.swift
//  PokemonGOD
//
//  Created by Huaiyu.Lin on 2018/6/14.
//  Copyright © 2018 Huaiyu Lin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class YUARViewController: UIViewController, UIGestureRecognizerDelegate {
    var sceneView:ARSCNView!
    var planeToggle = UISwitch()
    var middleButton = UIButton()
    var rightButton = UIButton()
    var planeColor:UIColor!
    var planeNodes:[SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)
        setupScene()
        setupButtons()
        changePlaneColor()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
//            // If the gesture recognizer's view isn't one of the squares, do not
//            // allow simultaneous recognition.
//            if gestureRecognizer.view != self.yellowView &&
//                gestureRecognizer.view != self.cyanView &&
//                gestureRecognizer.view != self.magentaView {
//                return false
//            }
//            // If the gesture recognizers are on diferent views, do not allow
//            // simultaneous recognition.
//            if gestureRecognizer.view != otherGestureRecognizer.view {
//                return false
//            }
//            // If either gesture recognizer is a long press, do not allow
//            // simultaneous recognition.
//            if gestureRecognizer is UILongPressGestureRecognizer ||
//                otherGestureRecognizer is UILongPressGestureRecognizer {
//                return false
//            }
//
            return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneStart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func setupScene() {
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.showsStatistics = true
        configureLighting()
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.view.addSubview(sceneView)
        
    }
    
    func sceneStart() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
    }
    
    func configureLighting() {
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    func setupButtons() {
        // middleButton setup
        middleButton.setTitle("Middle", for: .normal)
        middleButton.setTitleColor(.white, for: .normal)
        middleButton.backgroundColor = UIColor(red: 207/255,
                                                green: 30/255,
                                                blue: 80/255,
                                                alpha: 0.6)
        middleButton.frame.size = CGSize(width: 80, height: 40)
        middleButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.9)
        middleButton.layer.cornerRadius = 10
        middleButton.isEnabled = true
        middleButton.addTarget(self, action: #selector(middleButtonDidClick(_:)), for: .touchUpInside)
        
        
        // rightButton setup
        rightButton.setTitle("Right", for: .normal)
        rightButton.setTitleColor(UIColor.white, for: .normal)
        rightButton.isEnabled = true
        rightButton.backgroundColor = UIColor(red: 252/255, green: 88/255, blue: 60/255, alpha: 0.8)
        rightButton.layer.cornerRadius = 10;
        rightButton.addTarget(
            self,
            action: #selector(rightButtonDidClick(_:)),
            for: .touchUpInside)
        rightButton.frame.size.height = 40
        rightButton.frame.size.width = 80
        rightButton.center = CGPoint(
            x: middleButton.center.x + 100,
            y: middleButton.center.y)
        
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
        
        self.view.addSubview(planeToggle)
        self.view.addSubview(middleButton)
        self.view.addSubview(rightButton)
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            print("Screen edge swiped!")
            
        }
    }
    
    
    @objc func middleButtonDidClick(_ sender: Any) {
    }
    
    
    @objc func rightButtonDidClick(_ sender: Any) {
    }
    
    @objc func planeToggleDidClick(_ sender: Any) {
        changePlaneColor()
    }
    
    func changePlaneColor() {
        if planeToggle.isOn {
            planeColor = UIColor.clear
            sceneView.debugOptions = []
            sceneView.showsStatistics = false
            planeToggle.isOn = false
        } else {
            planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)
            sceneView.showsStatistics = true
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
            planeToggle.isOn = true
        }
        
        for node in planeNodes {
            node.geometry?.materials.first?.diffuse.contents = planeColor
        }
        
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


extension YUARViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let  planeAnchor = anchor as? ARPlaneAnchor else { return }
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.y)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = planeColor
        var planeNode = SCNNode(geometry: plane)
        
        let position = SCNVector3(planeAnchor.center.x,
                                  planeAnchor.center.y,
                                  planeAnchor.center.z)
        planeNode.name = "plane"
        planeNode.position = position
        planeNode.eulerAngles.x = -.pi/2
        
        update(&planeNode, withGeometry: plane, type: .static)
        
        planeNodes.append(planeNode)
        node.addChildNode(planeNode)

    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            var planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.name = "plane"
        planeNode.position = SCNVector3(x, y, z)
        
        update(&planeNode, withGeometry: plane, type: .static)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func update(_ node: inout SCNNode, withGeometry geometry: SCNGeometry, type: SCNPhysicsBodyType) {
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        let physicsBody = SCNPhysicsBody(type: type, shape: shape)
        node.physicsBody = physicsBody
    }
}

extension YUARViewController:SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
    }
}

extension float4x4 {
    
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
    
}

extension SCNMatrix4 {
    var translation: float3 {
        return float3(x:m41,y:m42,z:m43)
    }
}

