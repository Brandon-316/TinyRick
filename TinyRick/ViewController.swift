//
//  ViewController.swift
//  TinyRick
//
//  Created by Brandon Mahoney on 7/25/19.
//  Copyright © 2019 Brandon Mahoney. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    //MARK: - Properties
    var animations: [String: CAAnimation] = [:]
    var animation: [Dance] = []
    var planeNodes: [SCNNode] = []
    var lastAnimation: String = ""
    var animationCount: Int = 0
    var isRickPresent: Bool = false
    
    var rickAudioPlayer = AVAudioPlayer()
    var songAudioPlayer = AVAudioPlayer()
    
    //Sound clip variables
    let soundType = "wav"
    let tinyRickSound = "tinyRick"
    let rickyTickySound = "rickyTickyTabbyBiatch"
    let wubbaLubbaSound = "wubbaLubbaDubDub"
    let song = "ActinUp"
    
    //System sound ID's
    var tinyRickSoundID: SystemSoundID = 0
    var rickyTickySoundID: SystemSoundID = 1
    var wubbaLubbaSoundID: SystemSoundID = 2
    var songSoundID: SystemSoundID = 3

    
    //MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    
    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load song
        loadSound(resource: song, type: "m4a", with: &songAudioPlayer, play: false)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Load the DAE animations
        createAnimationsArray()
        loadAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            //If Rick has not been added than add to tapped location
            if !isRickPresent {
                let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
                
                if let hitResult = results.first {
                    self.addRick(atLocation: hitResult)
                    self.removePlaneNodes()
                    self.sceneView.debugOptions = []
                }
                
            } else {
                //Rick has already been added so start animation
                self.handleAnimation(for: touchLocation)
            }
        }
    }

    
    //MARK - Methods
    func createAnimationsArray() {
        for dance in Dance.allCases {
            self.animation.append(dance)
        }
    }
    
    func loadAnimations () {
        for animation in animation {
            self.loadAnimation(withKey: animation.key, sceneName: animation.sceneName, animationIdentifier: animation.animationIdentifier)
        }
    }
    
    func loadAnimation(withKey key: String, sceneName:String, animationIdentifier:String) {
        print("\(key) - \(sceneName) - \(animationIdentifier)")
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            // The animation will only play once
            animationObject.repeatCount = 1
            // To create smooth transitions between animations
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            // Store the animation for later use
            animations[key] = animationObject
        }
    }
    
    //Game Sounds
    func play(audioPlayer: inout AVAudioPlayer) {
        audioPlayer.play()
    }
    
    func loadSound(resource: String, type: String, with audioPlayer: inout AVAudioPlayer, play: Bool) {
        guard let sound = Bundle.main.path(forResource: resource, ofType: type) else {
            print("error to get audio from file")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
        } catch {
            print("audio file error")
        }
        
        if play {
            self.play(audioPlayer: &audioPlayer)
        }
    }
    
    func playSound(key: String, for audioPlayer: inout AVAudioPlayer) {
        let dance = self.animation[self.animationCount]
        switch dance {
            case .breakdanceEnding1: loadSound(resource: tinyRickSound, type: soundType, with: &audioPlayer, play: true)
            case .breakdanceEnding2: loadSound(resource: wubbaLubbaSound, type: soundType, with: &audioPlayer, play: true)
            case .breakdanceEnding3: loadSound(resource: rickyTickySound, type: soundType, with: &audioPlayer, play: true)
        }
    }
    
    func addRick(atLocation location: ARHitTestResult) {
        // Load the character in the idle animation
        let idleScene = SCNScene(named: "art.scnassets/TinyRick/IdleRickSanchez.dae")!
        
        // This node will be parent of all the animation models
        let node = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        // Set up some properties
        let x = location.worldTransform.columns.3.x
        let y = location.worldTransform.columns.3.y
        let z = location.worldTransform.columns.3.z
        node.position = SCNVector3(x, y, z)
        node.scale = SCNVector3(0.037, 0.037, 0.037)
        
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        isRickPresent = true
    }
    
    func handleAnimation(for touchLocation: CGPoint) {
        // Test if a 3D Object was touched
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(touchLocation, options: hitTestOptions)
        
        if hitResults.first != nil {
            
            if !sceneView.scene.rootNode.animationKeys.contains(self.lastAnimation) {
                let key = self.getKey(at: self.animationCount)
                playAnimation(key: key)
            } else {
                self.stopAnimation(key: self.lastAnimation)
            }
        }
    }
    
    func getKey(at index: Int) -> String {
        var key: String = ""
        key = animation[animationCount].key
        
        return key
    }
    
    func playAnimation(key: String) {
        // Add the animation to start playing it right away
        self.lastAnimation = key
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
        playSound(key: key, for: &rickAudioPlayer)
        songAudioPlayer.currentTime = 0
        songAudioPlayer.play()
        
        if animationCount == animation.count - 1 {
            animationCount = 0
        } else {
            animationCount += 1
        }
    }
    
    func stopAnimation(key: String) {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
}



//MARK: - Monitor Scene
extension ViewController {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if isRickPresent && !sceneView.scene.rootNode.animationKeys.contains(self.lastAnimation) && songAudioPlayer.isPlaying {
            self.songAudioPlayer.stop()
        }
    }
}




//MARK: - Plane Rendering
extension ViewController {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !self.isRickPresent {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            let planeNode = createPlane(withPlaneAnchor: planeAnchor)
            
            node.addChildNode(planeNode)
            self.planeNodes.append(planeNode)
        }
    }
    
    //MARK: - Plan Rendering Methods
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode
    }
    
    func removePlaneNodes() {
        for node in planeNodes {
            node.removeFromParentNode()
        }
    }
}
