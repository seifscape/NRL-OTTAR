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
    let button    = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.setupConstrainsts()
        self.button.isHidden = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI() {
        self.contentView.addSubview(self.imageView)
        self.imageView.clipsToBounds = true
        self.imageView.backgroundColor = .systemGray
        self.imageView.layer.cornerRadius = 15.0
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.translatesAutoresizingMaskIntoConstraints = false


        let largeConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "x.circle.fill", withConfiguration: largeConfig)
        self.button.setImage(largeBoldDoc, for: .normal)
        self.button.tintColor = .black
        self.button.layer.cornerRadius = 20
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.button)
        self.contentView.bringSubviewToFront(self.button)
    }

    private func setupConstrainsts() {
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        self.button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.button.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: -8).isActive = true
        self.button.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: -10).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil

//        for subview in subviews {
//            subview.removeConstraints(subview.constraints)
//            subview.removeFromSuperview()
//        }
//
//        self.removeFromSuperview() // BURN EVERYTHING
    }
}
