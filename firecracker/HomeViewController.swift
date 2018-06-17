//
//  HomeViewController.swift
//  firecracker
//
//  Created by Huaiyu.Lin on 2018/6/16.
//  Copyright © 2018 Huaiyu Lin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    private let backgroundImageView = UIImageView()
    private let firecrackerButton = UIButton()
    private var fireworkButton = UIButton()
    private var moonBlockButton = UIButton()
    private var paperMoneyButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func setupBackground() {
        backgroundImageView.frame = self.view.bounds
        backgroundImageView.image = UIImage.init(named: "welcome_page")
        self.view.addSubview(backgroundImageView)
    }
    
    func setupButtons() {
        // explodeBuddon setup
        let length  = self.view.frame.width * 0.3
        let padding = length * 0.08
        let offset  = length/2 + padding
        let centerX = self.view.center.x
        let centerY = self.view.center.y + 10
        
        moonBlockButton.setImage(UIImage.init(named: "button_block"), for: .normal)
        moonBlockButton.frame.size = CGSize(width: length, height: length)
        moonBlockButton.center = CGPoint(x:centerX-offset,y:centerY-offset)
        moonBlockButton.isEnabled = true
        moonBlockButton.addTarget(
            self,
            action: #selector(moonBlockButtonDidClick(_:)),
            for: .touchUpInside)
        
        firecrackerButton.setImage(UIImage.init(named: "button_firecracker"), for: .normal)
        firecrackerButton.frame.size = CGSize(width: length, height: length)
        firecrackerButton.center = CGPoint(x:centerX+offset,y:centerY-offset)
        firecrackerButton.isEnabled = true
        firecrackerButton.addTarget(
            self,
            action: #selector(firecrackerButtonDidClick(_:)),
            for: .touchUpInside)
        
        fireworkButton.setImage(UIImage.init(named: "button_firework"), for: .normal)
        fireworkButton.frame.size = CGSize(width: length, height: length)
        fireworkButton.center = CGPoint(x:centerX-offset,y:centerY+offset)
        fireworkButton.isEnabled = true
        fireworkButton.addTarget(
            self,
            action: #selector(fireworkButtonDidClick(_:)),
            for: .touchUpInside)
        
        paperMoneyButton.setImage(UIImage.init(named: "button_bucket"), for: .normal)
        paperMoneyButton.frame.size = CGSize(width: length, height: length)
        paperMoneyButton.center = CGPoint(x:centerX+offset,y:centerY+offset)
        paperMoneyButton.isEnabled = true
        paperMoneyButton.addTarget(
            self,
            action: #selector(paperMoneyButtonDidClick(_:)),
            for: .touchUpInside)
        
        self.view.addSubview(moonBlockButton)
        self.view.addSubview(firecrackerButton)
        self.view.addSubview(fireworkButton)
        self.view.addSubview(paperMoneyButton)
    }
    
    @objc func moonBlockButtonDidClick(_ sender: Any) {
        let pushViewController = MoonBlockViewController()
        navigationController?.pushViewController(pushViewController, animated: true)
    }
    
    @objc func firecrackerButtonDidClick(_ sender: Any) {
        let pushViewController = FirecrackerViewController()
        navigationController?.pushViewController(pushViewController, animated: true)
    }
    
    @objc func fireworkButtonDidClick(_ sender: Any) {
        let pushViewController = FireworkViewController()
        navigationController?.pushViewController(pushViewController, animated: true)
    }
    
    @objc func paperMoneyButtonDidClick(_ sender: Any) {
        let pushViewController = PaperMoneyViewController()
        navigationController?.pushViewController(pushViewController, animated: true)
    }
    
}
