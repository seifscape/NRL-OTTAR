//
//  CaptureDetailViewController.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 3/13/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class CaptureDetailViewController: UIViewController {

    var topHeaderView  = UIView()
    var textViewContainer = UIView()
    let textView = UITextView()
    var collectionContainer = UIView()
    var safeArea: UILayoutGuide!
    var collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    var topRightBarButton = UIBarButtonItem()
    var floatingButton = UIButton()
    private let spacing:CGFloat = 16.0
    private let topHeaderHeight:CGFloat = 150.0
    var listOfPhotos = [UIImage]()



    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
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
        

    }

    @objc
    private func editCaptures(_ sender: UIButton) {

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        if isEditing {
            isEditing = false
            topHeaderView.isUserInteractionEnabled = false
            textView.isEditable = false
            topRightBarButton.image = UIImage(systemName: "pencil")
            self.navigationItem.leftBarButtonItem = nil
            self.floatingButton.isHidden = true
        }
        else {
            isEditing = true
            topHeaderView.isUserInteractionEnabled = true
            textView.isEditable = true
            textView.isSelectable = true
            topRightBarButton.image = UIImage(systemName: "checkmark")
            self.floatingButton.isHidden = false
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

        let textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        //textView.center = topHeaderView.center
        textView.contentInsetAdjustmentBehavior = .never
         textView.textAlignment = NSTextAlignment.justified
        textView.textColor = UIColor.black
        textView.font = .preferredFont(forTextStyle: .body, compatibleWith: .current)
        textView.isEditable = false
        textView.isSelectable = false
        // textView.backgroundColor = UIColor.lightGray
//        textView.sizeToFit()
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
        self.floatingButton.addTarget(self, action: #selector(addMorePhotos(sender:)), for: .touchUpInside)

    }

    @objc func addMorePhotos(sender:UIButton) {
        self.navigationController?.pushViewController(CameraViewController.init(), animated: true)
    }


    func setupUIManual() {
        var topHeaderView  = UIView()
        var collectionContainer = UIView()
        topHeaderView = UIView(frame: CGRect(x: 0,
                                           y: 0,
                                           width: view.frame.width,
                                           height: 250))

        collectionContainer = UIView(frame: CGRect(x: 0,
                                                   y: topHeaderView.frame.height + 3,
                                                   width: view.frame.width,
                                                   height: view.frame.height - topHeaderView.frame.height - 5 ))
        topHeaderView.backgroundColor = .systemBlue
        collectionContainer.backgroundColor = .systemRed

        self.view.addSubview(topHeaderView)
        self.view.addSubview(collectionContainer)
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
}


extension CaptureDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "captureDetailCell", for: indexPath) as! CaptureDetailCollectionViewCell
        cell.imageView.image = listOfPhotos[indexPath.row]   //UIImage(named: "backgroundImage")
        cell.imageView.contentMode = .scaleToFill

        if self.isEditing {
            cell.button.isHidden = false
        }
        else { cell.button.isHidden = true }
        // Configure the cell
        return cell
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

    func downsample(imageAt imageURL: URL,
                    to pointSize: CGSize,
                    scale: CGFloat = UIScreen.main.scale) -> UIImage? {

        // Create an CGImageSource that represent an image
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
            return nil
        }

        // Calculate the desired dimension
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale

        // Perform downsampling
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        // Return the downsampled image as UIImage
        return UIImage(cgImage: downsampledImage)
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
}
