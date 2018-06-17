//
//  FireworkViewController.swift
//  PokemonGOD
//
//  Created by Huaiyu.Lin on 2018/6/14.
//  Copyright © 2018 Huaiyu Lin. All rights reserved.
//

import UIKit
import ARKit

class FireworkViewController: YUARViewController {
    let fireworkNodeName = "Firework"
    var fireworkNodes:[SCNNode] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()
        addSwipeGesturesToSceneView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addFireworkToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func addFireworkToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        guard let hitTestResult = hitTestResults.first else { return }
        
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        
        guard let fireworkScene = SCNScene(named: "chineseFirework.scn") else { return }
        guard let fireworkNode = fireworkScene.rootNode.childNode(withName: "Firework", recursively: false)
            else { return }
        
        fireworkNode.position = SCNVector3(x,y,z)
        
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        fireworkNode.physicsBody = physicsBody
        fireworkNode.name = fireworkNodeName
        
        sceneView.scene.rootNode.addChildNode(fireworkNode)
        fireworkNodes.append(fireworkNode)
    }
    
    func getFireworkNode(from swipeLocation: CGPoint) -> SCNNode? {
        let hitTestResults = sceneView.hitTest(swipeLocation)
        
        guard let parentNode = hitTestResults.first?.node.parent,
            parentNode.name == fireworkNodeName
            else { return nil }
        
        return parentNode
    }
    
    override func setupButtons() {
        super.setupButtons()
        middleButton.setTitle("Fire", for: .normal)
        rightButton.setTitle("Shoot", for: .normal)
    }
    
    override func middleButtonDidClick(_ sender: Any) {
        for fireworkNode in fireworkNodes {
            guard let physicsBody = fireworkNode.physicsBody,
            let reactorParticleSystem = SCNParticleSystem(named: "reactor", inDirectory: nil),
            let lineNode = fireworkNode.childNode(withName: "line", recursively: false)
            else { return }
            // 3
            physicsBody.isAffectedByGravity = false
            physicsBody.damping = 0
            // 4
            reactorParticleSystem.colliderNodes = planeNodes
            // 5
            lineNode.addParticleSystem(reactorParticleSystem)
            // 6
            let action = SCNAction.moveBy(x: 0, y: 0.3, z: 0, duration: 3)
            action.timingMode = .easeInEaseOut
            fireworkNode.runAction(action)
        }
    }
    
    override func rightButtonDidClick(_ sender: Any) {
        for fireworkNode in fireworkNodes {
            guard let physicsBody = fireworkNode.physicsBody
                else { return }
            let direction = SCNVector3(0, 3, 0)
            physicsBody.type = .dynamic
            physicsBody.applyForce(direction, asImpulse: true)
        }
    }
    
    override func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        super.renderer(renderer, didUpdate: node, for: anchor)
        
    }
    
    // TODO: Create get Firework node from swipe location method
    func addSwipeGesturesToSceneView() {
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(applyForceToFirework(withGestureRecognizer:)))
        swipeUpGestureRecognizer.direction = .up
        sceneView.addGestureRecognizer(swipeUpGestureRecognizer)
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(launchFirework(withGestureRecognizer:)))
        swipeDownGestureRecognizer.direction = .down
        sceneView.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    // TODO: Create apply force to Firework method
    
    @objc func applyForceToFirework(withGestureRecognizer recognizer: UIGestureRecognizer) {
        // 1
        guard recognizer.state == .ended else { return }
        // 2
        let swipeLocation = recognizer.location(in: sceneView)
        // 3
        guard let fireworkNode = getFireworkNode(from: swipeLocation),
            let physicsBody = fireworkNode.physicsBody
            else { return }
        // 4
        let direction = SCNVector3(0, 3, 0)
        physicsBody.type = .dynamic
        physicsBody.applyForce(direction, asImpulse: true)
    }
    
    
    // TODO: Create launch Firework method
    @objc func launchFirework(withGestureRecognizer recognizer: UIGestureRecognizer) {
        // 1
        guard recognizer.state == .ended else { return }
        // 2
        let swipeLocation = recognizer.location(in: sceneView)
        guard let fireworkNode = getFireworkNode(from: swipeLocation),
            let physicsBody = fireworkNode.physicsBody,
            let reactorParticleSystem = SCNParticleSystem(named: "reactor", inDirectory: nil),
            let lineNode = fireworkNode.childNode(withName: "line", recursively: false)
            else { return }
        // 3
        physicsBody.isAffectedByGravity = false
        physicsBody.damping = 0
        // 4
        reactorParticleSystem.colliderNodes = planeNodes
        // 5
        lineNode.addParticleSystem(reactorParticleSystem)
        // 6
        let action = SCNAction.moveBy(x: 0, y: 0.3, z: 0, duration: 3)
        action.timingMode = .easeInEaseOut
        fireworkNode.runAction(action)
    }
    
}


extension UIColor {
    open class var transparentWhite: UIColor {
        return UIColor.white.withAlphaComponent(0.20)
    }
}
