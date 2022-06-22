//
//  CaptureReviewViewController.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 3/26/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class CaptureReviewViewController: UIViewController {

    var topView     = UIView()
    var titleLabel  = UILabel()
    var bottomView = UIView()
    var safeArea: UILayoutGuide!
    var collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    var collectionContainer = UIView()
    var submitButton = UIButton()
    var topRightBarButton = UIBarButtonItem()

    var listOfPhotos = [UIImage]()

    private let spacing:CGFloat = 16.0
    private let topHeaderHeight:CGFloat = 20


    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        let layout = UICollectionViewFlowLayout()
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(CaptureDetailCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(NewCaptureCollectionViewCell.self, forCellWithReuseIdentifier: "CaptureCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        self.setupUI()
        self.setupConstraints()
        self.setupCollectionView()
        self.setupNavBar()
    }

    func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        // Set background color
        appearance.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        // Set font
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)
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
        topRightBarButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = topRightBarButton

    }

    func setupUI() {

        self.view.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        safeArea = self.view.layoutMarginsGuide

        collectionContainer = UIView(frame: .zero)
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        collectionContainer.backgroundColor = .systemBlue

        topView = UIView(frame: .zero)
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = .clear

        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Review Captures"
        titleLabel.font = .systemFont(ofSize: 32)
        titleLabel.textColor = .white

        bottomView = UIView(frame: .zero)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = .clear

        submitButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        submitButton.translatesAutoresizingMaskIntoConstraints = false

        let configuration = UIImage.SymbolConfiguration(pointSize: 33, weight: .light, scale: .large)
        let checkMarkSymbol = UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)
        submitButton.tintColor = .white
        submitButton.setTitle("\nDone", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setImage(checkMarkSymbol, for: .normal)
        bottomView.addSubview(submitButton)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = self.view.backgroundColor

        self.view.addSubview(topView)
        topView.addSubview(titleLabel)
        self.view.addSubview(collectionContainer)
        self.view.addSubview(bottomView)
        collectionContainer.addSubview(collectionView)

        self.submitButton.addTarget(self, action: #selector(submitCapture(_:)), for: .touchUpInside)
    }

    func setupConstraints() {

        topView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        topView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        topView.leftAnchor.constraint(equalTo: safeArea.leftAnchor).isActive = true
        topView.rightAnchor.constraint(equalTo: safeArea.rightAnchor).isActive = true

        titleLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true


        collectionContainer.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 3).isActive = true
        collectionContainer.leftAnchor.constraint(equalTo: safeArea.leftAnchor).isActive = true
        collectionContainer.rightAnchor.constraint(equalTo: safeArea.rightAnchor).isActive = true

        bottomView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        bottomView.topAnchor.constraint(equalTo: collectionContainer.bottomAnchor, constant: 10).isActive = true
        bottomView.leftAnchor.constraint(equalTo: safeArea.leftAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        bottomView.rightAnchor.constraint(equalTo: safeArea.rightAnchor).isActive = true

        submitButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        submitButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true


    }

    private func setupCollectionView() {
        collectionView.topAnchor.constraint(equalTo: collectionContainer.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: collectionContainer.leftAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: collectionContainer.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: collectionContainer.rightAnchor).isActive = true
    }

    @objc
    private func editCaptures(_ sender: UIButton) {

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }

        if isEditing {
            isEditing = false
            topRightBarButton.image = UIImage(systemName: "pencil")
            self.navigationItem.leftBarButtonItem = nil
        }
        else {
            isEditing = true
            topRightBarButton.image = UIImage(systemName: "checkmark")
        }
    }

    @objc func submitCapture(_ sender: UIButton) {
        let captureDetail = CaptureDetailViewController()
        captureDetail.listOfPhotos = self.listOfPhotos
        self.navigationController?.pushViewController(captureDetail, animated: true)
    }

}

extension CaptureReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfPhotos.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.row < listOfPhotos.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CaptureDetailCollectionViewCell
            cell?.imageView.image =  listOfPhotos[indexPath.row] // UIImage(named: "backgroundImage")
            if self.isEditing {
                cell?.button.isHidden = false
            }
            else { cell?.button.isHidden = true }
            return cell ?? UICollectionViewCell()
        }
        else {
            let captureCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CaptureCell", for: indexPath) as? NewCaptureCollectionViewCell
            return captureCell ?? UICollectionViewCell()
        }
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // https://stackoverflow.com/a/40808295 https://stackoverflow.com/a/44122977
        if indexPath.row == listOfPhotos.count {
            if let navController = self.navigationController {
                for controller in navController.viewControllers {
                    if controller is CaptureCameraViewController {
                        navController.popToViewController(controller, animated:true)
                        if let previousViewController = self.navigationController?.viewControllers.last as? CaptureCameraViewController {
                            previousViewController.photoList = self.listOfPhotos
                        }
                        break
                    }
                }
            }
        }
        else {
            if self.isEditing {
                self.listOfPhotos.remove(at: indexPath.row)
                collectionView.reloadData()
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
}
