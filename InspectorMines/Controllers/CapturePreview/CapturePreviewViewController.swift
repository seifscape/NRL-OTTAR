//
//  CapturePreviewViewController.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 5/12/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import FINNBottomSheet


protocol CapturePreviewControllerDelegate: AnyObject {
    func willTakeAditionalPhotos(withImage image: UIImage)
    func removeLastPhoto(targetImage targetPhoto: UIImage)
}

class CapturePreviewViewController: UIViewController {

    var previewContainer = UIView()
    var imagePreview     = UIImageView()
    var safeArea: UILayoutGuide!
    weak var delegate: CapturePreviewControllerDelegate?

    var photoList = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.backButtonTitle = ""
        self.navigationItem.backBarButtonItem?.tintColor = .white
        self.navigationController?.navigationBar.tintColor = .white

        self.setupUI()
        self.setupConstraints()
        self.displayBottomOptions()
        self.imagePreview.image = photoList.last

        BottomSheetView.cameraButton.addTarget(self, action: #selector(addMorePhotos(_:)), for: .touchUpInside)
        BottomSheetView.checkmarkButton.addTarget(self, action: #selector(completeCapture(_:)), for: .touchUpInside)
        BottomSheetView.cancelButton.addTarget(self, action: #selector(removePhoto(_:)), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func setupUI() {
        view.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        previewContainer = UIView(frame: .zero)
        previewContainer.backgroundColor = .gray
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        safeArea = self.view.layoutMarginsGuide
        imagePreview.translatesAutoresizingMaskIntoConstraints = false
        imagePreview.contentMode = .scaleToFill
        view.addSubview(previewContainer)
        previewContainer.addSubview(imagePreview)
    }

    func setupConstraints() {
        previewContainer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 50).isActive = true
        previewContainer.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -20).isActive = true
        previewContainer.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 20).isActive = true
        previewContainer.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -100).isActive = true

        imagePreview.topAnchor.constraint(equalTo: previewContainer.topAnchor).isActive = true
        imagePreview.leftAnchor.constraint(equalTo: previewContainer.leftAnchor).isActive = true
        imagePreview.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor).isActive = true
        imagePreview.rightAnchor.constraint(equalTo: previewContainer.rightAnchor).isActive = true
    }

    private func displayBottomOptions() {
        let bottomSheetView = BottomSheetView(
            contentView: UIView.makeView(withTitle: "UIView"),
            contentHeights: [100, 100]
        )
        bottomSheetView.present(in: view)
    }

    @objc func addMorePhotos(_ sender: UIButton) {

        if let image = imagePreview.image {
            delegate?.willTakeAditionalPhotos(withImage: image)
        }
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func removePhoto(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        defer {
            sender.isUserInteractionEnabled = true
        }
        delegate?.removeLastPhoto(targetImage: self.photoList.last ?? UIImage())
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            sender.isEnabled = true
            return
        }
    }

    @objc func completeCapture(_ sender: UIButton) {
        let captureReview = CaptureReviewViewController()
        captureReview.listOfPhotos = self.photoList
        DispatchQueue.main.async {
            // https://stackoverflow.com/a/53496233
            guard self.navigationController?.topViewController == self else { return }
            self.navigationController?.pushViewController(captureReview, animated: true)
        }
    }
}

// MARK: - Private extensions

private extension UIView {

    static let cameraButton = UIButton()
    static let checkmarkButton = UIButton()
    static let cancelButton = UIButton()


    static func makeView(withTitle title: String? = nil) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = .center
        view.addSubview(label)

        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .white
        borderView.alpha = 0.4
        view.addSubview(borderView)

        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .medium)
        let addSymbol = UIImage(systemName: "camera.badge.ellipsis", withConfiguration: configuration)
        let checkmarkSymbol = UIImage(systemName: "checkmark.circle", withConfiguration: configuration)
        let trashSymbol = UIImage(systemName: "trash.circle", withConfiguration: configuration)

        if  UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            // User Interface is Dark
            cameraButton.tintColor = .white
            checkmarkButton.tintColor = .white
            cancelButton.tintColor = .white
            label.textColor = .white
        } else {
            // User Interface is Light
            cameraButton.tintColor = .black
            checkmarkButton.tintColor = .black
            cancelButton.tintColor = .black
            label.textColor = .black
        }


        checkmarkButton.setImage(checkmarkSymbol, for: .normal)
        view.addSubview(checkmarkButton)

        cameraButton.setImage(addSymbol, for: .normal)
        view.addSubview(cameraButton)

        cancelButton.setImage(trashSymbol, for: .normal)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),

            checkmarkButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            checkmarkButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),

            cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            borderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 2),
            borderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }
}
