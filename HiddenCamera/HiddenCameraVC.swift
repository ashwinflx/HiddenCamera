
//
//  HiddenCameraVC.swift
//  HiddenCamera
//
//  Created by qbuser on 21/11/19.
//  Copyright © 2019 QBurst. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation

open class HiddenCameraVC: UIViewController, AVCapturePhotoCaptureDelegate{
    
    
    var captureSesssion : AVCaptureSession!
    var cameraOutput : AVCapturePhotoOutput!
    
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
            setUpCameraSession()
        } else {
            requestCameraAccessToProceed()
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.captureSesssion.stopRunning()
        
    }
    
    func requestCameraAccessToProceed() {
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
            [weak self]
            (granted :Bool) -> Void in
            
            if granted == true {
                // User granted
                print("User granted")
                DispatchQueue.main.async(){
                    //Do smth that you need in main thread
                    self?.setUpCameraSession()
                }
            }
            else {
                // User Rejected
                print("User Rejected Camera Access.Hidden camara won't works")
            }
        });
    }
    
    func setUpCameraSession() {
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
            
            self.captureSesssion = AVCaptureSession()
            self.captureSesssion.sessionPreset = AVCaptureSession.Preset.photo
            self.cameraOutput = AVCapturePhotoOutput()
            
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            
            if let input = try? AVCaptureDeviceInput(device: device!) {
                if (self.captureSesssion.canAddInput(input)) {
                    self.captureSesssion.addInput(input)
                    if (self.captureSesssion.canAddOutput(self.cameraOutput)) {
                        self.captureSesssion.addOutput(self.cameraOutput)
                        self.captureSesssion.startRunning()
                    }
                } else {
                    print("issue here : captureSesssion.canAddInput")
                }
            } else {
                print("some problem here")
            }
            
            
        }
    }
    
    public func capturePhoto() {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                kCVPixelBufferWidthKey as String: 600,
                kCVPixelBufferHeightKey as String: 600
            ]
            settings.previewPhotoFormat = previewFormat
            
            self.cameraOutput.capturePhoto(with: settings, delegate: self)
            
            
        }
        
    }
    
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            didCapturePhoto(image: image)
        } else {
            print("some error here")
        }
    }
    
    open func didCapturePhoto(image: UIImage) {
        
        
    }
}




