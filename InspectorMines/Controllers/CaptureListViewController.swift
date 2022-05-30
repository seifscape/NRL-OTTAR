//
//  CaptureListViewController.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 12/2/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class CaptureListViewController: UIViewController {


    var captureCollectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    var safeArea: UILayoutGuide!

    var capturesList:Captures?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captures"
        // https://www.hackingwithswift.com/example-code/uikit/how-to-stop-your-view-going-under-the-navigation-bar-using-edgesforextendedlayout
        // https://stackoverflow.com/questions/24402000/uinavigationbar-text-color-in-swift
//        edgesForExtendedLayout = []
        // https://stackoverflow.com/questions/39438606/change-navigation-bar-title-font-swift
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                                        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 20)!
]
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
        fetchCaptures()
    }

    func setupUI () {
//        self.view.backgroundColor = .white
//        self.view.layer.cornerRadius = 20
//        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        self.view.layer.shadowColor = UIColor.black.cgColor
//        self.view.layer.shadowOffset = .init(width: 0, height: -2)
//        self.view.layer.shadowRadius = 10
//        self.view.layer.shadowOpacity = 0.5
        safeArea = self.view.layoutMarginsGuide

        let newCaptureButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.myRightSideBarButtonItemTapped(_:)))
        newCaptureButton.tintColor = .white

        self.navigationItem.rightBarButtonItem = newCaptureButton
    }

    func fetchCaptures() {
        let url = URL(string: "http://127.0.0.1:1111/captures")
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (captures: Captures?, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.capturesList = captures
            DispatchQueue.main.async {
                self.captureCollectionView.reloadData()
            }
            captures?.captures?.forEach({ print("\($0.annotation)\n") })
        })
        task.resume()
    }

    func createCapture() {
        let uploadCaptureModel = Capture(albumID: 0, annotation: "", coordinates: "", dateCreated: "", dateUpdated: "")

        guard let jsonData = try? JSONEncoder().encode(uploadCaptureModel) else {
            print("Error: Trying to covert model to JSON data")
            return
        }
        

    }

    @objc func myRightSideBarButtonItemTapped(_ sender:UIBarButtonItem!)
    {
        let cameraVC = CameraViewController.init()
        self.navigationController?.pushViewController(cameraVC, animated: true)
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
        var numberOfItems = 0
        if let list = capturesList {
            if let captures = list.captures {
                numberOfItems = captures.count
            }
        }
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CaptureListCollectionViewCell
        if let albumID = capturesList?.captures?[indexPath.row].albumID {
            cell.titleLabel.text = "Capture: \(albumID)"
        }
        cell.locationLabel.text = capturesList?.captures?[indexPath.row].coordinates
        // Configure the cell
        return cell
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
