# HiddenCamera
HiddenCamera help to take selfie of user while actively using the app  

*****Steps to use Hidden Camera*****

- Add pod 'HiddenCamera', :git => 'https://github.com/ashwinflx/HiddenCamera.git', :tag => '1.0.7' to podFile of the project.

    'HiddenCamera', :git => 'https://github.com/ashwinflx/HiddenCamera.git', :tag => '1.0.7'
    
- Import HiddenCamera module to file were we want to use hidden camera.

   import HiddenCamera
    
- Inhert View controller from HiddenCameraVC were you need to use hidden camera.

    class ViewController: FaceCaptureVC
    
- call startCapturingSession() function to take the selfie.

      @IBAction func CapturePhotoTapped(_ sender: Any) {
        startCapturingSession()
     }
     
- override didCapturePhoto(images: [UIImage])  in view controller which will gives us the array of images taken.

     override func didCapturePhoto(images: [UIImage]) {
        DispatchQueue.main.async {
            self.capturedImage.image = images.last
        }
    }
- Added a timer were we can set the time for the image capture session. If it is not set then the session taking video till it takes the required number of photos were it detects the face.
 set sessionDurationLimit in the viewController were we are using HiddenCamera.
 
 ex: sessionDurationLimit = 10
 
 - Can set the number of photos need to be taken by setting imageCount. Default is 5.
 
 - Can set the image varience by imageVarienceNeeded. defaukt is 100. 
    
- add <key>Privacy - Camera Usage Description</key>
<string>APPNAME requires access to your phone’s camera.</string> to infoPlist
