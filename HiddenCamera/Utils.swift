//
//  HiddenCamera.h
//  HiddenCamera
//
//  Created by qbuser on 21/11/19.
//  Copyright © 2019 QBurst. All rights reserved.
//


import Vision

class Utils {

    static func detectFaceAngleFromFaceObservation(face: VNFaceObservation?, onCompletion: @escaping FaceAngleCompletionWithYawAngleAndRollAngle) {
        guard let yaw = face?.yaw?.doubleValue, let roll = face?.roll?.doubleValue else {
            onCompletion(nil, nil, GenericError.invalidData)
            return
        }
        
        let yawDegree = Utils.radiansToDegree(yaw)
        let rollDegree = Utils.radiansToDegree(roll)
        onCompletion(yawDegree, rollDegree, nil)
    }
    
    static func radiansToDegree(_ angleInRad: Double) -> Double {
        let angleDegree = angleInRad * 180.0 / Double.pi
        return angleDegree
    }
}
