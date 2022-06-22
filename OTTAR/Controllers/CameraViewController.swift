//
//  CameraViewController.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 11/28/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import SafariServices
//import FirebaseCore
//import FirebaseFirestore
//import FirebaseFirestoreSwift


// TODO:
// Create animation when taking a photo

class CameraViewController: UIViewController {

    var captureSession = AVCaptureSession()
    var previewView = UIView()
    var captureButton = CameraButton()
    var usingFrontCamera: Bool = false
//    var db: Firestore!
    private let photoOutput = AVCapturePhotoOutput()
    private var photosTakens: [String] = []


    lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
        guard error == nil else {
            self.showAlert(withTitle: "Barcode error", message: error?.localizedDescription ?? "error")
            return
        }
        self.processClassification(request)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        checkPermissions()
        initView()
        setupCameraLiveView()
        setupCameraOptions()

        // [START setup]
//        let settings = FirestoreSettings()
//
//        Firestore.firestore().settings = settings
//        // [END setup]
//        db = Firestore.firestore()

        captureButton.subscribeButtonAction = { [unowned self] in
            self.handleTakePhoto()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // TODO: Stop Session
        captureSession.stopRunning()
    }

    // MARK: - Camera
    private func checkPermissions() {
        // TODO: Checking permissions
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [self] granted in
                if !granted {
                    self.showPermissionsAlert()
                }
            }
        case .denied, .restricted:
            showPermissionsAlert()
        default:
            return
        }
    }

    private func initView() {
        previewView = UIView(frame: CGRect(x: 0,
                                           y: 0,
                                           width: view.frame.width,
                                           height: view.frame.height))
        view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.clipsToBounds = true
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        previewView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        previewView.contentMode = UIView.ContentMode.scaleAspectFit

    }

    private func setupCameraOptions() {

        let stackViewContainer = UIView(frame: previewView.frame)
        let mainStackView  = UIStackView(frame: stackViewContainer.frame)
        mainStackView.sizeToFit()

        mainStackView.axis = .horizontal
        mainStackView.distribution = .equalSpacing
        mainStackView.clipsToBounds = true
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)


        let configuration = UIImage.SymbolConfiguration(pointSize: 35, weight: .light, scale: .medium)

        let closeSymbol         = UIImage(systemName: "xmark", withConfiguration: configuration)
        let torchSymbolOn       = UIImage(systemName: "bolt.fill", withConfiguration: configuration)
        let torchSymbolOff      = UIImage(systemName: "bolt.slash.fill", withConfiguration: configuration)
        let rotateCameraSymbol  = UIImage(systemName: "arrow.triangle.2.circlepath.camera", withConfiguration: configuration)

        stackViewContainer.translatesAutoresizingMaskIntoConstraints    = false
        mainStackView.translatesAutoresizingMaskIntoConstraints         = false


        let closeButton = UIButton()
        closeButton.setImage(closeSymbol, for: .normal)
        closeButton.tintColor = .black

        let torchButton = UIButton()
        torchButton.setImage(torchSymbolOn, for: .normal)
        torchButton.setImage(torchSymbolOff, for: .selected)
        torchButton.tintColor = .black

        let rotateButton = UIButton()
        rotateButton.setImage(rotateCameraSymbol, for: .normal)
        rotateButton.tintColor = .black

        mainStackView.addArrangedSubview(closeButton)
        mainStackView.addArrangedSubview(torchButton)
        mainStackView.addArrangedSubview(rotateButton)

        stackViewContainer.addSubview(mainStackView)
        stackViewContainer.backgroundColor = .clear
        stackViewContainer.layer.cornerRadius = 20


        torchButton.addTarget(self,
                              action: #selector(toggleTorch(_:)),
                              for: .touchUpInside)

        rotateButton.addTarget(self,
                               action: #selector(toggleCamera(_:)), for: .touchUpInside)

        closeButton.addTarget(self, action:
                                #selector(closeButton(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: stackViewContainer.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: stackViewContainer.leadingAnchor),
            mainStackView.heightAnchor.constraint(equalTo: stackViewContainer.heightAnchor),
            mainStackView.widthAnchor.constraint(equalTo: stackViewContainer.widthAnchor)
        ])

        let blurEffect = UIBlurEffect(style: .prominent)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurredEffectView.layer.cornerRadius = 20
        blurredEffectView.layer.masksToBounds = true

        stackViewContainer.insertSubview(blurredEffectView, at: 0)

        NSLayoutConstraint.activate([
            blurredEffectView.topAnchor.constraint(equalTo: stackViewContainer.topAnchor),
            blurredEffectView.leadingAnchor.constraint(equalTo: stackViewContainer.leadingAnchor),
            blurredEffectView.heightAnchor.constraint(equalTo: stackViewContainer.heightAnchor),
            blurredEffectView.widthAnchor.constraint(equalTo: stackViewContainer.widthAnchor)
        ])

        self.previewView.addSubview(stackViewContainer)


        NSLayoutConstraint.activate([
            stackViewContainer.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 55),
            stackViewContainer.leftAnchor.constraint(equalTo: previewView.leftAnchor, constant: 30),
            stackViewContainer.rightAnchor.constraint(equalTo: previewView.rightAnchor, constant: -30),
            stackViewContainer.heightAnchor.constraint(equalToConstant: 75)
        ])


        captureButton = CameraButton(frame: CGRect.zero)
        captureButton.clipsToBounds = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        previewView.addSubview(captureButton)

        captureButton.heightAnchor.constraint(equalToConstant: 66).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: 66).isActive = true
        captureButton.centerXAnchor.constraint(equalTo: previewView.centerXAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -30).isActive = true

        captureButton.sizeToFit()
    }

    @objc private func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    @objc
    private func closeButton(_ sender: UIButton) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }

    @objc
    private func toggleCamera(_ sender: UIButton) {

        //Remove existing input
        guard let currentCameraInput: AVCaptureInput = captureSession.inputs.first else {
            return
        }

        //Indicate that some changes will be made to the session
        captureSession.beginConfiguration()
        captureSession.removeInput(currentCameraInput)

        //Get new input
        var newCamera: AVCaptureDevice! = nil
        if let input = currentCameraInput as? AVCaptureDeviceInput {
            if (input.device.position == .back) {
                newCamera = cameraWithPosition(position: .front)
            } else {
                newCamera = cameraWithPosition(position: .back)
            }
        }

        //Add input to session
        var err: NSError?
        var newVideoInput: AVCaptureDeviceInput!
        do {
            newVideoInput = try AVCaptureDeviceInput(device: newCamera)
        } catch let err1 as NSError {
            err = err1
            newVideoInput = nil
        }

        if newVideoInput == nil || err != nil {
            print("Error creating capture device input: \(err?.localizedDescription)")
        } else {
            captureSession.addInput(newVideoInput)
        }

        //Commit all the configuration changes at once
        captureSession.commitConfiguration()
    }

    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }

        return nil
    }

    @objc
    private func toggleTorch(_ sender: UIButton) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if !device.isTorchActive {
                    device.torchMode = .on
                    sender.isSelected = true
                } else {
                    device.torchMode = .off
                    sender.isSelected = false
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }

    private func setupCameraLiveView() {
        // TODO: Setup captureSession
        captureSession.sessionPreset = .hd1920x1080

        // TODO: Add input
        let videoDevice = AVCaptureDevice
            .default(.builtInWideAngleCamera, for: .video, position: .back)

        guard
            let device = videoDevice,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput) else {
                showAlert(
                    withTitle: "Cannot Find Camera",
                    message: "There seems to be a problem with the camera on your device.")
                return
            }

        if captureSession.canAddOutput(photoOutput) {
             captureSession.addOutput(photoOutput)
         }
        
        captureSession.addInput(videoDeviceInput)

        // TODO: Add output
        let captureOutput = AVCaptureVideoDataOutput()
        // TODO: Set video sample rate
        captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        captureSession.addOutput(captureOutput)

        configurePreviewLayer()

        // TODO: Run session
        captureSession.startRunning()
    }

    // MARK: - Vision
    func processClassification(_ request: VNRequest) {
        // TODO: Main logic
        guard let barcodes = request.results else { return }
        DispatchQueue.main.async { [self] in
            if captureSession.isRunning {
                view.layer.sublayers?.removeSubrange(1...)

                for barcode in barcodes {
                    guard
                        // TODO: Check for QR Code symbology and confidence score
                        let potentialQRCode = barcode as? VNBarcodeObservation,
                        potentialQRCode.symbology == .QR,
                        potentialQRCode.confidence > 0.9
                    else { return }

                    observationHandler(payload: potentialQRCode.payloadStringValue)
                }
            }
        }
    }

    // MARK: - Handler
    func observationHandler(payload: String?) {
        // TODO: Open it in Safari
        guard
            let payloadString = payload,
            let url = URL(string: payloadString),
            ["http", "https"].contains(url.scheme?.lowercased())
        else { return }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true

        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.delegate = self
        present(safariVC, animated: true)
    }

}



// MARK: - AVCaptureDelegation
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // TODO: Live Vision
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .right)

        do {
            try imageRequestHandler.perform([detectBarcodeRequest])
        } catch {
            print(error)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        AudioServicesPlaySystemSound(1108);
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)

        if let image = previewImage {
            let b64 = self.convertImageToBase64String(img: image)
            photosTakens.append(b64)
        }

//        if let image = previewImage {
//            let b64 = self.convertImageToBase64String(img: image)
//
//            let date = Date()
//            let df = DateFormatter()
//            df.dateFormat = "yyyy-MM-dd HH:mm"
//            let dateString = df.string(from: date)
//            db.collection("captures").document("capture: \(date)").setData([
//                "capture_date": dateString,
//                "image_encoded": b64
//            ]) { err in
//                if let err = err {
//                    print("Error writing document: \(err)")
//                } else {
//                    print("Document successfully written!")
//                }
//            }
//        }
    }

    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
    }
}

// MARK: - Helper
extension CameraViewController {
    private func configurePreviewLayer() {
        //    let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //    cameraPreviewLayer.videoGravity = .resizeAspectFill
        //    cameraPreviewLayer.connection?.videoOrientation = .portrait
        //    cameraPreviewLayer.frame = view.frame
        //    view.layer.insertSublayer(cameraPreviewLayer, at: 0)

        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.connection?.videoOrientation = .portrait
        let rootLayer: CALayer = self.previewView.layer
        rootLayer.masksToBounds = true
        cameraPreviewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(cameraPreviewLayer)

    }

    private func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }

    private func showPermissionsAlert() {
        showAlert(
            withTitle: "Camera Permissions",
            message: "Please open Settings and grant permission for this app to use your camera.")
    }
}

// MARK: - SafariViewControllerDelegate
extension CameraViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        captureSession.startRunning()
    }
}
