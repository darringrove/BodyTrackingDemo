//
//  ARViewContainer.swift
//  BodyTracking
//
//  Created by Ryan Kopinsky on 6/16/22.
//

/*
Copyright 2022 Reality School

All rights reserved. No part of this source code may be reproduced
or distributed by any means without prior written permission of the copyright owner.
It is strictly prohibited to publish any parts of the
source code to publicly accessible repositories or websites.

You are hereby granted permission to use and/or modify
the source code in as many apps as you want, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import SwiftUI
import RealityKit
import ARKit

private var bodySkeleton: BodySkeleton?
private let bodySkeletonAnchor = AnchorEntity()

// Wraps UIKit-based ARView to be used in SwiftUI View
struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView
    
    func makeUIView(context: UIViewRepresentableContext<ARViewContainer>) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        arView.setupForBodyTracking()
        
        // Add bodySkeletonAnchor to scene
        arView.scene.addAnchor(bodySkeletonAnchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: UIViewRepresentableContext<ARViewContainer>) {
        
    }
}

// Extend ARView to implement body tracking functionality
extension ARView: ARSessionDelegate {
    // Configure ARView for body tracking
    func setupForBodyTracking() {
        let configuration = ARBodyTrackingConfiguration()
        self.session.run(configuration)
        
        self.session.delegate = self
    }
    
    // Implement ARSession didUpdate anchors delegate method
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                // Create or update bodySkeleton
                if let skeleton = bodySkeleton {
                    // BodySkeleton already exists, update pose of all joints
                    skeleton.update(with: bodyAnchor)
                } else {
                    // BodySkeleton doesn't exist yet. This means human body detected for the first time.
                    // Create a bodySkeleton entity and add it to the bodySkeletonAnchor
                    bodySkeleton = BodySkeleton(for: bodyAnchor)
                    bodySkeletonAnchor.addChild(bodySkeleton!)
                }
            }
        }
    }
}
