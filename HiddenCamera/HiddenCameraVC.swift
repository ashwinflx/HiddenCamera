
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
    
    
    var captureSession : AVCaptureSession!
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
        
        self.captureSession.stopRunning()
        
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
        
        self.captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .front)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
        
        cameraOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(cameraOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(cameraOutput)
        captureSession.commitConfiguration()
        
        self.captureSession.startRunning()
    }
    
    public func capturePhoto() {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType
        ]
        settings.previewPhotoFormat = previewFormat
        self.cameraOutput.capturePhoto(with: settings, delegate: self)
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




