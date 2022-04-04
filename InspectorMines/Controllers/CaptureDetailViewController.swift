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
    private let spacing:CGFloat = 16.0
    private let topHeaderHeight:CGFloat = 150.0


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Capture Detail"
        edgesForExtendedLayout = []
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(self.view.frame.width/2.1) - spacing, height: (self.view.frame.height-topHeaderHeight)/3)
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        collectionView.register(CaptureDetailCollectionViewCell.self, forCellWithReuseIdentifier: "captureDetailCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        self.setupUI()
        self.setupConstraints()
        self.setupCollectionView()
        

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
        textView.center = topHeaderView.center
        textView.contentInsetAdjustmentBehavior = .automatic
        textView.textAlignment = NSTextAlignment.justified
        textView.textColor = UIColor.black
        textView.font = .systemFont(ofSize: 16)
        // textView.backgroundColor = UIColor.lightGray
        textView.text = "This is some text."
        topHeaderView.addSubview(textView)
        textView.sizeToFit()
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
        textView.leadingAnchor.constraint(equalTo: topHeaderView.leadingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: topHeaderView.bottomAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: topHeaderView.trailingAnchor).isActive = true

        collectionContainer.topAnchor.constraint(equalTo: topHeaderView.bottomAnchor, constant: 20).isActive = true
        collectionContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        collectionContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
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
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "captureDetailCell", for: indexPath) as! CaptureDetailCollectionViewCell
        cell.imageView.image = UIImage(named: "backgroundImage")
        // Configure the cell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
}
