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
    private var firecrackers:[SCNNode] = []
    private var previousTranslation:float3 = float3(0.0,0.0,0.0)
    private var planeButton = UIButton()
    private var explodeButton = UIButton()
    private var stopButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)
        previousTranslation = float3(0.0,0.0,0.0)
        setupScene()
        setupButtons()
        
        
        
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
    
    func setupButtons() {
        // explodeBuddon setup
        explodeButton.setTitle("Explode", for: .normal)
        explodeButton.setTitleColor(.white, for: .normal)
        explodeButton.backgroundColor = UIColor(red: 197/255,
                                                green: 10/255,
                                                blue: 60/255,
                                                alpha: 0.8)
        explodeButton.frame.size = CGSize(width: 80, height: 40)
        explodeButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.9)
        explodeButton.layer.cornerRadius = 10
        explodeButton.isEnabled = true
        explodeButton.addTarget(self, action: #selector(explodeButtonDidClick(_:)), for: .touchUpInside)
        
        // planeButton setup
        planeButton.setTitle("Hide Plane", for: .normal)
        planeButton.setTitleColor(.white, for: .normal)
        planeButton.backgroundColor = UIColor(red: 252/255, green: 88/255, blue: 60/255, alpha: 0.8)
        planeButton.frame.size = CGSize(width: 80, height: 40)
        planeButton.center = CGPoint(x: explodeButton.center.x - 100,
                                     y: explodeButton.center.y)
        planeButton.layer.cornerRadius = 10
        planeButton.isEnabled = true
        planeButton.addTarget(self, action: #selector(planeButtonDidClick(_:)), for: .touchUpInside)
        
        // stopButton setup
        stopButton.setTitle("Stop", for: .normal)
        stopButton.setTitleColor(UIColor.white, for: .normal)
        stopButton.isEnabled = true
        stopButton.backgroundColor = UIColor(red: 252/255, green: 88/255, blue: 60/255, alpha: 0.8)
        stopButton.layer.cornerRadius = 10;
        stopButton.addTarget(
            self,
            action: #selector(ViewController.stopButtonDidClick),
            for: .touchUpInside)
        stopButton.frame.size.height = 40
        stopButton.frame.size.width = 80
        stopButton.center = CGPoint(
            x: explodeButton.center.x + 100,
            y: explodeButton.center.y)
        
        
        self.view.addSubview(explodeButton)
        self.view.addSubview(planeButton)
        self.view.addSubview(stopButton)
        
    }
    
    @objc func planeButtonDidClick(_ sender: Any) {
        if planeButton.title(for: .normal) == "Hide Plane" {
            planeButton.setTitle("Show Plane", for: .normal)
            planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0)
            for node in sceneView.scene.rootNode.childNodes {
                if node.name == "Plane" {
                    node.geometry?.materials.first?.diffuse.contents = planeColor
                }
            }
        } else {
            planeButton.setTitle("Hide Plane", for: .normal)
            planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0)
            for node in sceneView.scene.rootNode.childNodes {
                if node.name == "Plane" {
                    node.geometry?.materials.first?.diffuse.contents = planeColor
                }
            }
        }
    }
    
    @objc func explodeButtonDidClick(_ sender: Any) {
        firecrackerExplode()
    }
    
    @objc func stopButtonDidClick(_ sender:Any) {
        
    }
    
    func setupScene() {
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.showsStatistics = true
//        addTapGestureToSceneView()
        addPanGestureToSceneView()
        configureLighting()
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
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
    
    func addPanGestureToSceneView() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePan(sender recognizer: UIPanGestureRecognizer) {
//        let translation = recognizer.translation(in: sceneView)
//        let location = recognizer.location(in: sceneView)
        
        let tapLocation = recognizer.location(in: sceneView)
        let planeTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        let nodeTestResults = sceneView.hitTest(tapLocation)
        
        guard let planeTestResult = planeTestResults.first else { return }
        guard let nodeTestResult = nodeTestResults.first?.node else { return }
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
        
        
        
        switch recognizer.state {
            case .began:
                previousTranslation = currentTranslation
                let firecracker = getFirecrackerNode()
                firecracker.position = SCNVector3(x: currentTranslation.x, y: currentTranslation.y, z: currentTranslation.z)
                sceneView.scene.rootNode.addChildNode(firecracker)
                firecrackers.append(firecracker)
                
            break
            
            case .changed:
                if diffxyz > 0.03 {
                    previousTranslation = currentTranslation
                    let firecracker = getFirecrackerNode()
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
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(red: 1, green: 0.3, blue: 0.3, alpha: 0)
        box.materials = [material]
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "Ball"
        let boxCore = SCNCylinder(radius: 0.02, height: 0.01)
        let boxCoreMaterial = SCNMaterial()
        boxCoreMaterial.diffuse.contents = UIColor.init(red: 1, green: 0.6, blue: 0.6, alpha: 1)
        boxCore.materials = [boxCoreMaterial]
        let boxCoreNode = SCNNode(geometry: boxCore)
        boxCoreNode.name = "BallCore"
        boxCoreNode.position = SCNVector3Make(0, 0.01, 0)
        boxNode.addChildNode(boxCoreNode)
        
        return boxNode
    }
    
    func getFirecrackerNode() -> SCNNode {
        
        let purpleImage = UIImage(named:"purple_firecracker.jpg")
        let blueImage = UIImage(named:"blue_firecracker.jpg")
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(red: 1, green: 0.3, blue: 0.3, alpha: 0)
        
        
        let firecracker = SCNCylinder(radius: 0.015, height: 0.009)
        firecracker.materials = [material]
        let firecrackerNode = SCNNode(geometry: firecracker)
        firecrackerNode.name = "firecracker"
        
        let firecrackerLeft = SCNCylinder(radius: 0.005, height: 0.03)
        let firecrackerLeftMaterial = SCNMaterial()
        firecrackerLeftMaterial.diffuse.contents = purpleImage
        firecrackerLeft.materials = [firecrackerLeftMaterial]
        let firecrackerLeftNode = SCNNode(geometry: firecrackerLeft)
        firecrackerLeftNode.name = "firecrackerLeft"
        firecrackerLeftNode.position = SCNVector3Make(-0.015, 0.0025, 0)
        firecrackerLeftNode.eulerAngles.x = -.pi/3
        firecrackerLeftNode.eulerAngles.z = .pi/2
        
        firecrackerNode.addChildNode(firecrackerLeftNode)
        
        let firecrackerRight = SCNCylinder(radius: 0.005, height: 0.03)
        let firecrackerRightMaterial = SCNMaterial()
        firecrackerRightMaterial.diffuse.contents = blueImage
        firecrackerRight.materials = [firecrackerRightMaterial]
        let firecrackerRightNode = SCNNode(geometry: firecrackerRight)
        firecrackerRightNode.name = "firecrackerRight"
        firecrackerRightNode.position = SCNVector3Make(0.015, 0.0025, 0)
        firecrackerRightNode.eulerAngles.x = -.pi/3
        firecrackerRightNode.eulerAngles.z = -.pi/2
        
        firecrackerNode.addChildNode(firecrackerRightNode)
        
        // raywenderlich
        let color = UIColor.white
        let emitterGeo = SCNCylinder(radius: 0.001, height: 0.001)
        let trailEmitter = createFire(color: color, geometry:emitterGeo)
        firecrackerNode.addParticleSystem(trailEmitter)
        return firecrackerNode
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
    
    @objc func firecrackerExplode() {
        
        guard !firecrackers.isEmpty else {
            return
        }
        
        let firecracker = firecrackers.removeFirst()
        firecracker.removeFromParentNode()
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(firecrackerExplode), userInfo: nil, repeats: false)

        
    }
    
    
    func createFire(color: UIColor, geometry: SCNGeometry) ->
        SCNParticleSystem {
            
            let fire = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
            fire.particleColor = color
            fire.emitterShape = geometry
            return fire
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
        planeNode.name = "plane"
        planeNode.position = position
        planeNode.eulerAngles.x = -.pi/2
        node.addChildNode(planeNode)
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

