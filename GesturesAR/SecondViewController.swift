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
        let object = SCNScene(named: "word.scn")!.rootNode.clone()
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
            setupML()
            loopCoreMLUpdate()
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
        
        private func setupML() {
            guard let selectedModel = try? VNCoreMLModel(for: example_5s0_hand_model().model) else {
                    fatalError("Could not load model.")
            }
            
            let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
            visionRequests = [classificationRequest]
            
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
                
                let columns = hitTest.first?.worldTransform.columns.3
                object.position = SCNVector3(x: columns!.x, y: columns!.y+0.2, z: columns!.z)
                let min = object.boundingBox.min
                let max = object.boundingBox.max
                object.pivot = SCNMatrix4MakeTranslation(
                    min.x + (max.x - min.x)/2,
                    min.y + (max.y - min.y)/2,
                    0
                )
                
                self.sceneView.scene.rootNode.addChildNode(object)
                sceneView.autoenablesDefaultLighting = true
                
            }
            
        }
        
        private func loopCoreMLUpdate() {
            if !runloopCoreMLUpdate { return }
            serialQueue.async {
                self.updateCoreML()
                self.loopCoreMLUpdate()
                
            }
            
        }
        
    }
    // MARK: - Private
    extension SecondViewController {
        private func updateCoreML() {
            if !runupdateCoreML { return }
            let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
            if pixbuff == nil { return }
            let ciImage = CIImage(cvPixelBuffer: pixbuff!)
            let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                try imageRequestHandler.perform(self.visionRequests)
            } catch {
                print(error)
            }
        }
    }
    // MARK: - Private
    extension SecondViewController {
        private func classificationCompleteHandler(request: VNRequest, error: Error?) {
            if error != nil {
                print("Error: " + (error?.localizedDescription)!)
                return
                
            }
            
            guard let observations = request.results else {
                print("No results")
                return
                
            }
            
            let classifications = observations[0...2]
                .compactMap({ $0 as? VNClassificationObservation })
                .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
                .joined(separator: "\n")
            
            DispatchQueue.main.async {
                let topPrediction = classifications.components(separatedBy: "\n")[0]
                let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
                let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
                
                if (topPredictionScore != nil && topPredictionScore! > 0.10) {
                    if topPredictionName == "FIVE-UB-RHand" {
                        
                        self.object.runAction(SCNAction.rotateBy(x: 0.0, y: 0.0, z: 1.0, duration: 200.0))
                        print("FIVE")
                        
                    }
                    
                    if topPredictionName == "fist-UB-RHand" {
                        self.object.removeAllActions()
                        print("FIST")
                        
                    }
                    
                }
                
            }
            
        }
        
    }
