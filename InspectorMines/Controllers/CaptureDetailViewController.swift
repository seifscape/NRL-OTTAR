//
//  CaptureDetailViewController.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 3/13/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import Get
import CoreAudio
import SPAlert

class CaptureDetailViewController: UIViewController {

    var topHeaderView  = UIView()
    var textViewContainer = UIView()
    var textView = UITextView()
    var collectionContainer = UIView()
    var safeArea: UILayoutGuide!
    var collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    var topRightBarButton = UIBarButtonItem()
    var floatingButton = UIButton()
    var deleteFloatingButton = UIButton()
    private let spacing:CGFloat = 16.0
    private let topHeaderHeight:CGFloat = 150.0
    var listOfImagesToRemove:[Int] = []
    var listOfIndexPaths:[IndexPath] = []
    var deleteResponseCapture : ((Capture?, Bool?) -> Void)?

    private var capture: Capture {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    init(capture:Capture) {
        self.capture = capture
        super.init(nibName: nil, bundle: nil)
        Task {
            do {
                self.capture = try await CaptureServices.getCapture(capture: capture)
            } catch {
                print("Request failed with error: \(error)")
            }
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
        self.textView.text = self.capture.annotation
        self.textView.delegate = self
//        self.textView.returnKeyType = .done
        self.navigationController?.navigationBar.barStyle = .black

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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


        // Floating Button
        let largeBoldTrash = UIImage(systemName: "trash.circle.fill", withConfiguration: largeConfig)
        self.deleteFloatingButton.setImage(largeBoldTrash, for: .normal)
        self.deleteFloatingButton.tintColor = .systemRed
        self.deleteFloatingButton.layer.cornerRadius = 25
        self.collectionContainer.addSubview(self.deleteFloatingButton)
        self.deleteFloatingButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteFloatingButton.layer.shadowColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00).cgColor
        self.deleteFloatingButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.deleteFloatingButton.layer.shadowOpacity = 0.2
        self.deleteFloatingButton.layer.shadowRadius = 4.0
        self.deleteFloatingButton.layer.masksToBounds = true
        self.deleteFloatingButton.isHidden = true
        self.deleteFloatingButton.addBlurEffect(style: .dark, cornerRadius: 25, padding: 0)
        self.deleteFloatingButton.addTarget(self, action: #selector(deleteCapture(_:)), for: .touchUpInside)


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



        deleteFloatingButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        deleteFloatingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        deleteFloatingButton.bottomAnchor.constraint(equalTo: floatingButton.topAnchor, constant: -20).isActive = true
        deleteFloatingButton.trailingAnchor.constraint(equalTo: collectionContainer.trailingAnchor, constant: -20).isActive = true


    }

    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: collectionContainer.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: collectionContainer.leftAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: collectionContainer.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: collectionContainer.rightAnchor).isActive = true

    }


    @objc
    private func editCaptures(_ sender: UIButton) {
        if self.isEditing {
            //deletePhotos()
            self.isEditing = false
            topHeaderView.isUserInteractionEnabled = false
            textView.isEditable = false
            topRightBarButton.image = UIImage(systemName: "pencil")
            self.navigationItem.leftBarButtonItem = nil
            self.floatingButton.isHidden = true
            self.deleteFloatingButton.isHidden = true
            self.collectionView.allowsSelection = true
            self.collectionView.allowsMultipleSelection = false

            if self.listOfImagesToRemove.count > 0  {
            Task {  try await
                CaptureServices.deleteImages(capture: self.capture,listOfImages:self.listOfImagesToRemove)
                self.deletePhotos()
                }

//                let capture = Task { () ->  Capture? in
//                    return try await CaptureServices.getCapture(capture:self.capture)
//                }
//                Task {
//                    let result = try await capture.value
//                    if let capture = result {
//                        DispatchQueue.main.async {
//                            print(capture.images?.count)
//                            print(capture.annotation)
//                            self.capture.images = capture.images
//                            self.collectionView.reloadData()
//                            self.collectionView.collectionViewLayout.invalidateLayout()
//                        }
//
//                    }
//                }
            }
        }
        else {
            self.isEditing = true
            topHeaderView.isUserInteractionEnabled = true
            textView.isEditable = true
            textView.isSelectable = true
            topRightBarButton.image = UIImage(systemName: "checkmark")
            self.floatingButton.isHidden = false
            self.deleteFloatingButton.isHidden = false
            self.collectionView.allowsSelection = false
            self.collectionView.allowsMultipleSelection = true
        }
    }


//    private func refreshAfterDelete() async throws  {
//        async let delete =  CaptureServices.deleteImages(capture: self.capture!, listOfImages:self.listOfImagesToRemove)
//        async let capture =  CaptureServices.getCapture(capture: self.capture!)
//        let (deleteData, captureData) = try await (delete, capture)
//    }


    private func deletePhotos() {
        if listOfIndexPaths.count == self.capture.images?.count {
            self.capture.images?.removeAll()
        } else {
            for x in self.listOfIndexPaths {
                print("List Len \(self.listOfIndexPaths.count)")
                print("Row: \(x.row)")
                self.capture.images?.remove(at: x.row)
            }
        }
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: listOfIndexPaths)
        })
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.listOfIndexPaths.removeAll()
        }
    }

    @objc
    func deleteCapture(_ sender:UIButton) {
        let alertView = SPAlertView(title: "Deleted", preset: .done)
        alertView.duration = 1.5
        alertView.present()

        Task {
            try await CaptureServices.deleteCapture(captureId: self.capture.captureID)
            self.deleteResponseCapture?(capture, true)
            alertView.dismiss()
            self.navigationController?.popViewController(animated: true)
        }
    }

    func updateListController() async {
        if let detailsList = self.navigationController?.viewControllers.first as? CaptureListViewController {
            await detailsList.fetchCaptures()
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
                        self.capture = try await CaptureServices.getCapture(capture: value)
                        self.collectionView.reloadData()
                        await self.updateListController()
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
        return self.capture.images?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "captureDetailCell", for: indexPath) as! CaptureDetailCollectionViewCell

        let imageData = Data(base64Encoded: capture.images?[indexPath.row].encoded ?? "", options: .init(rawValue: 0))
        if let imgData = imageData {
            cell.imageView.image = UIImage(data: imgData)
        }
        cell.imageView.contentMode = .scaleToFill

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: CaptureDetailCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCollectionViewCell else { return }
        if self.isEditing {
            self.listOfImagesToRemove.append(self.capture.images?[indexPath.row].imageID ?? 0)
            self.listOfIndexPaths.append(indexPath)
            print("Added: \(indexPath.row)")
             collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
             cell.isMarked = true
         }
        else {
            if let image = self.capture.images?[indexPath.row] {
                let imageViewController = ImageViewController(image: image)
                self.navigationController?.present(imageViewController, animated: true)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell: CaptureDetailCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCollectionViewCell else { return }
        if self.isEditing {
            if let index = listOfIndexPaths.firstIndex(of:indexPath) {
                listOfIndexPaths.remove(at: index)
            }

            if let index = listOfImagesToRemove.firstIndex(of:self.capture.images?[indexPath.row].imageID ?? 0) {
                listOfImagesToRemove.remove(at: index)
            }
            collectionView.deselectItem(at: indexPath, animated: true)
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
        let alertView = SPAlertView(title: "Updated", preset: .done)
        alertView.present()
        if !self.isEditing {
            Task {
                let captureTask = try await CaptureServices.updateCapture(capture: self.capture, updatedText: textView.text)
                if let task = captureTask {
                    alertView.dismiss()
                    await updateListController()
                    capture.annotation = task.annotation
                }
            }
        }
    }
}
