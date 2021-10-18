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
            // 深度マップを取得 (extension)
            guard let depthMap = frame.depthMap else { return }
            
            // depthMapをCPUに配置
            CVPixelBufferLockBaseAddress(depthMap, .readOnly)
            
            // 先頭ポインタを取得
            let base = CVPixelBufferGetBaseAddress(depthMap)
            // 横幅の取得
            let width = CVPixelBufferGetWidth(depthMap)
            // 縦幅の取得
            let height = CVPixelBufferGetHeight(depthMap)
            
            // UnsafeMutableRawPointer -> UnsafeMutablePointer<Float32>
            let bindPointer = base?.bindMemory(to: Float32.self, capacity: width * height)
            
            // UnsafeMutablePointer -> UnsafeBufferPointer<Float32>
            let bufPointer = UnsafeBufferPointer(start: bindPointer, count: width * height)
            
            // UnsafeBufferPointer<Float32> -> Array<Float32>
            let depthArray = Array(bufPointer)
            
            // depthMapをCPUから解放
            CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
            
            let fixedArray = depthArray.map( { $0.isNaN ? 0 : $0 })
            print("🎛 \(fixedArray[width * 10 + 20])")
            */
            
            /*
             capturedImageの解像度は1920*1440
             depthMapの解像度は256*192
             */
            
            // PNGファイルにdepthMapを書き出す
            let timestamp = dateFormat.string(from: Date())
        
            let depthMapImage = frame.depthMapImage
            let filenameDepthMap = "depthMap_\(timestamp).png"
            let fileURLDepthMap = depthMapURL.appendingPathComponent(filenameDepthMap)

            if let image = depthMapImage?.pngData() {
                try? image.write(to: fileURLDepthMap!)
            }
            
            // JPEGファイルにcapturedImageを書き出す
            let capturedImage = frame.capturedImageAsDepthMapScale
            let filenameImage = "capturedImage_\(timestamp).jpeg"
            let fileURLImage = capturedImageURL.appendingPathComponent(filenameImage)
            
            if let image = capturedImage?.jpegData(compressionQuality: 1.0) {
                try? image.write(to: fileURLImage!)
            }
            
        }
    }
}
