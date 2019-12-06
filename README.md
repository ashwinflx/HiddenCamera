**** HiddenCamera ****


HiddenCamera help to take secquence of image when it detect users face.


*****Steps to use Hidden Camera*****

- Add pod 'HiddenCamera', :git => 'https://github.com/ashwinflx/HiddenCamera.git', :tag => '1.0.7' to podFile of the project.

    pod 'HiddenCamera', :git => 'https://github.com/ashwinflx/HiddenCamera.git', :tag => '1.0.7'
    
- Import HiddenCamera module to file were we want to use hidden camera.

   import HiddenCamera
    
- Inhert View controller from HiddenCameraVC were you need to use hidden camera.

    class ViewController: FaceCaptureVC
    
- call startRunningSession() function to start the session.

//Imagecount: number of image to be returned. default is 5

//varienceNeeded: The threshold varience with which the image need to be captured. default is 100

  @IBAction func didPressTakePhoto(_ sender: UIButton) {
      //  startRunningSession()
        startCapturingSession(imageCount: 3, varienceNeeded: 75)
    }
    
    
- override  didCapturePhoto(image: UIImage) in view controller which will gives us the images taken.

     override func didCapturePhoto(images: [UIImage]) {
        self.photoPreviewView.image = image.last
    }
    
- add <key>Privacy - Camera Usage Description</key>
<string>APPNAME requires access to your phone’s camera.</string> to infoPlist
