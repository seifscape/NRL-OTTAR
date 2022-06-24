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
      case main
    }


    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Image>
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Image> = {
        let dataSource = UICollectionViewDiffableDataSource <Section, Image>(collectionView: collectionView) {
            [weak self] (collectionView: UICollectionView, indexPath: IndexPath, image: Image) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "captureDetailCell", for: indexPath) as? CaptureDetailCollectionViewCell
            if let image = self?.capture.images?[indexPath.row] {
                cell?.configure(for: image)
            }

          return cell
        }
        return dataSource
    }()

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
//    var listOfIndexPaths:[IndexPath] = []
    var listOfImagesToDelete = [Image]()
    var deleteResponseCapture : ((Capture?, Bool?) -> Void)?

    private var capture: Capture {
        didSet {
            DispatchQueue.main.async {
                var snapshot = Snapshot()
                snapshot.appendSections([.main])
                if let images = self.capture.images {
                    snapshot.appendItems(images, toSection: .main)
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
                alertView.duration = 1.5
                alertView.dismiss()
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

        topRightBarButton = UIBarButtonItem(title:"Edit", style: .plain, target: self, action: #selector(editCaptures(_:)))
        topRightBarButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = topRightBarButton


        collectionView.register(CaptureDetailCollectionViewCell.self, forCellWithReuseIdentifier: "captureDetailCell")
        collectionView.delegate = self
//        collectionView.dataSource = self
//        createDataSource()
        self.setupUI()
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
//        self.textView.returnKeyType = .done
        self.navigationController?.navigationBar.barStyle = .black

    }



    func applySnapshot(animatingDifferences: Bool = true) {
      // 2
      var snapshot = Snapshot()
      // 3
      snapshot.appendSections([.main])

      // 4
      snapshot.appendItems(self.capture.images ?? [Image](), toSection: .main)

      // 5
      dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
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

        topRightBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editCaptures(_:)))
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
            topRightBarButton.title = "Edit"
            self.navigationItem.leftBarButtonItem = nil
            self.floatingButton.isHidden = true
            self.deleteFloatingButton.isHidden = true
            self.collectionView.allowsSelection = true
            self.collectionView.allowsMultipleSelection = false
            var snapshot = dataSource.snapshot()
            snapshot.reloadSections([Section.main])
            dataSource.apply(snapshot)

            if listOfImagesToDelete.count > 0 {
                var listOfIds:[Int] = []
                for i in listOfImagesToDelete {
                    listOfIds.append(i.imageID)
                }
                Task {  try await
                    CaptureServices.deleteImages(capture: self.capture,listOfImages:listOfIds)
                    self.deletePhotos()
                    }
            }
        }
        else {
            self.isEditing = true
            topHeaderView.isUserInteractionEnabled = true
            textView.isEditable = true
            textView.isSelectable = true
            topRightBarButton.title = "Done"
            self.floatingButton.isHidden = false
            self.deleteFloatingButton.isHidden = false
            self.collectionView.allowsSelection = false
            self.collectionView.allowsMultipleSelection = true
        }
    }

    private func deletePhotos() {

        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(self.listOfImagesToDelete)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true) {
                guard self.capture.images != nil else { return }
                for i in self.listOfImagesToDelete {
                    for n in self.capture.images! {
                        if i.id == n.id {
                            self.capture.images?.remove(element: n)
                        }
                    }
                }
                self.listOfImagesToDelete.removeAll()
            }
        }
        print(self.capture.images?.count)
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

        if self.textView.text != "Placeholder" {
            capture.annotation = textView.text
        }

        let cameraVC = CaptureCameraViewController(capture: capture)

        // use back the old iOS 12 modal full screen style
        cameraVC.modalPresentationStyle = .fullScreen

        cameraVC.capturePreview.responseCapture = { [unowned self] (value, boolean) in
            DispatchQueue.main.async {
                if boolean != nil {
                    Task {
                        var snapshot = self.dataSource.snapshot()
                        snapshot.deleteItems(self.capture.images!)
                        self.capture = try await CaptureServices.getCapture(capture: value)
                        snapshot.appendItems(self.capture.images!)
                        snapshot.reloadSections([.main])
                        await self.dataSource.apply(snapshot, animatingDifferences: false)

//                        self.applySnapshot(animatingDifferences: true)
//                        var snapshot = self.dataSource.snapshot()
//                        snapshot.deleteItems(self.capture.images!)
//                        snapshot.appendItems(value.images!)
//                        await self.dataSource.apply(snapshot, animatingDifferences: true)
//                        if let currentLength = self.capture.images?.count {
//                            if let newImages = value.images {
//                                let newArray = newImages.dropFirst(currentLength)
//                                let finalArray = Array(newArray)
//                                snapshot.appendItems(finalArray)
//                                await self.dataSource.apply(snapshot, animatingDifferences: true)
//                                await self.updateListController()
//                            }
//                        }
                    }
                }
            }
        }
        let navigationController = UINavigationController(rootViewController: cameraVC)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.present(navigationController, animated: true)
    }
}


extension CaptureDetailViewController: UICollectionViewDelegate {

//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.capture.images?.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "captureDetailCell", for: indexPath) as? CaptureDetailCollectionViewCell
//        if let image = capture.images?[indexPath.row] {
//            cell?.configure(for: image)
//        }
//
//        if self.isEditing {
//            cell?.checkmarkView.isHidden = false
//        }
//
//        return cell ?? UICollectionViewCell()
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: CaptureDetailCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CaptureDetailCollectionViewCell else { return }
        print("Hit")
        if self.isEditing {
            if !cell.checkmarkView.checked {
                DispatchQueue.main.async {
                    cell.isMarked = true
                    cell.checkmarkView.checked = true
                }
                if let image = dataSource.itemIdentifier(for: indexPath) {
                    self.listOfImagesToDelete.append(image)
                    print("Added: \(indexPath.row)")
                }
            }
            else {
                DispatchQueue.main.async {
                    cell.isMarked = false
                    cell.checkmarkView.checked = false
                }
                if let image = dataSource.itemIdentifier(for: indexPath) {
                    for i in self.listOfImagesToDelete {
                        if i.id == image.id {
                            cell.checkmarkView.checked = false
                            self.listOfImagesToDelete.remove(element: i)
                            print("Removed: \(indexPath.row)")
                        }
                    }
                    print("Selected image ID: \(image.imageID)")
                 }
            }
         }
        else {
            if let image = dataSource.itemIdentifier(for: indexPath) {
                let imageViewController = ImageViewController(image: image)
                self.navigationController?.present(imageViewController, animated: true)
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

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter an annotation here"
            textView.textColor = UIColor.lightGray
            textView.becomeFirstResponder()
        } else if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) != capture.annotation {
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
