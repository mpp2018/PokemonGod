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
    private var sceneView:ARSCNView!
    var audioSource: SCNAudioSource!
    
    var paper: SCNNode?
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    var isBurnning = false
    var isHit = false
    var papers = Set<SCNNode>()
    private var planeToggle = UISwitch()
    private var fireButton = UIButton()
    private var stopButton = UIButton()
    private var planeColor:UIColor!
    private var planes:[SCNNode] = []
    private var bucketNode = SCNNode()
    private var extinguishTime:TimeInterval = 0
    private var currentTime:TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
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
        planeColor = UIColor.init(red: 0.6, green: 0.6, blue: 1, alpha: 0.5)
        setupScene()
        setupButtons()
        setUpAudio()
//        changePlaneColor()
        addTapGesturesToSceneView()
        
        
        
        
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
    
    func addTapGesturesToSceneView() {
        let tapGesture = UITapGestureRecognizer()
        
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.addTarget(self, action: #selector(didTap(recognizer:)))
        
        sceneView.addGestureRecognizer(tapGesture)
        
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
        let scene = SCNScene(named: "paperMoney.scn")!
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
    
    
    func setupButtons() {
        // fireButton setup
        fireButton.setTitle("Fire", for: .normal)
        fireButton.setTitleColor(.white, for: .normal)
        fireButton.backgroundColor = UIColor(red: 207/255,
                                                green: 30/255,
                                                blue: 80/255,
                                                alpha: 0.6)
        fireButton.frame.size = CGSize(width: 80, height: 40)
        fireButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.9)
        fireButton.layer.cornerRadius = 10
        fireButton.isEnabled = true
        fireButton.addTarget(self, action: #selector(fireButtonDidClick(_:)), for: .touchUpInside)
        
        // planeToggle setup
        planeToggle = UISwitch()
        planeToggle.isOn = true
        planeToggle.tintColor = UIColor(red: 180/255, green: 160/255, blue: 210/255, alpha: 0.8)
        planeToggle.onTintColor = UIColor(red: 180/255, green: 160/255, blue: 210/255, alpha: 0.8)
        planeToggle.frame.size = CGSize(width: 80, height: 40)
        planeToggle.center = CGPoint(x: fireButton.center.x - 100,
                                     y: fireButton.center.y)
        planeToggle.addTarget(self, action: #selector(planeToggleDidClick(_:)), for: .valueChanged)
        
        
        // stopButton setup
        stopButton.setTitle("Stop", for: .normal)
        stopButton.setTitleColor(UIColor.white, for: .normal)
        stopButton.isEnabled = true
        stopButton.backgroundColor = UIColor(red: 252/255, green: 88/255, blue: 60/255, alpha: 0.8)
        stopButton.layer.cornerRadius = 10;
        stopButton.addTarget(
            self,
            action: #selector(stopButtonDidClick),
            for: .touchUpInside)
        stopButton.frame.size.height = 40
        stopButton.frame.size.width = 80
        stopButton.center = CGPoint(
            x: fireButton.center.x + 100,
            y: fireButton.center.y)
        
        
        self.view.addSubview(fireButton)
        self.view.addSubview(stopButton)
        self.view.addSubview(planeToggle)
    }
    
    @objc func planeToggleDidClick(_ sender: Any) {
        changePlaneColor()
    }
    
    @objc func fireButtonDidClick(_ sender: Any) {
        startBurnning()
    }
    
    @objc func stopButtonDidClick(_ sender:Any) {
        stopBurnning()
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
            plane.firstMaterial?.diffuse.contents = planeColor
            let planeNode = SCNNode(geometry: plane)
            
            let position = SCNVector3(planeAnchor.center.x,
                                      planeAnchor.center.y,
                                      planeAnchor.center.z)
            planeNode.name = "plane"
            planeNode.position = position
            planeNode.eulerAngles.x = -.pi/2
            node.addChildNode(planeNode)
            planes.append(planeNode)
            let cylinder = SCNCylinder(radius: 0.1, height: 0.3)
            
            
            let bucketImage = UIColor.clear
            cylinder.firstMaterial?.diffuse.contents = bucketImage
            let bucket = SCNNode(geometry: cylinder)
            bucket.name = "bucket"
            bucket.simdPosition = float3(planeAnchor.center.x, planeAnchor.center.y + Float(cylinder.height/2), planeAnchor.center.z)
            bucket.physicsBody = SCNPhysicsBody.kinematic()
            bucket.physicsBody?.categoryBitMask = 2
            bucket.physicsBody?.collisionBitMask = 0
            bucket.physicsBody?.contactTestBitMask = 1
            
            let bucketReal = SCNScene(named: "bucket.scn")!
            let bucketNode2 = bucketReal.rootNode.childNode(withName: "bucket", recursively: true)!
            bucketNode2.simdPosition = float3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
            
            bucketNode = bucket
            node.addChildNode(bucket)
            node.addChildNode(bucketNode2)
            
            startBurnning()
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
        currentTime = time
        if extinguishTime == 0.0 {
            extinguishTime = time + 10
        }
        
        if extinguishTime < time {
            stopBurnning()
        }
        
        guard let planeNode = sceneView.scene.rootNode.childNode(withName: "plane", recursively: true) else { return }
        
        if paper?.parent != nil && (paper?.presentation.simdWorldPosition.y)! < planeNode.presentation.simdWorldPosition.y {
            paper?.physicsBody?.velocity = SCNVector3Zero
            paper?.physicsBody?.isAffectedByGravity = false
        }
        
        if paper?.parent != nil && paper!.presentation.simdWorldPosition.y < -2 {
            paper!.removeFromParentNode()
            
        }
    }
}

extension PaperMoneyViewController {
    private func startBurnning() {
        guard let fire = SCNParticleSystem(named: "fire", inDirectory: nil) else {
            assert(false)
        }
        extinguishTime = currentTime + 5
        bucketNode.removeAllParticleSystems()
        bucketNode.addParticleSystem(fire)
        playSound()
        isBurnning = true
        
    }
    
    private func increaseBurnning() {
        guard let fire = SCNParticleSystem(named: "fire", inDirectory: nil) else {
            assert(false)
        }
        extinguishTime = extinguishTime + 5
        bucketNode.addParticleSystem(fire)
        isBurnning = true
    }
    
    private func stopBurnning() {
        isBurnning = false
        extinguishTime = currentTime
        bucketNode.removeAllParticleSystems()
        stopSound()
    }
    
    private func setUpAudio() {
        // Instantiate the audio source
        audioSource = SCNAudioSource(fileNamed: "fireplace.mp3")!
        // As an environmental sound layer, audio should play indefinitely
        audioSource.loops = true
        // Decode the audio from disk ahead of time to prevent a delay in playback
        audioSource.load()
    }
    /// Plays a sound on the `bucketNode` using SceneKit's positional audio
    /// - Tag: AddAudioPlayer
    private func playSound() {
        // Ensure there is only one audio player
        bucketNode.removeAllAudioPlayers()
        // Create a player from the source and add it to `bucketNode`
        bucketNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        
    }
    
    private func stopSound() {
        // Ensure there is only one audio player
        bucketNode.removeAllAudioPlayers()
    }
    
}
extension PaperMoneyViewController:ARSessionDelegate {
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        print("Session interruption ended")
//        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        print("Session failed: \(error.localizedDescription)")
        resetTracking()
    }
}

extension PaperMoneyViewController:UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            return true
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
                self.extinguishTime = self.extinguishTime + 5
                if !self.isBurnning {
                    self.startBurnning()
                } else {
                    self.increaseBurnning()
                }
            }
            else {
                contact.nodeA.removeFromParentNode()
                self.papers.remove(contact.nodeA)
            }
        }
    }
}
