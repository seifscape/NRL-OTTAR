//
//  ImageViewController.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 6/14/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class CaptureImageViewController: UIViewController {

    let image:Image
    let imageView = UIImageView(frame: .zero)

    init(image: Image) {
        self.image = image
        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupConstraints()
        self.imageView.sizeToFit()
        let imageData = Data(base64Encoded: self.image.encoded, options: .init(rawValue: 0))
        if let imgData = imageData {
            self.imageView.image = UIImage(data: imgData)
            self.imageView.layoutIfNeeded()
        }
    }

    func setupUI() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.imageView)
    }

    func setupConstraints() {
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
}
