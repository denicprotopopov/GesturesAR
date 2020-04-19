//
//  ViewController.swift
//  GesturesAR
//
//  Created by Denis Protopopov on 19/04/2020.
//  Copyright © 2020 Denis Protopopov. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        sceneView.debugOptions = [SCNDebugOptions.showWorldOrigin]
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }


}

