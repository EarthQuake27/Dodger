//
//  GameScene.swift
//  Unkown Game
//
//  Created by Nyein Chan Aung on 7/25/17.
//  Copyright © 2017 Nyein Chan Aung. All rights reserved.
//

import GameplayKit
import SpriteKit
import CoreMotion

enum GameSceneState {
    case paused, active, gameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameState: GameSceneState = .paused
    var sinceTouch : TimeInterval = 0
    var lastTouchPosition: CGPoint?
    var buttonRestart: MSButtonNode!
    var returMenu: MSButtonNode!
    var complimentLabel: SKLabelNode!
    var instructions: MSButtonNode!
    var text = 0
    var decrease = 0.7
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var points = 0
    var motionManager: CMMotionManager!
    let scrollSpeed: CGFloat = 160
    let fixedDelta: TimeInterval = 1.0/60.0 /* 60 FPS */
    let bulletCategory: UInt32 = 0x1 << 0;
    let playerCategory: UInt32 = 0x1 << 1;
    let deleteCapCategory: UInt32 = 0x1 << 2;
    
    override func didMove(to view: SKView) {
        //Set up scene
        
        
        //Set physics contact delegate
        physicsWorld.contactDelegate = self
        
        //Movement
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = 0.1
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        //Recursive Node for goompa
        player = self.childNode(withName: "//player") as! SKSpriteNode
        
        //Recursive Node for scoreLabel
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        
        //Recursicel Node for InsultLabel
        complimentLabel = self.childNode(withName: "complimentLabel") as! SKLabelNode
        
        //Recursive Node for Instructions
        instructions = self.childNode(withName: "instructions") as! MSButtonNode
        
        instructions.selectedHandler = {
            self.instructions.removeFromParent()
            self.gameState = .active
            self.spawnBullets()
        }
        
        //Recursive Node for restart
        buttonRestart = self.childNode(withName: "//buttonRestart") as! MSButtonNode
        
        buttonRestart.selectedHandler = {
            
            //RestartM8
            let skView = self.view as SKView!
            
            //Load Game scene
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            //Ensure correct aspect mode
            scene?.scaleMode = .aspectFill
            
            //Restart game scene
            skView?.presentScene(scene)
        }
        
        buttonRestart.state = .MSButtonNodeStateHidden
        
        
        //Recursive Node for the Menu
        returMenu = self.childNode(withName: "returMenu") as! MSButtonNode!
        
        returMenu.selectedHandler = {
            self.returnEnu()
            
        }
        
        returMenu.state = .MSButtonNodeStateHidden
        
        
        
        
        /* Reset Score label */
        scoreLabel.text = "\(points)"
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //payer touches anything, game over
        
        //Ensure only called while game running
        if gameState != .active { return }
        
        //Change game state to game over
        gameState = .gameOver
        
        // Stop animation
        player.removeAllActions()
        
        //stop Movement
        player.physicsBody?.isDynamic = false
        
        // Show restart button
        buttonRestart.state = .MSButtonNodeStateActive
        
        //show returnMenu
        returMenu.state = .MSButtonNodeStateActive
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Called when a touch begin
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        //called when recuring frame
        
        if gameState != .active { return }
        
        if points < 200 {
            
            
            #if (arch(i386) || arch(x86_64))
                if let currentTouch = lastTouchPosition {
                    let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                    physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
                }
            #else
                if let accelerometerData = motionManager.accelerometerData {
                    player.physicsBody?.velocity = CGVector(dx: accelerometerData.acceleration.x * 1000, dy: accelerometerData.acceleration.x * 0)
                }
            #endif
            
        }
    }
    
    func returnEnu() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = MainMenu(fileNamed:"MainMenu") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill
        
        /* Show debug */
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    
    func spawnBullets() {
        
        
        let bullet = SKSpriteNode(imageNamed: "Spike")
        let spawnPoint = UInt32(self.size.width)
        
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 60))
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.allowsRotation = false
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = playerCategory
        bullet.physicsBody?.collisionBitMask = bulletCategory
        bullet.physicsBody?.collisionBitMask = playerCategory
        bullet.physicsBody?.collisionBitMask = deleteCapCategory
        bullet.position = CGPoint(x: CGFloat(arc4random_uniform(spawnPoint)), y: self.size.height)
        
        if gameState != .gameOver {
            
            let action = SKAction.moveTo(y: -50, duration: TimeInterval(decrease))
            bullet.run(SKAction.repeatForever(action))
            
            
            if bullet.position.y >= 100 {
                bullet.removeFromParent()
                print("delete")
            }
            
            //Speed Cap
            if points < 50 {
                
                decrease -= 0.001
                
            } else {
                
                if decrease == 0.65 {
                    decrease = 0.65
                    if points < 100 {
                        decrease -= 0.005
                    } else {
                        decrease -= 0.005
                    }
                }
                
            }
            print(decrease)
            
            //Correspondent to the points accumulated
            points += 1
            scoreLabel.text = String(points)
            
            
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameScene.spawnBullets), userInfo: nil, repeats: false)
            
            self.addChild(bullet)
            
        } else {
            
            bullet.removeFromParent()
        }
    }
}











