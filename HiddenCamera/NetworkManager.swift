import Foundation

public enum RecogisationStates: String {
    
    //Image Added to server for the first time. The user is created
    case created = "created"
    //The user is recogonised who's face was there in server
    case recogonised = "recognised"
}

class NetworkManager: NSObject {
    
    func getUseridForImage(withImage image:UIImage,isSuccess:@escaping((User)->Void),isFailure: @escaping((String)->Void)) {
        
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
                    if let RequestStatus = json["status"] as? Bool , RequestStatus {
                        if let faceId = json["id"] as? Int, let recogonisationState = json["state"] as? String {
                            
                            let user = User(name: json["name"] as? String, id: faceId, recogisationStates: recogonisationState == RecogisationStates.created.rawValue ? RecogisationStates.created : RecogisationStates.recogonised)
                            isSuccess(user)
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
    
    func postNameForUser(userId:Int, name: String) {
        
        var request  = URLRequest(url: URL(string: Constants.nameUploadurl)!)
        request.httpMethod = "POST"
        let parameters = "{\n\t\"id\": \(userId),\n\t\"name\": \"\(name)\"\n}"
        let postData = parameters.data(using: .utf8)
        request.httpBody = postData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
    }
    
    func postNameForUserId(userId:Int, name: String,isSuccess:@escaping((Bool)->Void)) {
        
        var request  = URLRequest(url: URL(string: Constants.nameUploadurl)!)
        request.httpMethod = "POST"
        let parameters = "{\"id\": \(userId),\"name\": \"\(name)\"}"
        let postData = parameters.data(using: .utf8)
        request.httpBody = postData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) {(
            data, response, error) in
            if error != nil
            {
                print("error upload : \(String(describing: error))")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                {
                    if let RequestStatus = json["status"] as? String,  RequestStatus.lowercased() == "success"{
                        isSuccess(true)
                    }
                } else {
                    isSuccess(false)
                }
            }
            catch {
                isSuccess(false)
            }
        }
        task.resume()
    }
}



open class User: NSObject {
    
    public var name: String?
    public var id: Int?
    public var recogisationStates: RecogisationStates?
    
       init(name: String?,id: Int, recogisationStates:  RecogisationStates) {
        super.init()
        self.name = name
        self.id = id
        self.recogisationStates = recogisationStates
    }
}

