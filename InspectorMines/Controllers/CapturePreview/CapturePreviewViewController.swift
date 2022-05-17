//
//  CapturePreviewViewController.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 5/12/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import FINNBottomSheet
import CollectionViewPagingLayout


protocol CapturePreviewControllerDelegate: AnyObject {
    func willTakeAditionalPhotos(withImage image: UIImage)
    func removeSelectedPhoto(targetImage targetPhoto: UIImage)
}

class CapturePreviewViewController: UIViewController {

    var previewContainer = UIView()
    var imagePreview     = UIImageView()
    var safeArea: UILayoutGuide!
    weak var delegate: CapturePreviewControllerDelegate?
    var photoList = [UIImage]()
    var indexOfCellBeforeDragging: Int = 0


    private let cellWitdhPercentage: CGFloat = 0.85
    private let idealCellDistance: CGFloat = 16

    private var currentPositionIndex = 0

    private let collectionView: UICollectionView = {
        let viewLayout = UICollectionViewFlowLayout()
        viewLayout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: viewLayout)
        collectionView.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.decelerationRate = .fast
        return collectionView
    }()

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
        self.collectionView.decelerationRate = .fast

        collectionView.register(CaptureDetailCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast

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
        imagePreview.translatesAutoresizingMaskIntoConstraints = false
        imagePreview.contentMode = .scaleToFill
        view.addSubview(previewContainer)
        previewContainer.addSubview(collectionView)
    }

    func setupConstraints() {
        previewContainer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 25).isActive = true
        previewContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant:0).isActive = true
        previewContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        previewContainer.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -100).isActive = true

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: previewContainer.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: previewContainer.leftAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: previewContainer.rightAnchor).isActive = true

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
        delegate?.removeSelectedPhoto(targetImage: self.photoList.last ?? UIImage())
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

extension CapturePreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CaptureDetailCollectionViewCell
        cell.imageView.image = photoList[indexPath.row] //UIImage(named: "backgroundImage")
        cell.imageView.contentMode = .scaleAspectFill
        // Configure the cell
        return cell
    }
}

// https://gist.github.com/danielCarlosCE/7a5f80dc6087773ba147be4dc72da826
// https://stackoverflow.com/a/66289855
// https://stackoverflow.com/questions/35045155/how-to-create-a-centered-uicollectionview-like-in-spotifys-player/49844718#49844718
extension CapturePreviewViewController: UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = cellWidth(forCollectionViewWidth: collectionView.frame.width)
        return CGSize(width: cellWidth, height: collectionView.frame.height)
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

