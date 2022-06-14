//
//  CaptureDetailCollectionViewCell.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 3/20/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class CaptureDetailCollectionViewCell: UICollectionViewCell {

    let card      = UIView(frame: .zero)
    let imageView = UIImageView(frame: .zero)
    let button    = UIButton()

    var isMarked: Bool = false {
        didSet {
            if isMarked {
                self.button.isHidden = false

            } else {
                self.button.isHidden = true
            }
        }
    }

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


        let largeConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "x.circle.fill", withConfiguration: largeConfig)
        self.button.setImage(largeBoldDoc, for: .normal)
        self.button.tintColor = .white
        self.button.layer.cornerRadius = 20
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.button)
        self.contentView.bringSubviewToFront(self.button)
        self.button.isHidden = true
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

        self.button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.button.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: -12).isActive = true
        self.button.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: -10).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        isMarked = false

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
