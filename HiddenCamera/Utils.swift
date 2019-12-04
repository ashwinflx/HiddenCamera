//
//  Utils.swift
//  FacialBiometric
//
//  Created by Denow Cleetus on 30/09/static func19.
//  Copyright © 2019 Rija Mairaj. All rights reserved.
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

    static func imageVarianceThreshold() -> Double {
        let valFromDefaults = UserDefaults.standard.double(forKey: Constants.UserDefaultsKey.imageVarianceThreshold)
        let val = (valFromDefaults == 0) ? Constants.imageVarianceThresholdDefault : valFromDefaults

        return val
    }
}
