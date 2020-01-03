//
//  HiddenCamera.h
//  HiddenCamera
//
//  Created by qbuser on 21/11/19.
//  Copyright © 2019 QBurst. All rights reserved.
//
import UIKit
import Vision
import AVFoundation


public protocol FaceDetectorProtocol: class {
    func didCapturePhoto(images: [UIImage])
}

open class FaceCapture: NSObject {
    
    //Properties
    private let faceDetectionRequest = VNSequenceRequestHandler()
    private let faceDetection = VNDetectFaceRectanglesRequest()
    
    private var operationQueueImgDraw = OperationQueue()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    
    private let captureSession = AVCaptureSession()
    private var captureDeviceInput: AVCaptureDeviceInput? = nil
    private var videoDataOutput: AVCaptureVideoDataOutput? = nil
    
    private var isRunning: Bool = false
    private var videoOutputAdded: Bool = false
    
    var sessionDurationLimit: Double? = nil
    weak var delegate:FaceDetectorProtocol?
    
    private var capturedImages = [UIImage]()
    private var imageCount: Int = Constants.imageCountToCapture
    private var imageVarienceNeeded = Constants.imageVarianceThresholdDefault
    
    
    
    deinit {
        self.stopRunningSession()
    }
    
    public func startCaptureSession(delegate: UIViewController,imageCount: Int? = nil, varienceNeeded: Double? = nil  ) {
        
        self.imageCount = imageCount ?? Constants.imageCountToCapture
        self.imageVarienceNeeded = varienceNeeded ?? Constants.imageVarianceThresholdDefault
        self.capturedImages.removeAll()
        operationQueueImgDraw.qualityOfService = .default
        operationQueueImgDraw.maxConcurrentOperationCount = 1
        self.delegate = delegate as? FaceDetectorProtocol
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }
    
    
    func configureSession() {
        
        captureSession.sessionPreset = .high
        let position: AVCaptureDevice.Position = AVCaptureDevice.Position.front
        
        do {
            let discoverDevices = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position)
            guard let cameraDevice = discoverDevices.devices.first else {
                print("No cameras available")
                return
                
            }
            if(cameraDevice.isFocusModeSupported(.continuousAutoFocus)) {
                try! cameraDevice.lockForConfiguration()
                cameraDevice.focusMode = .continuousAutoFocus
                cameraDevice.unlockForConfiguration()
            }
            
            addDeviceInput(device: cameraDevice)
            videoOutputAdded = addVideoDataOutput()
            if videoOutputAdded {
                startCapturingSession()
            }
        }
    }
    
    public func startCapturingSession(imageCount: Int? = nil, varienceNeeded: Double? = nil ) {
        if videoOutputAdded {
            startRunningSession()
        }
    }

    
    func addDeviceInput(device: AVCaptureDevice) {
        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(captureDeviceInput!) {
                captureSession.addInput(captureDeviceInput!)
            }
        }
        catch {
            print("Error in adding device input")
        }
    }
    
    func addVideoDataOutput() -> Bool {
        print("Add Video Output")
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput?.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)]
        if captureSession.canAddOutput(videoDataOutput!) {
            videoDataOutput?.alwaysDiscardsLateVideoFrames = true
            videoDataOutput?.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            captureSession.addOutput(videoDataOutput!)
            
            guard let connection = self.videoDataOutput?.connection(with: AVMediaType.video),
                connection.isVideoOrientationSupported else {
                    return false
            }
            connection.videoOrientation = .portrait
        } else {
            print("Could not add video output to the session")
            return false
        }
        return true
    }
    
    
    func startRunningSession() {
        if !isRunning {
            captureSession.startRunning()
            isRunning = true
            print("Start Running Session")
        }
    }
    
    @objc func captureSessionTimeout() {
        stopRunningSession()
        
    }
    
    func stopRunningSession() {
        if isRunning {
            captureSession.stopRunning()
            isRunning = false
            print("Stop Running Session")
        }
    }
    
}


extension FaceCapture : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as? [CIImageOption : Any])
        let ciImageWithOrientation = ciImage.oriented(forExifOrientation: Int32(UIImage.Orientation.left.rawValue))
        
        
        do {
            _ = try captureOnFaceDetect(on: ciImageWithOrientation)
        }
        catch FaceDetectionError.multipleFaces {
            print("FaceDetectionError.multipleFaces")
        } catch FaceDetectionError.lowSize {
            debugPrint("FaceDetectionError.lowSize")
        } catch FaceDetectionError.noFace {
            debugPrint("FaceDetectionError.noFace")
        } catch {
            debugPrint("Error: \(error.localizedDescription)")
        }
    }
    
    func captureOnFaceDetect(on image: CIImage) throws {
        try? faceDetectionRequest.perform([faceDetection], on: image)
        if let results = faceDetection.results as? [VNFaceObservation], results.count > 0 {
            if let face = results.first, results.count == 1 {
                operationQueueImgDraw.addOperation { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    Utils.detectFaceAngleFromFaceObservation(face: face, onCompletion: { (yawDegree, rollDegree, error) in
                        guard let yaw = yawDegree, let roll = rollDegree else {
                            debugPrint("Error: \(String(describing: error?.localizedDescription))")
                            return
                        }
                        
                        if yaw == 0 && roll == 0 {
                            
                            // Since OpenCV function is not accepting 'UIImage(ciImage: image)'
                            let originalImage = UIImage(ciImage: image)
                            UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
                            originalImage.draw(in: CGRect(origin: .zero, size: originalImage.size))
                            let newDrawnImage = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            
                            if let img = newDrawnImage {
                                let variance = OpenCVWrapper.imageVariance(img)
                                debugPrint("variance: \(variance)")
                                if variance > strongSelf.imageVarienceNeeded {
                                    DispatchQueue.main.async {
                                        strongSelf.operationQueueImgDraw.cancelAllOperations()
                                        debugPrint("eligible image")
                                        debugPrint("face yaw: \(String(describing: yaw))")
                                        if strongSelf.isRunning {
                                            strongSelf.stopRunningSession()
                                            print("Image Captured")
                                            strongSelf.detectAndCropfaceImage(on: image)
                                        }
                                    }
                                }
                            }
                        } else {
                            debugPrint("face angle != 0")
                        }
                    })
                }
            } else if results.count > 1 {
                throw FaceDetectionError.multipleFaces
            }
        }
    }
    
    private func detectAndCropfaceImage(on image: CIImage) {
        try? faceDetectionRequest.perform([faceDetection], on: image)
        if let results = faceDetection.results as? [VNFaceObservation], results.count > 0 {
            let orginalImage = Utils.convert(cmage: image)
            for face in results {
                let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -orginalImage.size.height)
                let translate = CGAffineTransform.identity.scaledBy(x: orginalImage.size.width, y: orginalImage.size.height)
                // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
                var facebounds = face.boundingBox.applying(translate).applying(transform)
                facebounds.size.height += 100
                let cropImage = orginalImage.crop(rect: facebounds)
                self.updateListWithImageCaptured(image: cropImage)
            }
        }
    }
    
    
    func updateListWithImageCaptured(image: UIImage) {
        self.capturedImages.append(image)
        if (self.capturedImages.count <= self.imageCount) {
            sessionQueue.asyncAfter(deadline: .now() + 0.5) {
                [unowned self] in
                self.startRunningSession()
            }
        } else {
            delegate?.didCapturePhoto(images: self.capturedImages)
        }
    }
}

