//
//  ViewController.swift
//  firecracker
//
//  Created by Huaiyu.Lin on 2018/6/1.
//  Copyright © 2018 Huaiyu Lin. All rights reserved.
//
import ARKit
import UIKit

class ViewController: UIViewController {
    private var sceneView:ARSCNView!
    private var planeColor:UIColor!
    override func viewDidLoad() {
        super.viewDidLoad()
        planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)
        setupScene()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneStart()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupScene() {
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.showsStatistics = true
        sceneView.scene = SCNScene()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        configureLighting()
        self.view.addSubview(sceneView)
    }
 
    func sceneStart() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical, .horizontal]
        sceneView.session.run(configuration)
    }
    func configureLighting() {
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap(sender:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(sender recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        
        let ball = SCNSphere(radius:CGFloat(0.15))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        ball.materials = [material]
        let ballNode = SCNNode(geometry: ball)
        ballNode.name = "Ball"
        ballNode.position = SCNVector3Make(translation.x, translation.y, translation.z)
        
        sceneView.scene.rootNode.addChildNode(ballNode)
    }
    
}



extension ViewController: ARSCNViewDelegate {
 
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let  planeAnchor = anchor as? ARPlaneAnchor else { return }
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.y)
        let plane = SCNPlane(width: width, height: height)

        plane.materials.first?.diffuse.contents = planeColor
        let planeNode = SCNNode(geometry: plane)

        let position = SCNVector3(planeAnchor.center.x,
                                planeAnchor.center.y,
                                planeAnchor.center.z)

        planeNode.position = position
        planeNode.eulerAngles.x = -.pi/2
        node.addChildNode(planeNode)

        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
}

extension ViewController:SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
    }
}

extension ViewController:UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//
//    }
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
//
//    }
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//
//    }
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

