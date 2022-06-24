//
//  CaptureDetailCollectionViewCell.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 3/20/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class CaptureDetailCollectionViewCell: UICollectionViewCell {

    let card      = UIView(frame: .zero)
    let imageView = UIImageView(frame: .zero)
    let button    = UIButton()
    var checkmarkView: SSCheckMark!
    var image:Image?


//    override var isSelected: Bool {
//        didSet {
//            if isSelected {
//                self.checkmarkView.checked = isSelected
//            } else {
//                // do opposite color
//                self.checkmarkView.checked = isSelected
//            }
//            self.checkmarkView.isHidden = !isSelected
//         }
//    }

    var isMarked: Bool = false {
        didSet {
            if isMarked {
                self.checkmarkView.checked = true
                self.checkmarkView.isHidden = false
                //self.button.isHidden = false
            } else {
                self.checkmarkView.checked = false
                self.checkmarkView.isHidden = true
                //self.button.isHidden = true
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.setupConstrainsts()
        //self.checkmarkView.checked = self.isMarked
        self.checkmarkView.isHidden = true
        //self.button.isHidden = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    func configure(for image:Image) {
        self.image = image

        let imageData = Data(base64Encoded: image.encoded, options: .init(rawValue: 0))

        if let imgData = imageData {
            self.imageView.image = UIImage(data: imgData)
        }
        self.imageView.contentMode = .scaleToFill
    }

    private func setupUI() {
        self.contentView.addSubview(self.card)
        self.card.addSubview(self.imageView)
        self.card.translatesAutoresizingMaskIntoConstraints = false
        self.card.layer.cornerRadius = 15.0
        self.card.clipsToBounds = true
        self.imageView.clipsToBounds = true
        self.imageView.backgroundColor = .systemGray
        //self.imageView.layer.cornerRadius = 15.0
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.translatesAutoresizingMaskIntoConstraints = false


        //        let largeConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .bold, scale: .large)
        //        let largeBoldDoc = UIImage(systemName: "x.circle.fill", withConfiguration: largeConfig)
        //        self.button.setImage(largeBoldDoc, for: .normal)
        //        self.button.tintColor = .white
        //        self.button.layer.cornerRadius = 20
        //        self.button.translatesAutoresizingMaskIntoConstraints = false
        //        self.contentView.addSubview(self.button)
        //        self.contentView.bringSubviewToFront(self.button)
        //        self.button.isHidden = true

        checkmarkView = SSCheckMark(frame: .zero)
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.backgroundColor = .clear
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
        checkmarkView.bottomAnchor.constraint(equalTo: self.card.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        checkmarkView.trailingAnchor.constraint(equalTo: self.card.trailingAnchor, constant: -20).isActive = true

        //        self.button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        //        self.button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        //        self.button.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: -12).isActive = true
        //        self.button.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: -10).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        checkmarkView.isHidden = true
    

        //        for subview in subviews {
        //            subview.removeConstraints(subview.constraints)
        //            subview.removeFromSuperview()
        //        }
        //
        //        self.removeFromSuperview() // BURN EVERYTHING
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
}
