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

class CaptureDetailViewController: UIViewController {

    enum Section: CaseIterable {
      case images
      case createImages

        var cellIdentifier: String {
            switch self {
            case .images:
                return "captureDetailCell"
            case .createImages:
                return "captureDetailCreateImageCell"
            }
        }

    }


    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    lazy var dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable> (collectionView: collectionView) { [unowned self] (collectionView, indexPath, item) in

            if let image = item as? Image, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.images.cellIdentifier, for: indexPath) as? CaptureDetailCollectionViewCell {
                if let image = self.capture.images?[indexPath.row] {
                    cell.configure(for: image)
                }
                return cell
            }

            if let image = item as? CreateImage, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.createImages.cellIdentifier, for: indexPath) as? CaptureDetailCreateImageCollectionViewCell {
                cell.configure(for: self.imagesToUpload[indexPath.row])
                return cell
            }

            fatalError()
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
            DispatchQueue.main.async {
                var snapshot = Snapshot()
                snapshot.appendSections([.images])
                if let images = self.capture.images {
                    snapshot.appendItems(images, toSection: .images)
                    self.dataSource.apply(snapshot, animatingDifferences: true)
                }
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
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        editModeButton = UIBarButtonItem(title:"Edit", style: .plain, target: self, action: #selector(editCaptures(_:)))
        editModeButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = editModeButton


        collectionView.register(CaptureDetailCollectionViewCell.self, forCellWithReuseIdentifier: "captureDetailCell")
        collectionView.register(CaptureDetailCreateImageCollectionViewCell.self, forCellWithReuseIdentifier: "captureDetailCreateImageCell")

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
        self.textView.keyboardDismissMode = .interactive
        self.navigationController?.navigationBar.barStyle = .black
    }



//    func applySnapshot(animatingDifferences: Bool = true) {
//      // 2
//      var snapshot = Snapshot()
//      // 3
//      snapshot.appendSections([.main])
//
//      // 4
//      snapshot.appendItems(self.capture.images ?? [Image](), toSection: .main)
//
//      // 5
//      dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
//    }

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
            //deletePhotos()
            self.isEditing = false
            topHeaderView.isUserInteractionEnabled = false
            textView.isEditable = false
            editModeButton.title = "Edit"
            self.navigationItem.leftBarButtonItem = nil
            self.floatingButton.isHidden = true
            self.deleteFloatingButton.isHidden = true
            self.collectionView.allowsSelection = true
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
            self.collectionView.allowsSelection = false
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
                    snapshot.deleteSections([.createImages])
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
                // self.capture.deleteImage(image: i)
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
            self.imagesToUpload = images
            var snapshot = self.dataSource.snapshot()
            snapshot.appendSections([.createImages])
            snapshot.appendItems(images)
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
                //self.dataSource.applySnapshotUsingReloadData(snapshot)
            }

        }
        let navigationController = UINavigationController(rootViewController: cameraVC)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.present(navigationController, animated: true)

    }

}


extension CaptureDetailViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let imageCell: CaptureDetailCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCollectionViewCell {
        if self.isEditing {
            if !imageCell.checkmarkView.checked {
                DispatchQueue.main.async {
                    imageCell.isMarked = true
                    imageCell.checkmarkView.checked = true
                }
                if let item = dataSource.itemIdentifier(for: indexPath) as? Image {
                    self.listOfImagesToDelete.append(item)
                }
            } else {
                DispatchQueue.main.async {
                    imageCell.isMarked = false
                    imageCell.checkmarkView.checked = false
                }
                if let item = dataSource.itemIdentifier(for: indexPath) as? Image {
                    for i in self.listOfImagesToDelete {
                        if i.captureID == item.captureID {
                            self.listOfImagesToDelete.remove(element: i)
                        }
                    }
                }
            }
         }
        else {
            if let item = dataSource.itemIdentifier(for: indexPath) as? Image {
                let imageViewController = CaptureImageViewController(image: item, createImage: nil)
                self.navigationController?.present(imageViewController, animated: true)
                print("ImageID: \(item.imageID)")
                print("Added: \(indexPath.row)")
                }
            }
        } else {
            if let createImageCell: CaptureDetailCreateImageCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCreateImageCollectionViewCell {
            if self.isEditing {
                if !createImageCell.checkmarkView.checked {
                    DispatchQueue.main.async {
                        createImageCell.isMarked = true
                        createImageCell.checkmarkView.checked = true
                    }
                    if let item = dataSource.itemIdentifier(for: indexPath) as? CreateImage {
                        for i in imagesToUpload {
                            if i.id == item.id {
                                self.removeLocalImages.append(i)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        createImageCell.isMarked = false
                        createImageCell.checkmarkView.checked = false
                    }
                    if let item = dataSource.itemIdentifier(for: indexPath) as? CreateImage {
                        for i in imagesToUpload {
                            if i.id == item.id {
                                self.removeLocalImages.remove(element: i)
                            }
                        }
                    }
                }
             }
            else {
                if let item = dataSource.itemIdentifier(for: indexPath) as? CreateImage {
                    let imageViewController = CaptureImageViewController(image: nil, createImage: item)
                    self.navigationController?.present(imageViewController, animated: true)
                    print("ImageID: \(item.id)")
                    print("Added: \(indexPath.row)")
                    }
                }
            }

        }

        collectionView.deselectItem(at: indexPath, animated: true)
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
