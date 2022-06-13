//
//  CaptureListViewController.swift
//  InspectorMines
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captures"
        // https://www.hackingwithswift.com/example-code/uikit/how-to-stop-your-view-going-under-the-navigation-bar-using-edgesforextendedlayout
        // https://stackoverflow.com/questions/24402000/uinavigationbar-text-color-in-swift
        edgesForExtendedLayout = []
//        self.navigationController?.navigationBar.isTranslucent = true
//        extendedLayoutIncludesOpaqueBars = true
        // https://stackoverflow.com/questions/39438606/change-navigation-bar-title-font-swift
//        self.navigationController?.navigationBar.backgroundColor  = .white
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black,
//                                                                        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 20)!
//]
        self.navigationController?.navigationBar.backgroundColor  = .white
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:self.view.frame.width - 50, height: 120)
        captureCollectionView.automaticallyAdjustsScrollIndicatorInsets = false
        captureCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        captureCollectionView.register(CaptureListCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        captureCollectionView.delegate = self
        captureCollectionView.dataSource = self
        self.view.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        self.captureCollectionView.backgroundColor = UIColor(red:0.09, green:0.16, blue:0.34, alpha:1.00)
        self.view.addSubview(captureCollectionView)
        setupUI()
        setupCollectionView()
        Task {
            await self.getCaptures()
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


    func getCaptures() async {
        do {
            capturesList = try await
            InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.captures.get).value
            DispatchQueue.main.async {
                self.captureCollectionView.reloadData()
            }
        }
        catch {
            print("Fetching images failed with error \(error)")
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
                self.navigationController?.pushViewController(CaptureDetailViewController(capture: value), animated: true)
                self.reloadTable()
            }
        }
        self.present(navigationController, animated: true, completion: nil)
    }

    private func reloadTable() {
        Task {
            await self.getCaptures()
        }
    }

    private func setupCollectionView() {
        captureCollectionView.layer.cornerRadius = 20
        captureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        captureCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        captureCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        captureCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        captureCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

    }

//    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
//       if let _ = viewControllerToPresent as? CaptureCameraViewController {
//           viewControllerToPresent.modalPresentationStyle = .fullScreen
//       }
//       super.present(viewControllerToPresent, animated: flag, completion: completion)
//   }
}

extension CaptureListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturesList?.captures.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CaptureListCollectionViewCell
        if let id = capturesList?.captures[indexPath.row].captureID {
            cell.titleLabel.text = "Capture: \(id)"
        }
        cell.locationLabel.text = capturesList?.captures[indexPath.row].coordinates
        // Configure the cell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let capture = capturesList?.captures[indexPath.row] {
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(CaptureDetailViewController(capture: capture), animated: true)
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
