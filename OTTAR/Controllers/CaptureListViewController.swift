//
//  CaptureListViewController.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 12/2/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import Get

class CaptureListViewController: UIViewController {


    var captureCollectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    var safeArea: UILayoutGuide!
    var capturesList:Captures?
    var capturePreviewController = CapturePreviewViewController(images: nil, capture: nil)
    var invalidURL = false
    var preferences = APIPreferencesLoader.load()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captures"
        edgesForExtendedLayout = []
        // https://www.hackingwithswift.com/example-code/uikit/how-to-stop-your-view-going-under-the-navigation-bar-using-edgesforextendedlayout
        // https://stackoverflow.com/questions/24402000/uinavigationbar-text-color-in-swift
        // https://stackoverflow.com/questions/39438606/change-navigation-bar-title-font-swift
//        self.navigationController?.navigationBar.isTranslucent = true
//        extendedLayoutIncludesOpaqueBars = true
//        self.navigationController?.navigationBar.backgroundColor  = .white
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black,
//                                                                        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 20)!
//]
        self.navigationController?.navigationBar.backgroundColor  = .white
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:self.view.frame.width - 30, height: 105)
        captureCollectionView.automaticallyAdjustsScrollIndicatorInsets = false
        captureCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        captureCollectionView.register(CaptureListCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        captureCollectionView.delegate = self
        captureCollectionView.dataSource = self
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

        alertController.addAction(continueAction)

        self.present(alertController,
                     animated: true)

    }

    func fetchCaptures() async {
        Task {
            do {
                self.capturesList =  try await CaptureServices.getCaptures()
                DispatchQueue.main.async {
                    self.captureCollectionView.reloadData()
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

//        if #available(iOS 15, *) {
//                    let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
//                    let appearance = UINavigationBarAppearance()
//                    appearance.configureWithOpaqueBackground()
//                    appearance.titleTextAttributes = textAttributes
//                    appearance.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
//                    appearance.shadowColor = .clear  //removing navigationbar 1 px bottom border.
//                    UINavigationBar.appearance().standardAppearance = appearance
//                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
//                }
    }


//    func getCaptures() async {
//        do {
//            capturesList = try await
//            OTTARNetworkAPI.sharedInstance.client.send(Paths.captures.get).value
//            DispatchQueue.main.async {
//                self.captureCollectionView.reloadData()
//            }
//        }
//        catch {
//            print("Fetching images failed with error \(error)")
//        }
//    }

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
                            self.captureCollectionView.reloadData()
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

extension CaptureListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturesList?.captures.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CaptureListCollectionViewCell

        let capture = self.capturesList?.captures[indexPath.row]
        // Configure the cell
        if let id = capture?.captureID {
            cell.titleLabel.text = "Capture: \(id)"
        }

        let myFormatter = DateFormatter()
        myFormatter.dateStyle = .medium
        myFormatter.timeZone = TimeZone(identifier: "UTC")

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")

        if let dateUpdated = capture?.dateUpdated {
            cell.timeLabel.text = String(format: "%@ UTC", formatter.string(from: dateUpdated))
            cell.dateLabel.text = myFormatter.string(from: dateUpdated)
            cell.clockImageView.tintColor = .systemRed
        } else {
            if let dateCreated = capture?.dateCreated {
                cell.timeLabel.text = String(format: "%@ UTC", formatter.string(from: dateCreated))
                cell.dateLabel.text = myFormatter.string(from: dateCreated)
            }
        }



        cell.locationLabel.text = capture?.coordinates
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

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
