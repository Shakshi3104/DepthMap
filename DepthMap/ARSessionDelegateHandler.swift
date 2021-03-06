//
//  ARSessionDelegateHandler.swift
//  DepthMap
//
//  Created by MacBook Pro M1 on 2021/04/20.
//
// https://stackoverflow.com/questions/59870084/pass-value-from-swiftui-to-arkit-dynamically
// https://qiita.com/1024chon/items/74da8d63a8959a8192f5

import ARKit

extension ARViewContainer {
    
    class ARSessionDelegateHandler: NSObject, ARSessionDelegate {
        /// - Tag: ARView
        var arVC: ARViewContainer
        
        /// - Tag: saving file
        var documentURL: NSURL {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            return documentURL
        }
        
        var depthMapURL: NSURL {
            let depthMapURL = documentURL.appendingPathComponent("DepthMap", isDirectory: true)
            if !FileManager.default.fileExists(atPath: depthMapURL!.path) {
                do {
                    try FileManager.default.createDirectory(at: depthMapURL!, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            return depthMapURL! as NSURL
        }
        
        var capturedImageURL: NSURL {
            let capturedImageURL = documentURL.appendingPathComponent("CapturedImage", isDirectory: true)
            if !FileManager.default.fileExists(atPath: capturedImageURL!.path) {
                do {
                    try FileManager.default.createDirectory(at: capturedImageURL!, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            return capturedImageURL! as NSURL
        }
        
        var dateFormat: DateFormatter {
            let format = DateFormatter()
            format.dateFormat = "yyyyMMddHHmmssSSS"
            return format
        }
        
        // Initialize
        init(_ control: ARViewContainer) {
            self.arVC = control
            super.init()
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            /*
            // ???????????????????????? (extension)
            guard let depthMap = frame.depthMap else { return }
            
            // depthMap???CPU?????????
            CVPixelBufferLockBaseAddress(depthMap, .readOnly)
            
            // ???????????????????????????
            let base = CVPixelBufferGetBaseAddress(depthMap)
            // ???????????????
            let width = CVPixelBufferGetWidth(depthMap)
            // ???????????????
            let height = CVPixelBufferGetHeight(depthMap)
            
            // UnsafeMutableRawPointer -> UnsafeMutablePointer<Float32>
            let bindPointer = base?.bindMemory(to: Float32.self, capacity: width * height)
            
            // UnsafeMutablePointer -> UnsafeBufferPointer<Float32>
            let bufPointer = UnsafeBufferPointer(start: bindPointer, count: width * height)
            
            // UnsafeBufferPointer<Float32> -> Array<Float32>
            let depthArray = Array(bufPointer)
            
            // depthMap???CPU????????????
            CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
            
            let fixedArray = depthArray.map( { $0.isNaN ? 0 : $0 })
            print("???? \(fixedArray[width * 10 + 20])")
            */
            
            /*
             capturedImage???????????????1920*1440
             depthMap???????????????256*192
             */
            
            // PNG???????????????depthMap???????????????
            let timestamp = dateFormat.string(from: Date())
        
            let depthMapImage = frame.depthMapImage
            let filenameDepthMap = "depthMap_\(timestamp).png"
            let fileURLDepthMap = depthMapURL.appendingPathComponent(filenameDepthMap)

            if let image = depthMapImage?.pngData() {
                try? image.write(to: fileURLDepthMap!)
            }
            
            // JPEG???????????????capturedImage???????????????
            let capturedImage = frame.capturedImageAsDepthMapScale
            let filenameImage = "capturedImage_\(timestamp).jpeg"
            let fileURLImage = capturedImageURL.appendingPathComponent(filenameImage)
            
            if let image = capturedImage?.jpegData(compressionQuality: 1.0) {
                try? image.write(to: fileURLImage!)
            }
            
        }
    }
}
