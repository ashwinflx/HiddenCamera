**** HiddenCamera ****


HiddenCamera help to take secquence of image when it detect users face.


*****Steps to use Hidden Camera*****

- Add pod 'HiddenCamera', :git => 'https://github.com/ashwinflx/HiddenCamera.git', :tag => '1.0.6' to podFile of the project.

    pod 'HiddenCamera', :git => 'https://github.com/ashwinflx/HiddenCamera.git', :tag => '1.0.6'
    
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
