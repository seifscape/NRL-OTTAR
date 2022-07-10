//
//  CaptureDetailViewController.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 3/13/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import Get
import SPAlert
import CoreGraphics
import Accelerate

enum Item: Hashable {
    case images(Image)
    case createImages(CreateImage)
}

enum Section: CaseIterable {
    case images
    case newImages

    var cellIdentifier: String {
        switch self {
        case .images:
            return "captureDetailCell"
        case .newImages:
            return "captureDetailCreateImageCell"
        }
    }
}

class CaptureDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    lazy var dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable> (collectionView: collectionView) { [unowned self] (collectionView, indexPath, item) in

        switch item {
        case let item as Image:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "captureDetailCell", for: indexPath) as? CaptureDetailCollectionViewCell else { fatalError() }
            // configure the cell
            if let image = self.capture.images?[indexPath.row] {
                cell.configure(for: image)
            }
            return cell
        case let item as CreateImage:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "captureDetailCreateImageCell", for: indexPath) as? CaptureDetailCreateImageCollectionViewCell else { fatalError() }
            // configure the cell
            cell.configure(for: self.imagesToUpload[indexPath.row])
            return cell


        default:
            return nil
        }
    }

    // Views
    var topHeaderView  = UIView()
    var textViewContainer = UIView()
    var textView = UITextView()
    var collectionContainer = UIView()
    var editModeButton = UIBarButtonItem()
    var floatingButton = UIButton()
    var deleteFloatingButton = UIButton()


    var listOfIds:[Int] = []
    var safeArea: UILayoutGuide!
    var collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let spacing:CGFloat = 16.0
    private let topHeaderHeight:CGFloat = 150.0
    private var listOfImagesToDelete = [Image]()
    private var removeLocalImages = [CreateImage]()
    var deleteResponseCapture : ((Capture?, Bool?) -> Void)?
    private var imagesToUpload:[CreateImage] = []
    private var capture: Capture {
        didSet {
            var snapshot = Snapshot()
            snapshot.appendSections([.images])
            if let images = self.capture.images {
                snapshot.appendItems(images, toSection: .images)
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }

    init(capture:Capture) {
        self.capture = capture
        super.init(nibName: nil, bundle: nil)
        Task {
            do {
                let alertView = SPAlertView(title: "Loading", preset: .spinner)
                alertView.present()
                self.capture = try await CaptureServices.getCapture(capture: capture)
                alertView.dismiss()
            } catch {
                let alertView = SPAlertView(title: "Error", preset: .error)
                alertView.present()
                alertView.duration = 0.75
                print("Request failed with error: \(error)")
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Capture Detail: \(self.capture.captureID)"
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

        layout.headerReferenceSize = CGSize(width: 50, height: 50)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        editModeButton = UIBarButtonItem(title:"Edit", style: .plain, target: self, action: #selector(editCaptures(_:)))
        editModeButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = editModeButton


        collectionView.register(CaptureDetailCollectionViewCell.self, forCellWithReuseIdentifier: "captureDetailCell")
        collectionView.register(CaptureDetailCreateImageCollectionViewCell.self, forCellWithReuseIdentifier: "captureDetailCreateImageCell")
                collectionView.register(SectionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier)


        collectionView.delegate = self
        self.setupInterface()
        self.setupConstraints()
        self.setupCollectionView()
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.setupNavBar()
        if self.capture.annotation.isEmpty {
            textView.text  = "Enter an annotation here"
            textView.textColor = .lightGray
        } else {
            self.textView.text = self.capture.annotation
        }
        self.textView.delegate = self
        self.textView.keyboardDismissMode = .none
        self.navigationController?.navigationBar.barStyle = .black

        self.textView.addDoneButton(title: "Done", target: self, selector: #selector(dismissKeyboard(_:)))
//        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
//        dismissKeyboardGesture.delegate = self
//        dismissKeyboardGesture.cancelsTouchesInView = false
//        self.collectionView.addGestureRecognizer(dismissKeyboardGesture)
//        self.view.addGestureRecognizer(dismissKeyboardGesture)

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)


        dataSource.supplementaryViewProvider = { [unowned self] collectionView, kind, indexPath in
            return self.supplementary(collectionView: collectionView, kind: kind, indexPath: indexPath)
        }

    }



        func supplementary(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView?
        {
            guard kind == UICollectionView.elementKindSectionHeader else {
              return nil
            }
            // 3
            let view = collectionView.dequeueReusableSupplementaryView(
              ofKind: kind,
              withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier,
              for: indexPath) as? SectionHeaderReusableView
            // 4
    //        let section = self.dataSource.snapshot()
    //          .sectionIdentifiers[indexPath.section]

            if indexPath.section == 0 {
                view?.titleLabel.text = "Images"  //section.cellIdentifier
            } else { view?.titleLabel.text = "New Images" }
            return view

        }

//    func gestureRecognizer(
//        _ gestureRecognizer: UIGestureRecognizer,
//        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
//    ) -> Bool {
//        return false
//    }

    @objc func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        self.capture.annotation = self.textView.text
        self.textView.endEditing(true)
        do {
//            self.textView.isEditable = true
            if self.capture.annotation.isEmpty {
                textView.text  = "Enter an annotation here"
                textView.textColor = .lightGray
            } else {
                self.textView.text = self.capture.annotation
            }

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
        flowLayout.itemSize = CGSize(width:(size.width/2.1) - spacing, height: (size.height-topHeaderHeight)/3)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isEditing = !self.isEditing
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

        editModeButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editCaptures(_:)))
        editModeButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = editModeButton
        self.navigationController?.navigationBar.tintColor = .black



    }

    func setupInterface() {
        self.view.backgroundColor = OTTARColors.nrlBlue
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
        self.floatingButton.layer.shadowColor = OTTARColors.nrlBlue.cgColor
        self.floatingButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.floatingButton.layer.shadowOpacity = 0.2
        self.floatingButton.layer.shadowRadius = 4.0
        self.floatingButton.layer.masksToBounds = true
        self.floatingButton.isHidden = true
        self.floatingButton.addBlurEffect(style: .dark, cornerRadius: 25, padding: 0)
        self.floatingButton.addTarget(self, action: #selector(addPhotos(_:)), for: .touchUpInside)


        // Floating Button
        let largeBoldTrash = UIImage(systemName: "trash.circle.fill", withConfiguration: largeConfig)
        self.deleteFloatingButton.setImage(largeBoldTrash, for: .normal)
        self.deleteFloatingButton.tintColor = .systemRed
        self.deleteFloatingButton.layer.cornerRadius = 25
        self.collectionContainer.addSubview(self.deleteFloatingButton)
        self.deleteFloatingButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteFloatingButton.layer.shadowColor = OTTARColors.nrlBlue.cgColor
        self.deleteFloatingButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.deleteFloatingButton.layer.shadowOpacity = 0.2
        self.deleteFloatingButton.layer.shadowRadius = 4.0
        self.deleteFloatingButton.layer.masksToBounds = true
        self.deleteFloatingButton.isHidden = true
        self.deleteFloatingButton.addBlurEffect(style: .dark, cornerRadius: 25, padding: 0)
        self.deleteFloatingButton.addTarget(self, action: #selector(deleteCaptureImages(_:)), for: .touchUpInside)


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
            self.isEditing = false
            topHeaderView.isUserInteractionEnabled = false
            textView.isEditable = false
            editModeButton.title = "Edit"
            self.navigationItem.leftBarButtonItem = nil
            self.floatingButton.isHidden = true
            self.deleteFloatingButton.isHidden = true
            self.collectionView.allowsMultipleSelection = false
            self.deletePhotosFromServer()
            self.uploadPhotosToServer()

        } else {
            self.isEditing = true
            topHeaderView.isUserInteractionEnabled = true
            textView.isEditable = true
            textView.isSelectable = true
            editModeButton.title = "Done"
            self.floatingButton.isHidden = false
            self.deleteFloatingButton.isHidden = false
            self.collectionView.allowsMultipleSelection = true
        }
    }


    private func deletePhotosFromServer() {
        Task {
            if self.listOfIds.count > 0 {
                print(self.listOfIds)
                try await CaptureServices.deleteImages(capture: self.capture,listOfImages:listOfIds)
                let alertView = SPAlertView(title: "Deleted", preset: .done)
                alertView.duration = 0.88
                alertView.present()
                self.listOfIds.removeAll()
            }
        }
    }

    private func uploadPhotosToServer() {
        if self.imagesToUpload.count == 0 {
            return
        }

        let alertView = SPAlertView(title: "Uploading", preset: .spinner)
        alertView.present()

        let taskImageUpload = Task { () -> Images? in
            let images = try await CaptureServices.addImages(capture: capture, images: self.imagesToUpload)
            return images
        }

        Task {
            do {
                if let responseImages = try await taskImageUpload.value {
                    alertView.dismiss()
                    for i in responseImages.images {
                        self.capture.images?.append(i)
                    }
                    var snapshot = dataSource.snapshot()
                    snapshot.appendItems(responseImages.images)
                    dataSource.apply(snapshot, animatingDifferences: false) {
                        self.imagesToUpload.removeAll()
                    }
                }
            }
            catch {
                alertView.dismiss()
                print("Request failed with error: \(error)")
            }
        }
    }


    @objc
    func deleteCaptureImages(_ sender: UIButton) {
        // Server Images
        if listOfImagesToDelete.count > 0 {
            for i in listOfImagesToDelete {
                listOfIds.append(i.imageID)
            }
            var snapshot = dataSource.snapshot()
            for i in self.listOfImagesToDelete {
                self.capture.images?.removeAll(where: {$0.imageID == i.imageID})
            }

            snapshot.deleteItems(self.listOfImagesToDelete)
            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.listOfImagesToDelete.removeAll()

        }
        // Local Images
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(self.removeLocalImages)
        self.dataSource.apply(snapshot, animatingDifferences: true) {
            for i in self.imagesToUpload {
                for e in self.removeLocalImages {
                    if i.id == e.id {
                        self.imagesToUpload.remove(element: i)
                    }
                }
            }
            self.removeLocalImages.removeAll()
        }
    }

    func updateListController() async {
        if let detailsList = self.navigationController?.viewControllers.first as? CaptureListViewController {
            await detailsList.fetchCaptures()
        }
    }

    @objc
    func addPhotos(_ sender: UIButton) {

        if self.textView.text != "Enter an annotation here" {
            capture.annotation = textView.text
        }

        let cameraVC = CaptureCameraViewController(capture: capture)
        cameraVC.modalPresentationStyle = .fullScreen

        cameraVC.capturePreview.appendImagesToCapture = { [unowned self] (images, boolean) in
            for image in images {
                self.imagesToUpload.append(image)
            }
            var snapshot = self.dataSource.snapshot()
            snapshot.appendSections([.newImages])
            snapshot.appendItems(self.imagesToUpload)
            DispatchQueue.main.async {
                self.dataSource.applySnapshot(snapshot, animated: true)
            }
        }
        let navigationController = UINavigationController(rootViewController: cameraVC)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.present(navigationController, animated: true)
    }

}

extension CaptureDetailViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.isEditing else {
            if let sectionItem = dataSource.itemIdentifier(for: indexPath) {
                switch sectionItem {
                case let sectionItem as Image:
                    let imageViewController = CaptureImageViewController(image: sectionItem, createImage: nil)
                    self.navigationController?.present(imageViewController, animated: true)
                case let sectionItem as CreateImage:
                    let imageViewController = CaptureImageViewController(image:nil, createImage: sectionItem)
                    self.navigationController?.present(imageViewController, animated: true)
                default:
                    return
                }
            }
            return
        }

        if let sectionItem = dataSource.itemIdentifier(for: indexPath) {
            switch sectionItem {
            case let sectionItem as Image:
                guard let cell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCollectionViewCell else { fatalError() }
                cell.showCheckmark()
                self.listOfImagesToDelete.append(sectionItem)
            case let sectionItem as CreateImage:
                guard let cell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCreateImageCollectionViewCell else { fatalError() }
                cell.showCheckmark()
                for i in imagesToUpload {
                    if i.id == sectionItem.id {
                        self.removeLocalImages.append(i)
                    }
                }
            default:
                return
            }
        }

    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard self.isEditing else { return }

        if let sectionItem = dataSource.itemIdentifier(for: indexPath) {
            switch sectionItem {
            case let sectionItem as Image:
                guard let cell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCollectionViewCell else { fatalError() }
                cell.hideCheckmark()
                for i in self.listOfImagesToDelete {
                    if i.captureID == sectionItem.captureID {
                        self.listOfImagesToDelete.remove(element: i)
                    }
                }
            case let sectionItem as CreateImage:
                guard let cell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCreateImageCollectionViewCell else { fatalError() }
                cell.hideCheckmark()
                for i in imagesToUpload {
                    if i.id == sectionItem.id {
                        self.removeLocalImages.remove(element: i)
                    }
                }
            default:
                return
            }
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

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
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

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        // Hide the keyboard.
        textView.resignFirstResponder()
        return true
    }


    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter an annotation here"
            textView.textColor = UIColor.lightGray
            textView.becomeFirstResponder()
        } else if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) != capture.annotation {
            if !self.isEditing {
                Task {
                    let captureTask = try await CaptureServices.updateCapture(capture: self.capture, updatedText: textView.text)
                    if let task = captureTask {
                        let alertView = SPAlertView(title: "Updated", preset: .done)
                        alertView.present()
                        alertView.dismiss()
                        await updateListController()
                        capture.annotation = task.annotation
                    }
                }
            }
        } else { textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}


extension Array where Element: Equatable{
    mutating func remove (element: Element) {
        if let i = self.firstIndex(of: element) {
            self.remove(at: i)
        }
    }
}

extension UICollectionViewDiffableDataSource {
    func reloadData(
        snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        completion: (() -> Void)? = nil
    ) {
        if #available(iOS 15.0, *) {
            self.applySnapshotUsingReloadData(snapshot, completion: completion)
        } else {
            self.apply(snapshot, animatingDifferences: false, completion: completion)
        }
    }

    func applySnapshot(
        _ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        animated: Bool,
        completion: (() -> Void)? = nil) {

            if #available(iOS 15.0, *) {
                self.apply(snapshot, animatingDifferences: animated, completion: completion)
            } else {
                if animated {
                    self.apply(snapshot, animatingDifferences: true, completion: completion)
                } else {
                    UIView.performWithoutAnimation {
                        self.apply(snapshot, animatingDifferences: true, completion: completion)
                    }
                }
            }
        }
}

extension UICollectionView {
    func reconfigureCell(at indexPath: IndexPath) {
        let visibleIndexPaths = self.indexPathsForVisibleItems
        let foundIndexPath = visibleIndexPaths.first { $0 == indexPath }

        if let foundIndexPath = foundIndexPath {
            let cell = self.cellForItem(at: foundIndexPath)

            // get model that corresponds to index path
            // reconfigure the cell using the model
        }
    }
}

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}


extension UITextView {

    func addDoneButton(title: String, target: Any, selector: Selector) {

        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar//5
    }
}


//extension UIImage {
//    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
//        var width: CGFloat
//        var height: CGFloat
//        var newImage: UIImage
//
//        let size = self.size
//        let aspectRatio =  size.width/size.height
//
//        switch contentMode {
//            case .scaleAspectFit:
//                if aspectRatio > 1 {                            // Landscape image
//                    width = dimension
//                    height = dimension / aspectRatio
//                } else {                                        // Portrait image
//                    height = dimension
//                    width = dimension * aspectRatio
//                }
//
//        default:
//            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
//        }
//
//        if #available(iOS 10.0, *) {
//            let renderFormat = UIGraphicsImageRendererFormat.default()
//            renderFormat.opaque = opaque
//            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
//            newImage = renderer.image {
//                (context) in
//                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
//            }
//        } else {
//            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
//                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
//                newImage = UIGraphicsGetImageFromCurrentImageContext()!
//            UIGraphicsEndImageContext()
//        }
//
//        return newImage
//    }
//}


extension CreateImage {
    struct Diffable {
        let id: UUID

        let encoded: String
        let dateCreated: Date
        // other properties that will be rendered on the cell

        init(model: CreateImage) {
            self.id = model.id
            self.encoded = model.encoded
            self.dateCreated = model.dateCreated ?? Date.now
        }
    }
}
