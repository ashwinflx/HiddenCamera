# HiddenCamera
HiddenCamera help to take selfie of user while actively using the app  

Steps to use Hidden Camera
- Add pod 'HiddenCamera', :git => 'https://github.com/ashwinflx/HiddenCamera.git', :tag => '1.0.0' to podFile of the project.
- Import HiddenCamera module to file were we want to use hidden camera.
- Inhert View controller from HiddenCameraVC were you need to use hidden camera.
- call capturePhoto() function to take the selfie.
- override  didCapturePhoto(image: UIImage) in view controller which will gives us the image taken.


