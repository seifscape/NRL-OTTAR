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

    func configure(for image:CreateImage) {
        self.createImage = image

        let imageData = Data(base64Encoded: image.encoded, options: .init(rawValue: 0))

        let targetSize = CGSize(width: self.contentView.frame.width, height: self.contentView.frame.height)

        if let imgData = imageData {
            self.imageView.image = UIImage(data: imgData)?.scalePreservingAspectRatio(targetSize: targetSize)
        }
        self.imageView.contentMode = .scaleAspectFill
    }
}
