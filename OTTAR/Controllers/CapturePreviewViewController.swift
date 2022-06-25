//
//  CapturePreviewViewController.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 5/12/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import Get
import CoreLocation
import SPAlert
import CoreLocation

protocol CapturePreviewControllerDelegate: AnyObject {
    func willTakeAditionalPhotos(withImage image: [CreateImage]?)
    func removeSelectedPhoto(targetImage targetIndex: Int)
}

class CapturePreviewViewController: UIViewController {

    var responseCapture: ((Capture, Bool?) -> Void)?
    var addImagesToCapture: (([CreateImage], Bool?) -> Void)?
    var bottomViewContainer = UIView()
    var previewContainer = UIView()
    var safeArea: UILayoutGuide!
    weak var cameraPreviewDelegate: CapturePreviewControllerDelegate?
    var indexOfCellBeforeDragging: Int = 0
    var initialAnimation:Bool = false
    var centerCell:CaptureDetailCollectionViewCell?
    var selectedIndex:IndexPath?
    var images:[CreateImage]?
    var capture:Capture?
    let cameraButton = UIButton()
    let checkmarkButton = UIButton()
    let cancelButton = UIButton()


    private let cellWitdhPercentage: CGFloat = 0.85
    private let idealCellDistance: CGFloat = 16
    private var currentPositionIndex = 0
    var currentLocation = CLLocation()

    private let collectionView: UICollectionView = {
        let viewLayout = UICollectionViewFlowLayout()
        viewLayout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: viewLayout)
        collectionView.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.decelerationRate = .normal
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()


    // this is a convenient way to create this view controller without a capture
    convenience init() {
        self.init(images: nil, capture: nil)
    }

    init(images: [CreateImage]?, capture: Capture?) {
        self.images = images
        self.capture = capture
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        navigationItem.backButtonTitle = ""
        self.navigationItem.backBarButtonItem?.tintColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.setupUI()
        self.setupConstraints()
        //self.displayBottomOptions()
        self.viewDidLayoutSubviews()

        collectionView.register(CaptureDetailCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast

        cameraButton.addTarget(self, action: #selector(addMorePhotos(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(removePhoto(_:)), for: .touchUpInside)
        checkmarkButton.addTarget(self, action: #selector(completeCapture(_:)), for: .touchUpInside)
        self.navigationController?.navigationBar.barStyle = .black


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.collectionView?.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.initialAnimation = false
        self.selectedIndex = nil
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        collectionView.collectionViewLayout.invalidateLayout()
//    }

    func setupUI() {
        view.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        previewContainer = UIView(frame: .zero)
        previewContainer.backgroundColor = .gray
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        safeArea = self.view.layoutMarginsGuide
        view.addSubview(previewContainer)
        previewContainer.addSubview(collectionView)

        bottomViewContainer = UIView(frame: .zero)
        bottomViewContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomViewContainer.backgroundColor = .white
        self.view.addSubview(bottomViewContainer)


        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .medium)
        let addSymbol = UIImage(systemName: "video.badge.plus", withConfiguration: configuration)
        let checkmarkSymbol = UIImage(systemName: "checkmark.circle", withConfiguration: configuration)
        let trashSymbol = UIImage(systemName: "trash.circle", withConfiguration: configuration)

        cameraButton.tintColor = .black
        checkmarkButton.tintColor = .black
        cancelButton.tintColor = .black

        checkmarkButton.setImage(checkmarkSymbol, for: .normal)
        bottomViewContainer.addSubview(checkmarkButton)

        cameraButton.setImage(addSymbol, for: .normal)
        bottomViewContainer.addSubview(cameraButton)

        cancelButton.setImage(trashSymbol, for: .normal)
        bottomViewContainer.addSubview(cancelButton)
    }

    func setupConstraints() {
        previewContainer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 25).isActive = true
        previewContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant:0).isActive = true
        previewContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        previewContainer.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -110).isActive = true

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: previewContainer.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: previewContainer.leftAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: previewContainer.rightAnchor).isActive = true


        bottomViewContainer.topAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: 20).isActive = true
        bottomViewContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomViewContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        NSLayoutConstraint.activate([

            cameraButton.centerYAnchor.constraint(equalTo: bottomViewContainer.centerYAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: bottomViewContainer.leadingAnchor, constant: 50),

            checkmarkButton.centerYAnchor.constraint(equalTo: bottomViewContainer.centerYAnchor),
            checkmarkButton.trailingAnchor.constraint(equalTo: bottomViewContainer.trailingAnchor, constant: -50),

            cancelButton.centerYAnchor.constraint(equalTo: bottomViewContainer.centerYAnchor),
            cancelButton.centerXAnchor.constraint(equalTo: bottomViewContainer.centerXAnchor),
        ])


    }



    @objc func addMorePhotos(_ sender: UIButton) {

        cameraPreviewDelegate?.willTakeAditionalPhotos(withImage:self.images)
//        if let image = imagePreview.image {
//            delegate?.willTakeAditionalPhotos(withImage: image)
//        }
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func removePhoto(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        defer {
            sender.isUserInteractionEnabled = true
        }
        if let index = self.selectedIndex?.row {
            cameraPreviewDelegate?.removeSelectedPhoto(targetImage: index)
            // self.photoList.remove(at: index)
        }
//        else if self.images?.count ?? 0 >= 1 {
//            // We will default to 0 since the user did not scroll
//            cameraPreviewDelegate?.removeSelectedPhoto(targetImage: 0)
//        }
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            return
        }
    }

    @objc func completeCapture(_ sender: UIButton) {
        let alertView = SPAlertView(title: "Uploading", preset: .spinner)
        alertView.present()
        sender.isEnabled = false

        if self.capture?.captureID != nil {
            Task {
                do {
                    if let capture = capture {
                        if let images = images {
                            let value = try await CaptureServices.addImages(capture: capture, images: images)
                            if value != nil {
                                if let imgs = value?.images {
                                    self.addImagesToCapture?(imgs, true)
                                }
//                                self.responseCapture?(capture, true)
                                sender.isEnabled = true
                                alertView.dismiss()
                                self.dismissMe()
                            }
                        }
                    }
                } catch { print("Unknown error: \(error)") }
            }
        } else {
            Task {
                if let images = self.images {
                    let coordinatesString = "\(String(format: "%.3f", self.currentLocation.coordinate.latitude)),\(String(format: "%.5f", self.currentLocation.coordinate.longitude))"
                    let capture = try await CaptureServices.createCapture(coordinateString: coordinatesString, images: images)
                    if let unwrapedCapture = capture {
                        self.responseCapture?(unwrapedCapture, nil)
                        sender.isEnabled = true
                        alertView.dismiss()
                        self.dismissMe()
                    }
                }
            }
        }
    }

    func dismissMe() {
        DispatchQueue.main.async {
            // https://stackoverflow.com/a/53496233
            guard self.navigationController?.topViewController == self else { return }
            self.dismiss(animated: true)
        }
    }
}


extension CapturePreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  images?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CaptureDetailCollectionViewCell
        // Configure the cell
        let imageData = Data(base64Encoded: images?[indexPath.row].encoded ?? "", options: .init(rawValue: 0))
        if let imgData = imageData {
            cell.imageView.image = UIImage(data: imgData)
        }

        cell.imageView.contentMode = .scaleAspectFill

        // if user does not scroll, assign the value
        self.selectedIndex = indexPath

        return cell
    }
}

// https://gist.github.com/danielCarlosCE/7a5f80dc6087773ba147be4dc72da826
// https://stackoverflow.com/a/66289855
// https://stackoverflow.com/questions/35045155/how-to-create-a-centered-uicollectionview-like-in-spotifys-player/49844718#49844718
// https://medium.com/@sh.soheytizadeh/zoom-uicollectionview-centered-cell-swift-5-e63cad9bcd49
extension CapturePreviewViewController: UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = cellWidth(forCollectionViewWidth: collectionView.frame.width)
        return CGSize(width: cellWidth, height: collectionView.frame.height - 30.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellDistance(forCollectionViewWidth: collectionView.frame.width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let collectionViewWidth = collectionView.frame.width
        let sides = collectionViewWidth - cellWidth(forCollectionViewWidth: collectionViewWidth)
        let horizontalInset: CGFloat = sides/2
        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }

        let centerPoint = CGPoint(x: self.collectionView.frame.size.width/2 + scrollView.contentOffset.x,
                                  y:self.collectionView.frame.size.height/2 + scrollView.contentOffset.y )

        if let indexPath = self.collectionView.indexPathForItem(at: centerPoint), self.centerCell == nil {
            self.centerCell = (self.collectionView.cellForItem(at: indexPath) as! CaptureDetailCollectionViewCell)
            self.selectedIndex = indexPath
            self.centerCell?.transformToLarge()
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }

        if let cell = self.centerCell {
            let offsetX = centerPoint.x - cell.center.x
            if offsetX < -20 || offsetX > 20 {
                cell.transformToStandard()
                self.centerCell = nil
            }
        }
    }


    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offsetWidthForOneItem = caculateContentOffsetForOneItem(scrollView)
        let offsetForCurrentItem = { CGPoint(x: offsetWidthForOneItem * CGFloat(self.currentPositionIndex), y: targetContentOffset.pointee.y) }

        enum HorizontalDirection { case left, right }
        let horizontalDirection: HorizontalDirection = velocity.x > 0 ? .right : .left

        switch horizontalDirection {
        case .left:
            let isFirstItem = currentPositionIndex <= 0
            guard isFirstItem == false else {
                targetContentOffset.pointee = offsetForCurrentItem()
                return
            }

            currentPositionIndex -= 1
            targetContentOffset.pointee = offsetForCurrentItem()

        case .right:
            let isLastItem = (scrollView.contentOffset.x + offsetWidthForOneItem >= scrollView.contentSize.width)
            guard isLastItem == false else {
                targetContentOffset.pointee = offsetForCurrentItem()
                return
            }

            currentPositionIndex += 1
            targetContentOffset.pointee = offsetForCurrentItem()
        }
    }

    private func cellWidth(forCollectionViewWidth collectionViewWidth: CGFloat) -> CGFloat {
        let itemWidth = collectionViewWidth * cellWitdhPercentage
        return itemWidth
    }

    private func cellDistance(forCollectionViewWidth collectionViewWidth: CGFloat) -> CGFloat {
        let sides = collectionViewWidth - cellWidth(forCollectionViewWidth: collectionViewWidth)
        let oneSide = sides/2
        let final = min(idealCellDistance, oneSide/2)
        return final
    }

    private func caculateContentOffsetForOneItem(_ scrollView: UIScrollView) -> CGFloat {
        let cellItemWidth = cellWidth(forCollectionViewWidth: scrollView.frame.width)
        let sides = scrollView.frame.width - cellItemWidth
        let oneSide: CGFloat = sides/2
        let nextItemVisiblePart = scrollView.frame.width - (oneSide + cellItemWidth + cellDistance(forCollectionViewWidth: scrollView.frame.width))
        return oneSide + (cellItemWidth - nextItemVisiblePart)
    }
}

