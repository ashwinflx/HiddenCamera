//
//  HiddenCamera.h
//  HiddenCamera
//
//  Created by qbuser on 21/11/19.
//  Copyright © 2019 QBurst. All rights reserved.
//

import Vision

// MARK: - Error

enum GenericError: Error {
    case invalidData
}

// MARK: -
typealias FaceAngleCompletionWithYawAngleAndRollAngle = (Double?, Double?, Error?) -> Void

extension UIImage {
   
    // WIP, incomplete *****
    var faces: [UIImage] {
        guard let ciimage = CIImage(image: self) else { return [] }
        var orientation: NSNumber {
            switch imageOrientation {
            case .up:            return 1
            case .upMirrored:    return 2
            case .down:          return 3
            case .downMirrored:  return 4
            case .leftMirrored:  return 5
            case .right:         return 6
            case .rightMirrored: return 7
            case .left:          return 8
            }
        }
        return CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])?
            .features(in: ciimage, options: [CIDetectorImageOrientation: orientation])
            .compactMap {
                let rect = $0.bounds.insetBy(dx: -100, dy: -100)
                UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
                defer { UIGraphicsEndImageContext() }
                UIImage(ciImage: ciimage.cropped(to: rect)).draw(in: CGRect(origin: .zero, size: rect.size))
                guard let face = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
                // now that you have your face image you need to properly apply a circle mask to it
                let size = face.size
                let newSize = CGSize(width: size.width, height: size.height)
                UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
                defer { UIGraphicsEndImageContext() }
                guard let cgImage = face.cgImage?.cropping(to: CGRect(origin: CGPoint(x: size.width > size.height ? (size.width-size.height).rounded(.down)/2 : 0, y: size.height > size.width ? (size.height-size.width).rounded(.down)/2 : 0), size: newSize))
                    else { return nil }
                let faceRect = CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height))
                debugPrint("faceRect: \(faceRect)")
                UIImage(cgImage: cgImage).draw(in: faceRect)
                return UIGraphicsGetImageFromCurrentImageContext()
            } ?? []
    }
}

extension UIImage {
    
    func detectFaceAngle(onCompletion: @escaping FaceAngleCompletionWithYawAngleAndRollAngle) {
        if let cgImg = self.cgImage {
            
            let faceRectReq = VNDetectFaceRectanglesRequest { (req, error) in
                if let err = error {
                    debugPrint("error: \(err.localizedDescription)")
                } else {
                    
                    guard let observation = req.results?.first as? VNFaceObservation,
                        let yaw = observation.yaw, let roll = observation.roll else {
                            return
                    }
                    
                    // represents face angle
                    let degreeYaw = Utils.radiansToDegree(yaw.doubleValue)
                    debugPrint("yaw: \(yaw)")
                    debugPrint("yawDegree: \(degreeYaw)")
                    
                    // represents orientation, it will return 180 degree for inverted image and so on
                    let degreeRoll = Utils.radiansToDegree(roll.doubleValue)
                    debugPrint("roll: \(roll)")
                    debugPrint("rollDegree: \(degreeRoll)")
                    
                    onCompletion(degreeYaw, degreeRoll, nil)
                }
            }
            
            let sequenceHandler = VNSequenceRequestHandler()
            do {
                try sequenceHandler.perform([faceRectReq], on: cgImg)
            } catch {
                debugPrint("error : \(error.localizedDescription)")
                onCompletion(nil, nil, error)
            }
        } else {
            onCompletion(nil, nil, GenericError.invalidData)
        }
    }

}
