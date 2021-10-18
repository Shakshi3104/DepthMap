//
//  ARFrame+Extension.swift
//  DepthMap
//
//  Created by MacBook Pro M1 on 2021/04/20.
//

import ARKit

// MARK: - ARFrame extension
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
    
    var capturedImageAsDepthMapScale: UIImage? {
        let capturedImage = self.capturedImage
        
        let imageWidth = CVPixelBufferGetWidth(capturedImage)
        let imageHeight = CVPixelBufferGetHeight(capturedImage)
        
        let scaleX = 256.0 / Double(imageWidth)
        let scaleY = 192.0 / Double(imageHeight)
        
        let ciImage = CIImage(cvPixelBuffer: capturedImage)
        let resizedImage = ciImage.resize(scaleX: scaleX, scaleY: scaleY)
        
        guard let resizedImage = resizedImage else {
            return nil
        }

        let cgImage = CIContext().createCGImage(resizedImage, from: resizedImage.extent)
        guard let image = cgImage else { return nil }
        return UIImage(cgImage: image)
    }
}

// MARK: - CIImage extension
extension CIImage {
    func resize(scaleX: CGFloat, scaleY: CGFloat) -> CIImage? {
        let matrix = CGAffineTransform(scaleX: scaleX, y: scaleY)
        return self.transformed(by: matrix)
    }
}
