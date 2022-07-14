//
//  CaptureDetailCreateImageCollectionViewCell.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 7/4/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class CaptureDetailCreateImageCollectionViewCell: CaptureDetailCollectionViewCell {
    var createImage:CreateImage?


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.setupConstrainsts()
        self.checkmarkView.isHidden = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    func configure(for image:CreateImage) {
        self.createImage = image

        let imageData = Data(base64Encoded: image.encoded, options: .init(rawValue: 0))

        let targetSize = CGSize(width: self.contentView.frame.width, height: self.contentView.frame.height)

        if let imgData = imageData {
            self.imageView.image = UIImage(data: imgData)?.scalePreservingAspectRatio(targetSize: targetSize)
        }
        self.imageView.contentMode = .scaleAspectFill
    }

    private func setupUI() {
        self.contentView.addSubview(self.card)
        self.card.addSubview(self.imageView)
        self.card.translatesAutoresizingMaskIntoConstraints = false
        self.card.layer.cornerRadius = 15.0
        self.card.clipsToBounds = true
        checkmarkView = SSCheckMark(frame: .zero)
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.backgroundColor = .clear
//        checkmarkView.clipsToBounds = true
//        self.imageView.clipsToBounds = true
//        self.imageView.backgroundColor = .systemGray
//        self.imageView.contentMode = .scaleAspectFill
//        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.card.addSubview(checkmarkView)
    }

    private func setupConstrainsts() {

        self.card.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.card.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.card.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.card.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        self.imageView.topAnchor.constraint(equalTo: self.card.topAnchor).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.card.leftAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.card.bottomAnchor).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.card.rightAnchor).isActive = true

        checkmarkView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        checkmarkView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        checkmarkView.bottomAnchor.constraint(equalTo: self.card.bottomAnchor, constant: -10).isActive = true
        checkmarkView.trailingAnchor.constraint(equalTo: self.card.trailingAnchor, constant: -20).isActive = true

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        checkmarkView.isHidden = true
    }
}
