//
//  CaptureDetailCollectionViewCell.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 3/20/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class CaptureDetailCollectionViewCell: UICollectionViewCell {


    let imageView = UIImageView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.setupConstrainsts()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI() {
        self.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray
        imageView.layer.cornerRadius = 15.0
        imageView.contentMode = .scaleAspectFill
        // imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstrainsts() {
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

//    override func prepareForReuse() {
//        super.prepareForReuse()
////        imageView.image = nil
//
//        for subview in subviews {
//            subview.removeConstraints(subview.constraints)
//            subview.removeFromSuperview()
//        }
//
//        self.removeFromSuperview() // BURN EVERYTHING
//    }
}
