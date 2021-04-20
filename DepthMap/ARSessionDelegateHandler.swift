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
        
        var dateFormat: DateFormatter {
            let format = DateFormatter()
            format.dateFormat = "yyyyMMddHHmmssSSS"
            return format
        }
        
        init(_ control: ARViewContainer) {
            self.arVC = control
            super.init()
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
//            guard let depthData = frame.smoothedSceneDepth ?? frame.sceneDepth else {
//                return
//            }
//
//            // 深度マップを取得
//            let depthMap = depthData.depthMap
            
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
            
//            print("depth map size: \(width) * \(height)")
//            let capturedImage = frame.capturedImage
//
//            let imageWidth = CVPixelBufferGetWidth(capturedImage)
//            let imageHeight = CVPixelBufferGetHeight(capturedImage)
//
//            print("image size: \(imageWidth) * \(imageHeight)")
            
            /*
             capturedImageの解像度は1920*1440
             depthMapの解像度は256*192
             */
            
            print(fixedArray[width * 10 + 20])
            
            // CSVファイルに書き出す
            let timestamp = dateFormat.string(from: Date())
            let filename = "depthmap_\(timestamp).csv"
            let fileURL = documentURL.appendingPathComponent(filename)

            guard let filepath = fileURL?.path else {
                return
            }

            let depthMapData = fixedArray.map { String(describing: $0)} .joined(separator: ",")

            do {
                try depthMapData.write(toFile: filepath, atomically: true, encoding: .utf8)
            }
            catch let error as NSError {
                print("Failure to Write File\n\(error)")
            }
            
            // PNGファイルに書き出す
//            let depthMapImage = frame.depthMapImage
//            let filename = "depthmap_\(timestamp).png"
//            let fileURL = documentURL.appendingPathComponent(filename)
//
//            if let image = depthMapImage?.pngData() {
//                try? image.write(to: fileURL!)
//            }
            
        }
    }
}
