//
//  ARFrame+Extension.swift
//  DepthMap
//
//  Created by MacBook Pro M1 on 2021/04/20.
//

import ARKit

extension ARFrame {
    var depthMap: CVPixelBuffer? {
        guard let depthMap = self.smoothedSceneDepth?.depthMap ?? self.sceneDepth?.depthMap else {
            return nil
        }
        
        return depthMap
    }
    
    var depthMapImage: UIImage? {
        guard let depthMap = self.depthMap else {
            return nil
        }
        
        let ciImage = CIImage(cvPixelBuffer: depthMap)
        let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
        guard let image = cgImage else { return nil }
        return UIImage(cgImage: image)
    }
}
