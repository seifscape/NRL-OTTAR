//
//  CaptureDetailViewController.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 3/13/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import Get

class CaptureDetailViewController: UIViewController {

    var topHeaderView  = UIView()
    var textViewContainer = UIView()
    var textView = UITextView()
    var collectionContainer = UIView()
    var safeArea: UILayoutGuide!
    var collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    var topRightBarButton = UIBarButtonItem()
    var floatingButton = UIButton()
    private let spacing:CGFloat = 16.0
    private let topHeaderHeight:CGFloat = 150.0
    var listOfImagesToRemove:[Int] = []
    var deleteResponseCapture : ((Capture?, Bool?) -> Void)?

    private var capture: Capture? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    init(capture:Capture?) {
        super.init(nibName: nil, bundle: nil)
        Task {
            self.capture = await self.loadCapture(captureID:capture?.captureID ?? 0)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Capture Detail"
        self.textView.delegate = self
        topHeaderView.isUserInteractionEnabled = false
        edgesForExtendedLayout = []
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(self.view.frame.width/2.1) - spacing, height: (self.view.frame.height-topHeaderHeight)/3)
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        let config = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "pencil", withConfiguration: config)
        topRightBarButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(editCaptures(_:)))
        topRightBarButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = topRightBarButton


        collectionView.register(CaptureDetailCollectionViewCell.self, forCellWithReuseIdentifier: "captureDetailCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        self.setupUI()
        self.setupConstraints()
        self.setupCollectionView()
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.setupNavBar()
        self.textView.text = "Attribution information placeholder"
        self.textView.delegate = self
        self.navigationController?.navigationBar.barStyle = .black
    }


    func setupNavBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let appearance = UINavigationBarAppearance()
        // Set background color
        appearance.backgroundColor = .white
        // Set font
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ]

        appearance.shadowColor = .clear
        // Apply the appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.prefersLargeTitles = false

        let config = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "pencil", withConfiguration: config)
        topRightBarButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(editCaptures(_:)))
        topRightBarButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = topRightBarButton
        self.navigationController?.navigationBar.tintColor = .black

    }

    func loadCapture(captureID: Int) async -> Capture? {

        do {
            let capture = try await InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(captureID).get).value
            return capture
        }
        catch {
            print("Fetching capture failed with error \(error)")
            return nil
        }
    }

    func setupUI() {
        self.view.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        topHeaderView = UIView(frame: .zero)
        topHeaderView.translatesAutoresizingMaskIntoConstraints = false
        topHeaderView.clipsToBounds = true
        topHeaderView.layer.cornerRadius = 10


        collectionContainer = UIView(frame: .zero)
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false


        textView.translatesAutoresizingMaskIntoConstraints = false
        topHeaderView.backgroundColor = .white
        collectionContainer.backgroundColor = .systemTeal
        collectionView.backgroundColor = self.view.backgroundColor

        self.view.addSubview(topHeaderView)
        self.view.addSubview(collectionContainer)
        collectionContainer.addSubview(collectionView)

        safeArea = self.view.layoutMarginsGuide
        topHeaderView.addSubview(textView)

        textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.contentInsetAdjustmentBehavior = .never
        textView.textAlignment = NSTextAlignment.justified
        textView.textColor = UIColor.black
        textView.font = .preferredFont(forTextStyle: .body, compatibleWith: .current)
        textView.isEditable = false
        textView.isSelectable = false
        topHeaderView.addSubview(textView)

        // Floating Button
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "camera.circle.fill", withConfiguration: largeConfig)
        self.floatingButton.setImage(largeBoldDoc, for: .normal)
        self.floatingButton.tintColor = .white
        self.floatingButton.layer.cornerRadius = 25
        self.collectionContainer.addSubview(self.floatingButton)
        self.floatingButton.translatesAutoresizingMaskIntoConstraints = false
        self.floatingButton.layer.shadowColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00).cgColor
        self.floatingButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.floatingButton.layer.shadowOpacity = 0.2
        self.floatingButton.layer.shadowRadius = 4.0
        self.floatingButton.layer.masksToBounds = true
        self.floatingButton.isHidden = true

        self.floatingButton.addBlurEffect(style: .dark, cornerRadius: 25, padding: 0)
        self.floatingButton.addTarget(self, action: #selector(addMorePhotos(_:)), for: .touchUpInside)

    }

    func setupConstraints() {

        topHeaderView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20).isActive = true
        topHeaderView.leftAnchor.constraint(equalTo: safeArea.leftAnchor).isActive = true
        topHeaderView.bottomAnchor.constraint(equalTo: safeArea.topAnchor,constant: topHeaderHeight).isActive = true
        topHeaderView.rightAnchor.constraint(equalTo: safeArea.rightAnchor).isActive = true

        textView.topAnchor.constraint(equalTo: topHeaderView.topAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: topHeaderView.leftAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: topHeaderView.bottomAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: topHeaderView.rightAnchor).isActive = true

        collectionContainer.topAnchor.constraint(equalTo: topHeaderView.bottomAnchor, constant: 5).isActive = true
        collectionContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        collectionContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true

        floatingButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        floatingButton.trailingAnchor.constraint(equalTo: collectionContainer.trailingAnchor, constant: -20).isActive = true
        floatingButton.bottomAnchor.constraint(equalTo: collectionContainer.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true

    }

    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: collectionContainer.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: collectionContainer.leftAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: collectionContainer.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: collectionContainer.rightAnchor).isActive = true

    }

    private func refreshAfterDelete() async throws {
        let deleteTask = try await self.deleteImages(listOfImages:self.listOfImagesToRemove)
        Task {
            self.capture = await self.loadCapture(captureID:self.capture?.captureID ?? 0)
            self.collectionView.reloadData()
        }
    }

    @objc
    private func editCaptures(_ sender: UIButton) {

//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }

        if isEditing {

            if let indexPaths = self.collectionView.indexPathsForSelectedItems {
                if let currentCapture = self.capture {
                    for i in indexPaths {
                        if let targetImageId = currentCapture.images?[i.row].imageID {
                            self.listOfImagesToRemove.append(targetImageId)
                        }
                    }
                }
                Task {
                    try await self.refreshAfterDelete()
                }
            }

            isEditing = false
            topHeaderView.isUserInteractionEnabled = false
            textView.isEditable = false
            topRightBarButton.image = UIImage(systemName: "pencil")
            self.navigationItem.leftBarButtonItem = nil
            self.floatingButton.isHidden = true
            self.collectionView.allowsSelection = true
            self.collectionView.allowsMultipleSelection = false
        }
        else {
            isEditing = true
            topHeaderView.isUserInteractionEnabled = true
            textView.isEditable = true
            textView.isSelectable = true
            topRightBarButton.image = UIImage(systemName: "checkmark")
            self.floatingButton.isHidden = false
            self.collectionView.allowsSelection = false
            self.collectionView.allowsMultipleSelection = true
        }
    }

    @objc
    func addMorePhotos(_ sender:UIButton) {

        let cameraVC = CaptureCameraViewController(capture: capture)

        // use back the old iOS 12 modal full screen style
        cameraVC.modalPresentationStyle = .fullScreen

        cameraVC.capturePreview.responseCapture = { (value, boolean) in
            DispatchQueue.main.async {
                if boolean != nil {
                    Task {
                        self.capture = await self.loadCapture(captureID:value?.captureID ?? 0)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        let navigationController = UINavigationController(rootViewController: cameraVC)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.present(navigationController, animated: true)
    }
}


extension CaptureDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capture?.images?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "captureDetailCell", for: indexPath) as! CaptureDetailCollectionViewCell

        let imageData = Data(base64Encoded: capture?.images?[indexPath.row].encoded ?? "", options: .init(rawValue: 0))
        if let imgData = imageData {
            cell.imageView.image = UIImage(data: imgData)
        }

        cell.imageView.contentMode = .scaleToFill

        if !self.isEditing {
            cell.isMarked = false
        }

//        if self.isEditing {
//            cell.button.isHidden = false
//        }
//        else { cell.button.isHidden = true }
        // Configure the cell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         guard let cell: CaptureDetailCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCollectionViewCell else { return }
         if self.collectionView.allowsMultipleSelection {
             cell.isMarked = true
         }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell: CaptureDetailCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCollectionViewCell else { return }
        if self.collectionView.allowsMultipleSelection {
            cell.isMarked = false
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: 5, bottom: spacing, right: 5)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let numberOfItemsPerRow:CGFloat = 2
            let spacingBetweenCells:CGFloat = 0

            let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row

            let width = floor((collectionView.bounds.width - totalSpacing)/numberOfItemsPerRow)
            return CGSize(width: width, height: width)
    }


    func updateCapture(updatedAnnotation: String) async throws -> Capture? {

        let updateTask = Task {() ->  Capture? in
            return try await
            InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(capture?.captureID ?? -1).patch(CreateAndUpdateCapture(annotation: textView.text))).value
        }
        return try await updateTask.value
    }

    func deleteImages(listOfImages: [Int]) async throws -> DeleteImages? {
        let delete = DeleteImages(imageIDs: listOfImages)

        let deleteTask = Task {() ->  DeleteImages? in
            return try await
            InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(self.capture?.captureID ?? 0).removeImages.delete(delete)).value
        }
        return try await deleteTask.value
    }

}

extension UIButton {
    func addBlurEffect(style: UIBlurEffect.Style = .regular, cornerRadius: CGFloat = 0, padding: CGFloat = 0) {
        backgroundColor = .clear
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        blurView.isUserInteractionEnabled = false
        blurView.backgroundColor = .clear
        if cornerRadius > 0 {
            blurView.layer.cornerRadius = cornerRadius
            blurView.layer.masksToBounds = true
        }
        self.insertSubview(blurView, at: 0)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: padding).isActive = true
        self.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -padding).isActive = true
        self.topAnchor.constraint(equalTo: blurView.topAnchor, constant: padding).isActive = true
        self.bottomAnchor.constraint(equalTo: blurView.bottomAnchor, constant: -padding).isActive = true

        if let imageView = self.imageView {
            imageView.backgroundColor = .clear
            self.bringSubviewToFront(imageView)
        }
    }
}

extension CaptureDetailViewController: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if self.isEditing {
            return true
        }
        else {
            return false
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if !self.isEditing {
            Task {
                try await self.updateCapture(updatedAnnotation: textView.text)
            }
        }
    }
}
