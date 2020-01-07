//
//  NetworkManager.swift
//  HiddenCamera
//
//  Created by qbuser on 07/01/20.
//  Copyright © 2020 QBurst. All rights reserved.
//

import Foundation

enum RecogisationStates: String {
    
    //Image Added to server for the first time. The user is created
    case created = "created"
    //The user is recogonised who's face was there in server
    case recogonised = "recognised"
}

class NetworkManager: NSObject {
    
    func getUseridForImage(withImage image:UIImage,isSuccess:@escaping((RecogisationStates, String)->Void),isFailure: @escaping((String)->Void)) {
        
        //Creating URL request to post the image as multipart/form-data
        var request  = URLRequest(url: URL(string: Constants.imageUploadUrl)!)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(parameters: [:],
        boundary: boundary,
        data: image.jpegData(compressionQuality: 1)!,
        mimeType: "image/jpg",
        filename: "image.jpg")
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) {(
            data, response, error) in
            if error != nil
            {
                print("error upload : \(String(describing: error))")
                return
            }

            do
            {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                {
                    if let RequestStatus = json["status"] as? String , RequestStatus == "true" {
                        if let faceId = json["face_id"] as? String, let recogonisationState = json["state"] as? String{
                            isSuccess(recogonisationState == RecogisationStates.created.rawValue ? RecogisationStates.created : RecogisationStates.recogonised, faceId)
                            return
                        }
                    }
                }
                isFailure(Constants.invalidJSON)
            }
            catch
            {
                isFailure(Constants.somethingwentWrongError)
            }
        }
        task.resume()
    }
    
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        return body as Data
    }
    

}

