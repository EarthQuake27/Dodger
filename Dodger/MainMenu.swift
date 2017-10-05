//
//  MainMenu.swift
//  Dodger
//
//  Created by Nyein Chan Aung on 8/8/17.
//  Copyright © 2017 Nyein Chan Aung. All rights reserved.
//


import SpriteKit

class MainMenu: SKScene {
    
    /* UI Connections */
    var playButton: MSButtonNode!
    var creditsButton: MSButtonNode!
    var list: MSButtonNode!
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Set UI connections */
        
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        
        playButton.selectedHandler = {
            self.StartGame()
            print("active play")
        }
        
        list = self.childNode(withName: "//list") as! MSButtonNode
        
        list.selectedHandler = {
            self.StartAme()
            print("active")
        }
        
        list.state = .MSButtonNodeStateHidden
        
        
        creditsButton = self.childNode(withName: "creditsButton") as! MSButtonNode
        
        creditsButton.selectedHandler = {
            self.list.state = .MSButtonNodeStateActive
            print("revealed")
        }
    }
    
    
    func StartGame() {
        
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = GameScene(fileNamed:"GameScene") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill
        
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func StartAme() {
        
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = GameScene(fileNamed:"GameScene") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill
        
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }

}

