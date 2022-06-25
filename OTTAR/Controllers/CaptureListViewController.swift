//
//  CaptureListViewController.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 12/2/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import Get
import SPAlert

class CaptureListViewController: UIViewController {

    enum Section: CaseIterable {
        case main
    }

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Capture>
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Capture> = {
        let dataSource = UICollectionViewDiffableDataSource <Section, Capture>(collectionView: captureCollectionView) {
            [weak self] (collectionView: UICollectionView, indexPath: IndexPath, capture: Capture) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CaptureListCollectionViewCell

            let capture = self?.capturesList?.captures[indexPath.row]
            // Configure the cell
            if let id = capture?.captureID {
                cell?.titleLabel.text = "Capture: \(id)"
            }

            let myFormatter = DateFormatter()
            myFormatter.dateStyle = .medium
            myFormatter.timeZone = TimeZone(identifier: "UTC")

            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            formatter.timeZone = TimeZone(identifier: "UTC")

            if let dateUpdated = capture?.dateUpdated {
                cell?.timeLabel.text = String(format: "%@ UTC", formatter.string(from: dateUpdated))
                cell?.dateLabel.text = myFormatter.string(from: dateUpdated)
                cell?.clockImageView.tintColor = .systemRed
            } else {
                if let dateCreated = capture?.dateCreated {
                    cell?.timeLabel.text = String(format: "%@ UTC", formatter.string(from: dateCreated))
                    cell?.dateLabel.text = myFormatter.string(from: dateCreated)
                }
            }

            cell?.locationLabel.text = capture?.coordinates
            cell?.layoutSubviews()
            return cell
        }
        return dataSource
    }()

    var captureCollectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    var safeArea: UILayoutGuide!
    var capturePreviewController = CapturePreviewViewController(images: nil, capture: nil)
    var preferences = APIPreferencesLoader.load()
    var topLeftBarButton = UIBarButtonItem()
    var captureToDelete: [Capture] = []
    private var capturesList: Captures? {
        didSet {
            DispatchQueue.main.async {
                var snapshot = Snapshot()
                snapshot.appendSections([.main])
                if let captures = self.capturesList?.captures {
                    snapshot.appendItems(captures, toSection: .main)
                    self.dataSource.apply(snapshot, animatingDifferences: true)
                }
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captures"
        edgesForExtendedLayout = []
        self.navigationController?.navigationBar.backgroundColor  = .white
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:self.view.frame.width - 30, height: 105)
        captureCollectionView.automaticallyAdjustsScrollIndicatorInsets = false
        captureCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        captureCollectionView.register(CaptureListCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        captureCollectionView.delegate = self
        // captureCollectionView.dataSource = self
        captureCollectionView.clipsToBounds = true
        self.view.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        self.captureCollectionView.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        self.view.addSubview(captureCollectionView)
        setupUI()
        setupCollectionView()
        Task {
            await self.fetchCaptures()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewDidLayoutSubviews()
        self.captureCollectionView.collectionViewLayout.invalidateLayout()
        print("Server: \(preferences.baseURL)")
        if preferences.baseURL.isEmpty {
            self.presentInput()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.captureCollectionView.collectionViewLayout.invalidateLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = self.captureCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
        flowLayout.itemSize = CGSize(width:size.width - 30, height: 105)
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.presentInput()
        }
    }

    func presentInput() {
        // http://140.82.3.140
        let alertController = UIAlertController(title: "Server Address",
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Server IP"
        }

        let continueAction = UIAlertAction(title: "Continue",
                                           style: .default) { [weak alertController] _ in
            guard let textFields = alertController?.textFields else { return }
            if let ipText = textFields[0].text {
                self.preferences.baseURL = (String(format: "http://%@", ipText))
                APIPreferencesLoader.write(preferences: self.preferences)
                print("IP: \(APIPreferencesLoader.load().baseURL)")
                OTTARNetworkAPI.sharedInstance.updateClient()
                Task {
                    await self.fetchCaptures()
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)

        alertController.addAction(cancelAction)
        alertController.addAction(continueAction)
        self.present(alertController, animated: true)
    }

    func fetchCaptures() async {
        Task {
            do {
                self.capturesList =  try await CaptureServices.getCaptures()
                DispatchQueue.main.async {
                    //                    self.captureCollectionView.reloadData()
                    self.captureCollectionView.collectionViewLayout.invalidateLayout()
                }
            } catch {
                print("Unknown error: \(error)")
            }

        }
    }

    func setupUI () {
        safeArea = self.view.layoutMarginsGuide
        let newCaptureButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.myRightSideBarButtonItemTapped(_:)))
        newCaptureButton.tintColor = .black

        self.navigationItem.rightBarButtonItem = newCaptureButton


        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20.0),
                                          .foregroundColor: UIColor.black]

        // Customizing our navigation bar
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        topLeftBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editCaptures(_:)))
        topLeftBarButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = topLeftBarButton
        self.navigationController?.navigationBar.tintColor = .black

    }

    @objc
    private func editCaptures(_ sender: UIButton) {
        if self.isEditing {
            self.isEditing = false
            topLeftBarButton.title = "Edit"
        }
        else {
            self.isEditing = true
            topLeftBarButton.title = "Done"
        }
    }

    @objc func myRightSideBarButtonItemTapped(_ sender:UIBarButtonItem!)
    {
        let cameraVC = CaptureCameraViewController.init()

        // use back the old iOS 12 modal full screen style
        cameraVC.modalPresentationStyle = .overCurrentContext
        cameraVC.modalPresentationCapturesStatusBarAppearance = true

        let navigationController = UINavigationController(rootViewController: cameraVC)
        navigationController.modalPresentationStyle = .fullScreen
        // https://stackoverflow.com/a/62301281
        navigationController.navigationBar.barStyle = .black
        cameraVC.capturePreview.responseCapture = { (value, boolean) in
            DispatchQueue.main.async {
                let detailController = CaptureDetailViewController(capture: value)
                detailController.title = "Capture Detail: \(value.captureID)"
                self.navigationController?.pushViewController(detailController, animated: true)
                DispatchQueue.main.async {
                    Task {
                        self.capturesList =  try await CaptureServices.getCaptures()
                        DispatchQueue.main.async {
                            var snapshot = self.dataSource.snapshot()
                            snapshot.reloadSections([Section.main])
                            self.dataSource.apply(snapshot)
                        }
                    }
                }
            }
        }
        self.present(navigationController, animated: true, completion: nil)
    }

    private func setupCollectionView() {
        captureCollectionView.layer.cornerRadius = 20
        captureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        captureCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        captureCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        captureCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        captureCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

    }
}

extension CaptureListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditing {
            if let capture = dataSource.itemIdentifier(for: indexPath) {
                let alertController = UIAlertController(title: "Delete Capture: \(capture.captureID)",
                                                        message: nil,
                                                        preferredStyle: .alert)

                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                let deleteAction = UIAlertAction(title: "Delete",
                                                 style: .destructive) { _ in
                    self.captureToDelete.append(capture)
                    self.deleteCapture(capture.captureID)
                }

                alertController.addAction(cancelAction)
                alertController.addAction(deleteAction)
                self.present(alertController, animated: true)
                print("Capture ID: \(capture.captureID)")
            }
        }
        else {
            if let capture = capturesList?.captures[indexPath.row] {
                DispatchQueue.main.async {
                    let captureDetail = CaptureDetailViewController(capture: capture)
                    captureDetail.deleteResponseCapture = { (value, boolean) in
                        DispatchQueue.main.async {
                            self.captureCollectionView.reloadData()
                            self.captureCollectionView.collectionViewLayout.invalidateLayout()
                        }

                        self.capturesList?.captures.remove(at: indexPath.row)
                        self.captureCollectionView.performBatchUpdates({
                            self.captureCollectionView.deleteItems(at: [indexPath])
                        })
                    }
                    captureDetail.navigationItem.title = "Capture Detail: \(capture.captureID)"

                    self.navigationController?.pushViewController(captureDetail, animated: true)
                }
            }
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 5, bottom: 15, right: 5)
    }
}

// https://stackoverflow.com/a/63818404
extension String {
    func getAttributedString<T>(_ key: NSAttributedString.Key, value: T) -> NSAttributedString {
        let applyAttribute = [ key: T.self ]
        let attrString = NSAttributedString(string: self, attributes: applyAttribute)
        return attrString
    }
}


extension CaptureListViewController {
    @objc
    func deleteCapture(_ captureId: Int) {
        Task {
            try await CaptureServices.deleteCapture(captureId: captureId)
            let alertView = SPAlertView(title: "Deleted", preset: .done)
            alertView.duration = 0.75
            alertView.present()
            alertView.dismiss()

            var snapshot = dataSource.snapshot()
            snapshot.deleteItems(self.captureToDelete)
            snapshot.reloadSections([Section.main])
            self.dataSource.apply(snapshot, animatingDifferences: true) {
                for i in self.captureToDelete {
                    self.capturesList?.captures.removeAll(where: {$0.id == i.id})
                }
            }
        }
    }
}
