# HiddenCamera
HiddenCamera help to take selfie of user while actively using the app  

*****Steps to use Hidden Camera*****

- Add pod 'HiddenCamera', :git => 'https://github.com/ashwinflx/HiddenCamera.git', :tag => '1.0.2' to podFile of the project.
    HiddenCamera', :git => 'https://github.com/ashwinflx/HiddenCamera.git', :tag => '1.0.2
    
- Import HiddenCamera module to file were we want to use hidden camera.

   import HiddenCamera
    
- Inhert View controller from HiddenCameraVC were you need to use hidden camera.

    class ViewController: HiddenCameraVC
    
- call capturePhoto() function to take the selfie.

      @IBAction func CapturePhotoTapped(_ sender: Any) {
        capturePhoto()
     }
     
- override  didCapturePhoto(image: UIImage) in view controller which will gives us the image taken.

     override func didCapturePhoto(image: UIImage) {
        self.photoPreviewView.image = image
    }
    
- add <key>Privacy - Camera Usage Description</key>
<string>APPNAME requires access to your phone’s camera.</string> to infoPlist
