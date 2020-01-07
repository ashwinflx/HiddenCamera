//
//  HiddenCamera.h
//  HiddenCamera
//
//  Created by qbuser on 21/11/19.
//  Copyright © 2019 QBurst. All rights reserved.
//

// MARK: - Constants
enum Constants {
    static let imageVarianceThresholdDefault = 50.0
    static let error = "Error"
    static let ok = "OK"
    static let imageCountToCapture = 5
    static let invalidJSON = "Invalid Json"
    static let somethingwentWrongError = "Something went wrong"
    
    //urls
    static let imageUploadUrl = "http://0.0.0.0:5000/upload"
    
    enum NotificationNames {
        static let reachability = NSNotification.Name(rawValue: "Reachability")
    }
}

enum FaceDetectionError: Error {
    case noFace
    case multipleFaces
    case lowSize
}
