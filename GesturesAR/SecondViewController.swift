//
//  SecondViewController.swift
//  GesturesAR
//
//  Created by Denis Protopopov on 27/04/2020.
//  Copyright © 2020 Denis Protopopov. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import Vision

class SecondViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    var runloopCoreMLUpdate = true
        var runupdateCoreML = true
        
        private var serialQueue = DispatchQueue(label: "dispatchqueueml")
        private var visionRequests = [VNRequest]()
        let object = SCNScene(named: "art.scnassets/portal.scn")!.rootNode.clone()
    }
        
    // MARK: - Lifecycle
    extension SecondViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
           
            func setUpCoachingOverlay() {
                let coachingOverlay = ARCoachingOverlayView()
                coachingOverlay.session = sceneView.session
                coachingOverlay.delegate = self as? ARCoachingOverlayViewDelegate
                coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
                sceneView.addSubview(coachingOverlay)
                
                NSLayoutConstraint.activate([
                    coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
                    coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
                ])
               
                coachingOverlay.activatesAutomatically = true
                coachingOverlay.goal = .horizontalPlane
                
            }
            func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {}
            func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {}
              //  self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
              //  ARSCNDebugOptions.showFeaturePoints]
            setupAR()
            setUpCoachingOverlay()
                
            }
            func punchTheClown() {
                
                sceneView?.session.pause()
                sceneView?.removeFromSuperview()
                sceneView = nil
                runloopCoreMLUpdate = false
                runupdateCoreML = false

            }
            
            override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                punchTheClown()
            }
    }
    // MARK: - Setup
    extension SecondViewController {
       
        private func setupAR() {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
            sceneView.addGestureRecognizer(tapGestureRecognizer)
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            sceneView.session.run(configuration)
        }
        
        
    }
    // MARK: - Private
    extension SecondViewController {
        @objc func tapped(recognizer: UIGestureRecognizer) {
            
            let location = recognizer.location(in: sceneView)
            let hitTest = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
            
            if hitTest.isEmpty {
                print("No Plane Detected")
                print("Continue Detection")
                return
                
            } else {
                
               // SCNVector3(x: hitResult.worldTransform.columns.3.x, y: //hitResult.worldTransform.columns.3.y + 0.05, z: hitResult.worldTransform.columns.3.z)
                
                let columns = hitTest.first?.worldTransform.columns.3
                object.position = SCNVector3(x: columns!.x, y: columns!.y, z: columns!.z-1)
               // let min = object.boundingBox.min
                //let max = object.boundingBox.max
               // object.pivot = SCNMatrix4MakeTranslation(
                  // min.x + (max.x - min.x)/2,
              //      min.y + (max.y - min.y)/2,
              //     min.z + (max.z - min.z)/2
          //      )
                
                self.sceneView.scene.rootNode.addChildNode(object)
                sceneView.autoenablesDefaultLighting = true
                
            }
            
        }
        
     
        
    }

