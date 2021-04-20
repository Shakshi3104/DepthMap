//
//  ContentView.swift
//  DepthMap
//
//  Created by MacBook Pro M1 on 2021/04/20.
//
// https://ameblo.jp/kamekame0912/entry-12566811291.html


import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
   
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: UIViewRepresentableContext<ARViewContainer>) {
        let configuration = ARWorldTrackingConfiguration()
        
        if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics = .sceneDepth
        }
        
        uiView.session.run(configuration)
    }
    
    func makeCoordinator() -> ARSessionDelegateHandler {
        ARSessionDelegateHandler(self)
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
