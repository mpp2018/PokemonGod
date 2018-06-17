//
//  ViewController.swift
//  firecracker
//
//  Created by Huaiyu.Lin on 2018/6/1.
//  Copyright © 2018 Huaiyu Lin. All rights reserved.
//

import ARKit
import UIKit
import AVFoundation

class FirecrackerViewController: UIViewController {
    private var sceneView:ARSCNView!
    private var planeColor:UIColor!
    private var planes:[SCNNode] = []
    private var firecrackers:[SCNNode] = []
    private var firecrackerSetNode = SCNNode()
    private var previousTranslation:float3 = float3(0.0,0.0,0.0)
    private var planeToggle = UISwitch()
    private var explodeButton = UIButton()
    private var cleanButton = UIButton()
    private var player: AVAudioPlayer?
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "firecracker", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)
        previousTranslation = float3(0.0,0.0,0.0)
        setupScene()
        setupButtons()
//        changePlaneColor()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneStart()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.player?.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    } 
    
    func setupButtons() {
        // explodeBuddon setup
        explodeButton.setTitle("Explode", for: .normal)
        explodeButton.setTitleColor(.white, for: .normal)
        explodeButton.backgroundColor = UIColor(red: 207/255,
                                                green: 30/255,
                                                blue: 80/255,
                                                alpha: 0.6)
        explodeButton.frame.size = CGSize(width: 80, height: 40)
        explodeButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.9)
        explodeButton.layer.cornerRadius = 10
        explodeButton.isEnabled = true
        explodeButton.addTarget(self, action: #selector(explodeButtonDidClick(_:)), for: .touchUpInside)
        
        // planeToggle setup
        planeToggle = UISwitch()
        planeToggle.isOn = true
        planeToggle.tintColor = UIColor(red: 180/255, green: 160/255, blue: 210/255, alpha: 0.8)
        planeToggle.onTintColor = UIColor(red: 180/255, green: 160/255, blue: 210/255, alpha: 0.8)
        planeToggle.frame.size = CGSize(width: 80, height: 40)
        planeToggle.center = CGPoint(x: explodeButton.center.x - 100,
                                y: explodeButton.center.y)
        planeToggle.addTarget(self, action: #selector(planeToggleDidClick(_:)), for: .valueChanged)
        
        
        // cleanButton setup
        cleanButton.setTitle("Clean", for: .normal)
        cleanButton.setTitleColor(UIColor.white, for: .normal)
        cleanButton.isEnabled = true
        cleanButton.backgroundColor = UIColor(red: 252/255, green: 88/255, blue: 60/255, alpha: 0.8)
        cleanButton.layer.cornerRadius = 10;
        cleanButton.addTarget(
            self,
            action: #selector(FirecrackerViewController.cleanButtonDidClick),
            for: .touchUpInside)
        cleanButton.frame.size.height = 40
        cleanButton.frame.size.width = 80
        cleanButton.center = CGPoint(
            x: explodeButton.center.x + 100,
            y: explodeButton.center.y)
        
        
        self.view.addSubview(explodeButton)
        self.view.addSubview(cleanButton)
        self.view.addSubview(planeToggle)
        
    }
    
    @objc func planeToggleDidClick(_ sender: Any) {
        changePlaneColor()
    }
    
    @objc func explodeButtonDidClick(_ sender: Any) {
        playSound()
        firecrackerExplode()
    }
    
    @objc func cleanButtonDidClick(_ sender:Any) {

        for node in sceneView.scene.rootNode.childNodes {
            if node.name == "firecrackerSet" ||
                node.name == "box" ||
                node.name == "line"  {
                node.removeFromParentNode()
            }
            
        }
    }
    
    func setupScene() {
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.showsStatistics = true
        addPanGestureToSceneView()
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
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap(sender:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addPanGestureToSceneView() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePan(sender recognizer: UIPanGestureRecognizer) {
//        let translation = recognizer.translation(in: sceneView)
//        let location = recognizer.location(in: sceneView)
        
        let tapLocation = recognizer.location(in: sceneView)
        let planeTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        guard let planeTestResult = planeTestResults.first else { return }
        let currentTranslation = planeTestResult.worldTransform.translation
        let diffTranslation = (currentTranslation - previousTranslation)
        let (diffx, diffy, diffz) = (diffTranslation.x,diffTranslation.y,diffTranslation.z)
        let diffxyz = pow((pow(diffx, 2) +
                            pow(diffy, 2) +
                            pow(diffz, 2)), 0.5)
//        let diffxz = pow((pow(diffx, 2) +
//                        pow(diffz, 2)), 0.5)
        let tanTheta = diffx/diffz
        var thetaOffset = 0.0
        if diffz < 0 { thetaOffset = .pi }
        let theta = Float(thetaOffset) + atan(tanTheta)
        
        let line = getLineNode()
        line.transform = SCNMatrix4Rotate(line.transform, theta, 0, 1, 0)
        line.position = SCNVector3(x: currentTranslation.x, y: currentTranslation.y, z: currentTranslation.z)
        sceneView.scene.rootNode.addChildNode(line)
        
        switch recognizer.state {
            case .began:
                previousTranslation = currentTranslation
//                let firecracker = getfirecrackerSetNode()
//                firecracker.position = SCNVector3(x: currentTranslation.x, y: currentTranslation.y, z: currentTranslation.z)
//                sceneView.scene.rootNode.addChildNode(firecracker)
//                firecrackers.append(firecracker)
            break
            
            case .changed:
                if diffxyz > 0.02 {
                    previousTranslation = currentTranslation
                    let firecracker = getfirecrackerSetNode()
                    firecracker.position = SCNVector3(x: currentTranslation.x, y: currentTranslation.y, z: currentTranslation.z)
                    firecracker.eulerAngles.y = theta
                    sceneView.scene.rootNode.addChildNode(firecracker)
                    firecrackers.append(firecracker)
                }
            break
            case .ended:
                previousTranslation = float3(0.0,0.0,0.0)
                let firecrackerBox = getFirecrackerBoxNode()
                let offsetx = (diffx/diffxyz) * 0.06
                let offsetz = (diffz/diffxyz) * 0.06
                firecrackerBox.position = SCNVector3Make(currentTranslation.x + offsetx, currentTranslation.y, currentTranslation.z + offsetz)
                firecrackerBox.eulerAngles.y = theta
                sceneView.scene.rootNode.addChildNode(firecrackerBox)
//                firecrackers.append(firecrackerBox)
            break
            default: break
        }
        
    
        
        
        
    }
    
    func getFirecrackerBoxNode() -> SCNNode {
        let box = SCNBox(width: 0.06, height: 0.02, length: 0.06, chamferRadius: 0.002)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(red: 1, green: 0.3, blue: 0.3, alpha: 0)
        box.materials = [material]
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "box"
        let boxCore = SCNBox(width: 0.06, height: 0.02, length: 0.06, chamferRadius: 0.003)
        let boxCoreMaterial = SCNMaterial()
        boxCoreMaterial.diffuse.contents =  UIImage(named:"firebox.png")
        boxCore.materials = [boxCoreMaterial]
        let boxCoreNode = SCNNode(geometry: boxCore)
        boxCoreNode.name = "boxCore"
        boxCoreNode.position = SCNVector3Make(0, 0.01, 0)
        boxCoreNode.eulerAngles.y = -.pi/4
        boxNode.addChildNode(boxCoreNode)
        
        return boxNode
    }
    func getLineNode() -> SCNNode {
       
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        let line = SCNCylinder(radius: 0.001, height: 0.004)
        line.materials = [material]
        let lineNode = SCNNode(geometry: line)
        lineNode.eulerAngles.x = -.pi/2
        lineNode.name = "line"
        
        return lineNode
    }
    
    func getfirecrackerSetNode() -> SCNNode {
        if firecrackerSetNode.name != "firecrackerSet" {
            createFirecrackerSetNode()
        } else {
            firecrackerSetNode = firecrackerSetNode.clone()
        }
        
        return firecrackerSetNode
    }
    
    func createFirecrackerSetNode() {
        if firecrackerSetNode.name != "firecrackerSet" {
            let purpleImage = UIImage(named:"purple_firecracker.jpg")
            let blueImage = UIImage(named:"blue_firecracker.jpg")
            let grayImage = UIImage(named:"gray_firecracker.jpg")
            let redImage = UIImage(named:"red_firecracker.jpg")
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.init(red: 1, green: 0.3, blue: 0.3, alpha: 0)
            
            
            let firecracker = SCNSphere(radius: 0.03)
            firecracker.materials = [material]
            firecrackerSetNode = SCNNode(geometry: firecracker)
            firecrackerSetNode.name = "firecracker"
            
            let firecrackerLeft = SCNCylinder(radius: 0.005, height: 0.03)
            let firecrackerLeftMaterial = SCNMaterial()
            firecrackerLeftMaterial.diffuse.contents = purpleImage
            firecrackerLeft.materials = [firecrackerLeftMaterial]
            let firecrackerLeftNode = SCNNode(geometry: firecrackerLeft)
            firecrackerLeftNode.name = "firecrackerLeft"
            firecrackerLeftNode.position = SCNVector3Make(-0.015, 0.0025, 0)
            firecrackerLeftNode.eulerAngles.x = -.pi/3
            firecrackerLeftNode.eulerAngles.z = .pi/2
            
            firecrackerSetNode.addChildNode(firecrackerLeftNode)
            
            let firecrackerRight = SCNCylinder(radius: 0.005, height: 0.03)
            let firecrackerRightMaterial = SCNMaterial()
            firecrackerRightMaterial.diffuse.contents = blueImage
            firecrackerRight.materials = [firecrackerRightMaterial]
            let firecrackerRightNode = SCNNode(geometry: firecrackerRight)
            firecrackerRightNode.name = "firecrackerRight"
            firecrackerRightNode.position = SCNVector3Make(0.015, 0.0025, 0)
            firecrackerRightNode.eulerAngles.x = -.pi/3
            firecrackerRightNode.eulerAngles.z = -.pi/2
            
            firecrackerSetNode.addChildNode(firecrackerRightNode)
            
            let firecrackerTop = SCNCylinder(radius: 0.005, height: 0.03)
            let firecrackerTopMaterial = SCNMaterial()
            firecrackerTopMaterial.diffuse.contents = grayImage
            firecrackerTop.materials = [firecrackerTopMaterial]
            let firecrackerTopNode = SCNNode(geometry: firecrackerTop)
            firecrackerTopNode.name = "firecrackerTop"
            firecrackerTopNode.position = SCNVector3Make(-0.015, 0.0025, 0)
            firecrackerTopNode.eulerAngles.x = -.pi/3
            firecrackerTopNode.eulerAngles.z = .pi/2
            firecrackerTopNode.transform = SCNMatrix4Rotate(firecrackerTopNode.transform, .pi/2, 0, 0, 1)
            firecrackerSetNode.addChildNode(firecrackerTopNode)
            
            let firecrackerBottom = SCNCylinder(radius: 0.005, height: 0.03)
            let firecrackerBottomMaterial = SCNMaterial()
            firecrackerBottomMaterial.diffuse.contents = redImage
            firecrackerBottom.materials = [firecrackerBottomMaterial]
            let firecrackerBottomNode = SCNNode(geometry: firecrackerBottom)
            firecrackerBottomNode.name = "firecrackerBottom"
            firecrackerBottomNode.position = SCNVector3Make(0.015, 0.0025, 0)
            firecrackerBottomNode.eulerAngles.x = -.pi/3
            firecrackerBottomNode.eulerAngles.z = -.pi/2
            firecrackerBottomNode.transform = SCNMatrix4Rotate(firecrackerBottomNode.transform, .pi/2, 0, 0, 1)
            firecrackerSetNode.addChildNode(firecrackerBottomNode)
            firecrackerSetNode.name = "firecrackerSet"
            
        }
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
    
    @objc func firecrackerExplode() {
        
        guard !firecrackers.isEmpty else {
            return
        }
        
        if firecrackers.count == 2 {
            player?.setVolume(0, fadeDuration: 0.6)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.player?.stop()
            }
        }
        
        let firecracker = firecrackers.removeFirst()
        createExplosion(geometry: firecracker.geometry!, position: firecracker.presentation.position,
                        rotation: firecracker.presentation.rotation)
        firecracker.removeFromParentNode()
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(firecrackerExplode), userInfo: nil, repeats: false)

        
    }
   
    
    func createExplosion(geometry: SCNGeometry, position: SCNVector3,
                         rotation: SCNVector4) {
        
        let explosion =
            SCNParticleSystem(named: "Explode.scnp", inDirectory:
                nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .surface
        
        let rotationMatrix =
            SCNMatrix4MakeRotation(rotation.w, rotation.x,
                                   rotation.y, rotation.z)
        let translationMatrix =
            SCNMatrix4MakeTranslation(position.x, position.y,
                                      position.z)
        let transformMatrix =
            SCNMatrix4Mult(rotationMatrix, translationMatrix)
        
        sceneView.scene.addParticleSystem(explosion, transform:
            transformMatrix)
    }
    
}


extension FirecrackerViewController: ARSCNViewDelegate {
 
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
        planeNode.name = "plane"
        planeNode.position = position
        planeNode.eulerAngles.x = -.pi/2
        planes.append(planeNode)
        node.addChildNode(planeNode)
        createFirecrackerSetNode()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
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
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
}

extension FirecrackerViewController:SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
    }
}

extension FirecrackerViewController:UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
           
            return true
    }
}
