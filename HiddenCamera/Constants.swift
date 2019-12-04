//
//  Constants.swift
//  FacialBiometric
//
//  Created by Denow Cleetus on 30/09/19.
//  Copyright © 2019 Rija Mairaj. All rights reserved.
//


// MARK: - Constants
enum Constants {
    static let imageVarianceThresholdDefault = 50.0
    static let error = "Error"
    static let ok = "OK"
    static let imageCountToCapture = 5
    
    // MARK: - UserDefaultsKey
    enum UserDefaultsKey {
        static let latitude = "Latitude"
        static let longitude = "Longitude"
        static let imageVarianceThreshold = "imageVarianceThreshold"
    }
    
    enum NotificationNames {
        static let reachability = NSNotification.Name(rawValue: "Reachability")
    }
}

enum FaceDetectionError: Error {
    case noFace
    case multipleFaces
    case lowSize
}
