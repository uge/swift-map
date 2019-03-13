//
//  GameViewController.swift
//  TerrainRender
//
//  Created by Eugene Feinberg on 3/12/19.
//  Copyright © 2019 Eugene Feinberg. All rights reserved.
//

import SceneKit
import QuartzCore
import AppKit
import Foundation
import Cocoa

class GameViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Load the dem example
        let dem = NSImage(contentsOfFile: "/Users/uge/Desktop/TerrainRender/TerrainRender/art.scnassets/out.png")!
        
        // Define a 2D plane object to map elevation to
        let plane = SCNPlane(width: 10.0, height: 10.0)
        
        // Create a representation of the DEM map to colorize
        guard let demRep = NSBitmapImageRep(data: dem.tiffRepresentation!) else {
            print("Could not make demRep")
            return 
        }
        
        // Use the built in colorization instead of a more fancy LUT to go from green to red based on height
        demRep.colorize(byMappingGray: CGFloat(0.1), to: NSColor.red, blackMapping: NSColor.green, whiteMapping: NSColor.red)
        
        let material = SCNMaterial()
        // Color comes from the height->color representation
        material.diffuse.contents = demRep
        // Displacement comes from the grayscale height value
        material.displacement.contents = dem
        
        // In case we rotate it to behind
        material.isDoubleSided = true
        
        plane.widthSegmentCount = 1201
        plane.heightSegmentCount = 1201
        plane.firstMaterial = material

        let planeNode = SCNNode(geometry:plane)
        
        planeNode.position = SCNVector3(x:0, y:0, z:0)
        scene.rootNode.addChildNode(planeNode)
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = NSColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
        }
    }
}
