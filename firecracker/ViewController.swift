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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    func setupScene() {
        
    }
    
}



extension ViewController: ARSCNViewDelegate, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {
    
}


