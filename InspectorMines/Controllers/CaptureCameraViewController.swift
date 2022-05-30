//
//  CaptureCameraViewController.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 5/12/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Photos

class CaptureCameraViewController: UIViewController {

    private var spinner: UIActivityIndicatorView!
    var previewContainer = UIView()
    let imagePreview     = UIImageView()
    let locationManager  = CLLocationManager()
    let resumeButton     = UIButton()
    let cameraUnavailableLabel = UILabel()
    var captureButton = CameraButton()
    var previewView   = PreviewView()
    var photoButton   = UIButton()
    var previewButton = UIButton()
    var photoList = [UIImage]()
    let capturePreview = CapturePreviewViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupConstraints()
        self.setupCameraOptionsUI()
        capturePreview.delegate = self

        // Set up the video preview view.
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.session = session

        // Request location authorization so photos and videos can be tagged with their location.
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        /*
         Check the video authorization status. Video access is required and audio
         access is optional. If the user denies audio access, InspectoreMines won't
         record audio during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break

        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. Suspend the session queue to delay session
             setup until the access request has completed.

             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })

        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }

        /*
         Setup the capture session.
         In general, it's not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.

         Don't perform these tasks on the main queue because
         AVCaptureSession.startRunning() is a blocking call, which can
         take a long time. Dispatch session setup to the sessionQueue, so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
        }
        DispatchQueue.main.async {
            self.spinner = UIActivityIndicatorView(style: .large)
            self.spinner.color = .systemBlue
            self.previewView.addSubview(self.spinner)
        }

        captureButton.subscribeButtonAction = { [unowned self] in
            self.capturePhoto(captureButton)
            captureButton.isEnabled = false
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning

            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "InspectorMines doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "InspectorMines", message: message, preferredStyle: .alert)

                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))

                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                                                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                                                          options: [:],
                                                                                          completionHandler: nil)
                    }))

                    self.present(alertController, animated: true, completion: nil)
                }

            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "InspectorMines", message: message, preferredStyle: .alert)

                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))

                    self.present(alertController, animated: true, completion: nil)
                }
            }
            if self.photoList.count > 0 {
                DispatchQueue.main.async {
                    self.previewButton.isHidden = false
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        super.viewWillDisappear(animated)
    }

    func setupUI() {
        view.backgroundColor = .systemGray
        previewContainer = UIView(frame: .zero)
        previewContainer.backgroundColor = .black
        previewContainer.translatesAutoresizingMaskIntoConstraints = false


        previewView.translatesAutoresizingMaskIntoConstraints = false
        self.previewContainer.addSubview(previewView)

        cameraUnavailableLabel.translatesAutoresizingMaskIntoConstraints = false
        cameraUnavailableLabel.text = "Camera Unavailable"
        cameraUnavailableLabel.alpha = 0
        self.view.addSubview(previewContainer)
        previewContainer.addSubview(cameraUnavailableLabel)

        resumeButton.titleLabel?.text = "Resume"
        resumeButton.isHidden = true
        resumeButton.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.addSubview(resumeButton)

        // Floating Button
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "chevron.forward.circle", withConfiguration: largeConfig)
        self.previewButton.setImage(largeBoldDoc, for: .normal)
        self.previewButton.tintColor = .white
        self.previewButton.layer.cornerRadius = 25
        self.previewContainer.addSubview(self.previewButton)
        self.previewButton.translatesAutoresizingMaskIntoConstraints = false
        self.previewButton.layer.shadowColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00).cgColor
        self.previewButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.previewButton.layer.shadowOpacity = 0.2
        self.previewButton.layer.shadowRadius = 4.0
        self.previewButton.layer.masksToBounds = true
        DispatchQueue.main.async {
            self.previewButton.isHidden = true
        }
        self.previewButton.addBlurEffect(style: .dark, cornerRadius: 25, padding: 0)
        self.previewButton.addTarget(self, action: #selector(goToPreviewController(_:)), for: .touchUpInside)
    }

    func setupCameraOptionsUI() {
        let stackViewContainer = UIView(frame: previewContainer.frame)
        let mainStackView  = UIStackView(frame: stackViewContainer.frame)
        mainStackView.sizeToFit()

        mainStackView.axis = .horizontal
        mainStackView.distribution = .equalSpacing
        mainStackView.clipsToBounds = true
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)


        let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .medium)

        let closeSymbol         = UIImage(systemName: "xmark", withConfiguration: configuration)
        let torchSymbolOn       = UIImage(systemName: "bolt.fill", withConfiguration: configuration)
        let torchSymbolOff      = UIImage(systemName: "bolt.slash.fill", withConfiguration: configuration)
        let rotateCameraSymbol  = UIImage(systemName: "arrow.triangle.2.circlepath.camera", withConfiguration: configuration)

        stackViewContainer.translatesAutoresizingMaskIntoConstraints    = false
        mainStackView.translatesAutoresizingMaskIntoConstraints         = false


        let closeButton = UIButton()
        closeButton.setImage(closeSymbol, for: .normal)

        let torchButton = UIButton()
        torchButton.setImage(torchSymbolOn, for: .normal)
        torchButton.setImage(torchSymbolOff, for: .selected)


        photoButton.setImage(rotateCameraSymbol, for: .normal)

        if  UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            // User Interface is Dark
            photoButton.tintColor = .white
            torchButton.tintColor = .white
            closeButton.tintColor = .white
        } else {
            // User Interface is Light
            photoButton.tintColor = .black
            torchButton.tintColor = .black
            closeButton.tintColor = .black
        }

        mainStackView.addArrangedSubview(closeButton)
        mainStackView.addArrangedSubview(torchButton)
        mainStackView.addArrangedSubview(photoButton)

        stackViewContainer.addSubview(mainStackView)
        stackViewContainer.backgroundColor = .clear
        stackViewContainer.layer.cornerRadius = 20

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

        self.previewContainer.addSubview(stackViewContainer)


        NSLayoutConstraint.activate([
            stackViewContainer.topAnchor.constraint(equalTo: previewContainer.topAnchor, constant: 55),
            stackViewContainer.leftAnchor.constraint(equalTo: previewContainer.leftAnchor, constant: 50),
            stackViewContainer.rightAnchor.constraint(equalTo: previewContainer.rightAnchor, constant: -50),
            stackViewContainer.heightAnchor.constraint(equalToConstant: 65)
        ])


        captureButton = CameraButton(frame: CGRect.zero)
        captureButton.clipsToBounds = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.addSubview(captureButton)

        captureButton.heightAnchor.constraint(equalToConstant: 66).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: 66).isActive = true
        captureButton.centerXAnchor.constraint(equalTo: previewContainer.centerXAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: -30).isActive = true
        captureButton.sizeToFit()


        torchButton.addTarget(self,
                              action: #selector(toggleTorch(_:)),
                              for: .touchUpInside)

        photoButton.addTarget(self,
                               action: #selector(changeCamera(_:)), for: .touchUpInside)

        closeButton.addTarget(self, action:
                                #selector(closeButton(_:)), for: .touchUpInside)
    }

    func setupConstraints() {

        previewContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        previewContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        previewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        previewView.topAnchor.constraint(equalTo: previewContainer.topAnchor).isActive = true
        previewView.rightAnchor.constraint(equalTo: previewContainer.rightAnchor).isActive = true
        previewView.leftAnchor.constraint(equalTo: previewContainer.leftAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor).isActive = true

        resumeButton.centerXAnchor.constraint(equalTo: previewContainer.centerXAnchor).isActive = true
        resumeButton.centerYAnchor.constraint(equalTo: previewContainer.centerYAnchor).isActive = true

        cameraUnavailableLabel.centerXAnchor.constraint(equalTo: previewContainer.centerXAnchor).isActive = true
        cameraUnavailableLabel.centerYAnchor.constraint(equalTo: previewContainer.centerYAnchor).isActive = true

        previewButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        previewButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        previewButton.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -20).isActive = true
        previewButton.bottomAnchor.constraint(equalTo: previewContainer.layoutMarginsGuide.bottomAnchor).isActive = true
    }


    // MARK: Session Management

    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }

    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private var selectedSemanticSegmentationMatteTypes = [AVSemanticSegmentationMatte.MatteType]()

    // Communicate with the session and other session objects on this queue.
    private let sessionQueue = DispatchQueue(label: "session queue")

    private var setupResult: SessionSetupResult = .success

    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!

    // Call this on the session queue.
    /// - Tag: ConfigureSession
    private func configureSession() {
        if setupResult != .success {
            return
        }

        session.beginConfiguration()

        /*
         Do not create an AVCaptureMovieFileOutput when setting up the session because
         Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
         */
        session.sessionPreset = .high

        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?

            // Choose the back dual camera, if available, otherwise default to a wide angle camera.

            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
                // If a rear dual camera is not available, default to the rear dual wide camera.
                defaultVideoDevice = dualWideCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If a rear dual wide camera is not available, default to the rear wide angle camera.
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                // If the rear wide angle camera isn't available, default to the front wide angle camera.
                defaultVideoDevice = frontCameraDevice
            }
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput

                DispatchQueue.main.async {
                    /*
                     Dispatch video streaming to the main queue because AVCaptureVideoPreviewLayer is the backing layer for PreviewView.
                     You can manipulate UIView only on the main thread.
                     Note: As an exception to the above rule, it's not necessary to serialize video orientation changes
                     on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.

                     Use the window scene's orientation as the initial video orientation. Subsequent orientation changes are
                     handled by CameraViewController.viewWillTransition(to:with:).
                     */
                    let initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }

        // Add the photo output.
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)

            photoOutput.isHighResolutionCaptureEnabled = true
            //photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
            //photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
            // photoOutput.isPortraitEffectsMatteDeliveryEnabled = photoOutput.isPortraitEffectsMatteDeliverySupported
            photoOutput.enabledSemanticSegmentationMatteTypes = photoOutput.availableSemanticSegmentationMatteTypes
            selectedSemanticSegmentationMatteTypes = photoOutput.availableSemanticSegmentationMatteTypes
            photoOutput.maxPhotoQualityPrioritization = .quality
            // photoOutput.isDepthDataDeliveryEnabled = true
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }

        session.commitConfiguration()
    }


    @objc private func resumeInterruptedSession(_ resumeButton: UIButton) {
        sessionQueue.async {
            /*
             The session might fail to start running, for example, if a phone or FaceTime call is still
             using audio or video. This failure is communicated by the session posting a
             runtime error notification. To avoid repeatedly failing to start the session,
             only try to restart the session in the error handler if you aren't
             trying to resume the session.
             */
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
            if !self.session.isRunning {
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Unable to resume", comment: "Alert message when unable to resume the session running")
                    let alertController = UIAlertController(title: "InspectorMines", message: message, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.resumeButton.isHidden = true
                }
            }
        }
    }

    // MARK: Device Configuration

    private weak var cameraButton: UIButton?


    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInDualWideCamera],
                                                                               mediaType: .video, position: .unspecified)

    /// - Tag: ChangeCamera
    @objc private func changeCamera(_ cameraButton: UIButton) {

        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position

            let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera],
                                                                                   mediaType: .video, position: .back)
            let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],
                                                                                    mediaType: .video, position: .front)
            var newVideoDevice: AVCaptureDevice? = nil

            switch currentPosition {
            case .unspecified, .front:
                newVideoDevice = backVideoDeviceDiscoverySession.devices.first

            case .back:
                newVideoDevice = frontVideoDeviceDiscoverySession.devices.first

            @unknown default:
                print("Unknown capture position. Defaulting to back, dual-camera.")
                newVideoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            }

            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

                    self.session.beginConfiguration()

                    // Remove the existing device input first, because AVCaptureSession doesn't support
                    // simultaneous use of the rear and front cameras.
                    self.session.removeInput(self.videoDeviceInput)

                    if self.session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)

                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }

                    /*
                     Set Live Photo capture and depth data delivery if it's supported. When changing cameras, the
                     `livePhotoCaptureEnabled` and `depthDataDeliveryEnabled` properties of the AVCapturePhotoOutput
                     get set to false when a video device is disconnected from the session. After the new video device is
                     added to the session, re-enable them on the AVCapturePhotoOutput, if supported.
                     */
                    //self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported
                    //self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    //self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = self.photoOutput.isPortraitEffectsMatteDeliverySupported
                    self.photoOutput.enabledSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
                    self.selectedSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes
                    self.photoOutput.maxPhotoQualityPrioritization = .quality

                    self.session.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
            }

        }
    }

    @objc
    private func toggleTorch(_ sender: UIButton) {

        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)

        guard let device = deviceDiscoverySession.devices.first
            else {return}

        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                let on = device.isTorchActive
                if on != true && device.isTorchModeSupported(.on) {
                    try device.setTorchModeOn(level: 1.0)
                } else if device.isTorchModeSupported(.off){
                    device.torchMode = .off
                } else {
                    print("Torch mode is not supported")
                }
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }


    @objc
    private func closeButton(_ sender: UIButton) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }

    @objc
    private func goToPreviewController(_ sender: UIButton) {

        let isEqual = self.photoList.elementsEqual(capturePreview.photoList, by: { $0 == $1} )

        if !isEqual {
            capturePreview.photoList = self.photoList
        }

        capturePreview.modalPresentationStyle = .fullScreen
        capturePreview.navigationItem.backButtonDisplayMode = .minimal
        self.navigationController?.pushViewController(capturePreview, animated: true)
    }


    @objc private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }

    private func focus(with focusMode: AVCaptureDevice.FocusMode,
                       exposureMode: AVCaptureDevice.ExposureMode,
                       at devicePoint: CGPoint,
                       monitorSubjectAreaChange: Bool) {

        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()

                /*
                 Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                 Call set(Focus/Exposure)Mode() to apply the new point of interest.
                 */
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }

                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }

                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }

    // MARK: Capturing Photos

    private let photoOutput = AVCapturePhotoOutput()

    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()

    /// - Tag: CapturePhoto
    @objc private func capturePhoto(_ photoButton: UIButton) {
        /*
         Retrieve the video preview layer's video orientation on the main queue before
         entering the session queue. Do this to ensure that UI elements are accessed on
         the main thread and session configuration is done on the session queue.
         */
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation

        // AudioServicesPlaySystemSound(1108);
        sessionQueue.async {
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            var photoSettings = AVCapturePhotoSettings()

            // Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
            if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }

            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = .auto
            }

            photoSettings.isHighResolutionPhotoEnabled = true
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }


            photoSettings.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliveryEnabled


            if photoSettings.isDepthDataDeliveryEnabled {
                if !self.photoOutput.availableSemanticSegmentationMatteTypes.isEmpty {
                    photoSettings.enabledSemanticSegmentationMatteTypes = self.selectedSemanticSegmentationMatteTypes
                }
            }

            photoSettings.photoQualityPrioritization = .quality

            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
                // Flash the screen to signal that InspectoreMines took a photo.
                DispatchQueue.main.async {
                    self.previewView.videoPreviewLayer.opacity = 0
                    UIView.animate(withDuration: 0.25) {
                        self.previewView.videoPreviewLayer.opacity = 1
                    }
                }
            }, completionHandler: { photoCaptureProcessor in

                DispatchQueue.main.async {
                    if let capturedImage = photoCaptureProcessor.photoData {
                        if let image = UIImage(data: capturedImage) {
                            self.photoList.append(image)
                        }
                    }
                    self.previewButton.sendActions(for: .touchUpInside)
                    self.captureButton.isEnabled = true
                }

                // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
                self.sessionQueue.async {
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                }
            }, photoProcessingHandler: { animate in
                // Animates a spinner while photo is processing
                DispatchQueue.main.async {
                    if animate {
                        self.spinner.hidesWhenStopped = true
                        self.spinner.center = CGPoint(x: self.previewView.frame.size.width / 2.0, y: self.previewView.frame.size.height / 2.0)
                        self.spinner.startAnimating()
                    } else {
                        self.spinner.stopAnimating()
                    }
                }
            }
            )

            // Specify the location the photo was taken
            photoCaptureProcessor.location = self.locationManager.location

            // The photo output holds a weak reference to the photo capture delegate and stores it in an array to maintain a strong reference.
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
        }
    }

    // MARK: KVO and Notifications

    private var keyValueObservations = [NSKeyValueObservation]()
    /// - Tag: ObserveInterruption
    private func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                self.cameraButton?.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
                self.photoButton.isEnabled = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)

        let systemPressureStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoDeviceInput.device)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)

        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: session)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)

        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }

    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }

    /// - Tag: HandleRuntimeError
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }

        print("Capture session runtime error: \(error)")
        // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {
                    DispatchQueue.main.async {
                        self.resumeButton.isHidden = false
                    }
                }
            }
        } else {
            resumeButton.isHidden = false
        }
    }


    /// - Tag: HandleSystemPressure
    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        /*
         The frame rates used here are only for demonstration purposes.
         Your frame rate throttling may be different depending on your app's camera configuration.
         */
        let pressureLevel = systemPressureState.level
        print(pressureLevel.rawValue)
    }


    /// - Tag: HandleInterruption
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        /*
         In some scenarios you want to enable the user to resume the session.
         For example, if music playback is initiated from Control Center while
         using InspectoreMines, then the user can let InspectoreMines resume
         the session running, which will stop music playback. Note that stopping
         music playback in Control Center will not automatically resume the session.
         Also note that it's not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")

            var showResumeButton = false
            if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
                showResumeButton = true
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // Fade-in a label to inform the user that the camera is unavailable.
                cameraUnavailableLabel.alpha = 0
                cameraUnavailableLabel.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.cameraUnavailableLabel.alpha = 1
                }
            } else if reason == .videoDeviceNotAvailableDueToSystemPressure {
                print("Session stopped running due to shutdown system pressure level.")
            }
            if showResumeButton {
                // Fade-in a button to enable the user to try to resume the session running.
                resumeButton.alpha = 0
                resumeButton.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.resumeButton.alpha = 1
                }
            }
        }
    }

    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")

        if !resumeButton.isHidden {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.resumeButton.alpha = 0
            }, completion: { _ in
                self.resumeButton.isHidden = true
            })
        }
        if !cameraUnavailableLabel.isHidden {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.cameraUnavailableLabel.alpha = 0
            }, completion: { _ in
                self.cameraUnavailableLabel.isHidden = true
            }
            )
        }
    }

    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
    }
}


extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {

        var uniqueDevicePositions = [AVCaptureDevice.Position]()

        for device in devices where !uniqueDevicePositions.contains(device.position) {
            uniqueDevicePositions.append(device.position)
        }
        return uniqueDevicePositions.count
    }
}

extension CaptureCameraViewController: CapturePreviewControllerDelegate {

    func removeSelectedPhoto(targetImage targetIndex: Int) {
        print(targetIndex)
        if self.photoList.count < targetIndex {
            return
        }
        else {
            self.photoList.remove(at: targetIndex)

        }

//        for (index, object) in self.photoList.enumerated() {
//            if targetPhoto == self.photoList[index] {
//                print("Item at \(index): \(object)")
//            }
//        }

//        for element in 0..<self.photoList.count {
//            print(element)
//        }
//        if self.photoList.last == targetPhoto {
//            self.photoList.removeLast()
//            print("Hit")
//        }
    }

    func willTakeAditionalPhotos(withImage image: UIImage) {
        //self.photoList.append(image)
    }
}

