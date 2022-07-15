//
//  CaptureDetailCollectionViewCell.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 3/20/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import CoreGraphics

class CaptureDetailCollectionViewCell: UICollectionViewCell {

    let card      = UIView(frame: .zero)
    let imageView = UIImageView(frame: .zero)
    let button    = UIButton()
    var checkmarkView: SSCheckMark!
    var image:Image?


    var isMarked: Bool = false {
        didSet {
            if isMarked {
                self.checkmarkView.checked = true
                self.checkmarkView.isHidden = false
            } else {
                self.checkmarkView.checked = false
                self.checkmarkView.isHidden = true
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.setupConstrainsts()
        self.checkmarkView.isHidden = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    func configure(for image:Image) {
        self.image = image

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
        checkmarkView.clipsToBounds = true
        self.card.addSubview(checkmarkView)
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
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

    func transformToLarge() {
        UIView.animate(withDuration:0.2){
            self.transform = CGAffineTransform(translationX: 1.0, y: -14.0)
            self.card.layoutSubviews()
        }
    }

    func transformToStandard() {
        UIView.animate(withDuration:0.2){
            self.transform = CGAffineTransform.identity
        }
    }

    func showCheckmark() {
        self.isMarked = true
        self.checkmarkView.checked = true
    }

    func hideCheckmark() {
        self.isMarked = false
        self.checkmarkView.checked = false
    }
}


extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }

        return scaledImage
    }
}
