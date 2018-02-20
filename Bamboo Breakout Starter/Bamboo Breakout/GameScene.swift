//
//  GameScene.swift
//  Bamboo Breakout
/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */ 

import SpriteKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"

//Costants bitMasks
let BallCategory   : UInt32 = 0x1 << 0
let BottomCategory : UInt32 = 0x1 << 1
let BlockCategory  : UInt32 = 0x1 << 2
let PaddleCategory : UInt32 = 0x1 << 3
let BorderCategory : UInt32 = 0x1 << 4


class GameScene: SKScene, SKPhysicsContactDelegate {
    
  var isFingerOnPaddle = false
    
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    //Created un edge-based
    let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    //Set friction
    borderBody.friction = 0
    //Set physic body for every node
    self.physicsBody = borderBody
    
    //Bouncing ball
    physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    physicsWorld.contactDelegate = self
    
    let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
    ball.physicsBody!.applyImpulse(CGVector(dx: 2.0, dy: -2.0))
    
    //Set categoryBitMasks
    let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
    
    let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
    let bottom = SKNode()
    bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
    addChild(bottom)
    
    bottom.physicsBody!.categoryBitMask = BottomCategory
    ball.physicsBody!.categoryBitMask = BallCategory
    paddle.physicsBody!.categoryBitMask = PaddleCategory
    borderBody.categoryBitMask = BorderCategory
    
    ball.physicsBody!.contactTestBitMask = BottomCategory
  }
    //Methods touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if let body = physicsWorld.body(at: touchLocation) {
            if body.node?.name == PaddleCategoryName {
                print("Began touch on paddle")
                isFingerOnPaddle = true
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check whether the player is touching the paddle
        if isFingerOnPaddle {
            // Get the touch location and previous touch location
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            // SKSpriteNode for the paddle
            let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
            // Current position
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            // Repositioning the paddle .. limit the position
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            // Set the position
            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Create two local variables
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        // Check the two bodies that collided
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        // Profit from the sorting that you did just before
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
            print("Hit bottom. First contact has been made.")
        }
    }
  
}
