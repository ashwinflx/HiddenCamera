### Features

HiddenCamera helps to identify the user by capturing their face.

# Hidden Camera

## Steps to use Hidden Camera

* Add the below 'HiddenCamera' pod to podFile.

    `pod 'HiddenCamera', :git => 'https://github.com/ashwinflx/HiddenCamera.git', :tag => '2.0.4'`

* Import HiddenCamera module to file were we want to use hidden camera.

    `import HiddenCamera`
    
* Declare FaceCapture object globally in the controlller were we are using the HiddenCamera.

    `var faceDetector:FaceCapture?`
    
* Assign value for the object and call the getUserIdByFace inside FaceCapture to get the users id.

    ```Swift
    faceDetector = FaceCapture()
    faceDetector?.getUserIdByFace(delegate: self)
    ```
* Conform to FaceDetectorProtocol,  didRecieveFaceIdForUser will give the user details

    ```Swift
    func didRecieveFaceIdForUser(userDetails: User?) {
        if let details = userDetails, let id = details.id {
            progressLabel.text = "Face id: \(id)"
        }
    }
    ```
 
 #### note
- add <key>Privacy - Camera Usage Description</key>
<string>APPNAME requires access to your phone’s camera.</string> to infoPlist

License
----

MIT
