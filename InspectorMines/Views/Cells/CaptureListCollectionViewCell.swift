//
//  CaptureListCollectionViewCell.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 2/14/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class CaptureListCollectionViewCell: UICollectionViewCell {

    let titleLabel = UILabel()
    let locationLabel = UILabel()
    let dateLabel = UILabel()
    let timeLabel = UILabel()
    let mainStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.text = "First Capture"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: self.frame.height/2).isActive = true



        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .horizontal
        mainStackView.distribution = .fill
        mainStackView.clipsToBounds = true
        mainStackView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: self.bounds.width,
                                     height: self.bounds.height/2)

        mainStackView.backgroundColor = .white
        self.addSubview(mainStackView)
        mainStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        mainStackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .light, scale: .medium)
        let pinSymbol = UIImage(systemName: "mappin", withConfiguration: configuration)
        let clockSymbol = UIImage(systemName: "clock.fill", withConfiguration: configuration)

        let pinImageView = UIImageView(image: pinSymbol)
        pinImageView.translatesAutoresizingMaskIntoConstraints = false

        let clockImageView = UIImageView(image: clockSymbol)
        clockImageView.translatesAutoresizingMaskIntoConstraints = false

        let locationViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: mainStackView.frame.width/2, height: mainStackView.frame.height))
        locationViewContainer.translatesAutoresizingMaskIntoConstraints = false

        let horizontalStackView = UIStackView()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.backgroundColor = .white
        horizontalStackView.addArrangedSubview(pinImageView)



        locationLabel.textColor = .black
        locationLabel.text = "38.8228°, 77.0179°"
        locationLabel.font = .systemFont(ofSize: 14)
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.addArrangedSubview(locationLabel)
        locationViewContainer.addSubview(horizontalStackView)

        mainStackView.addArrangedSubview(locationViewContainer)
        locationViewContainer.leftAnchor.constraint(equalTo: mainStackView.leftAnchor).isActive = true
        horizontalStackView.centerYAnchor.constraint(equalTo: locationViewContainer.centerYAnchor).isActive = true




        let dateTimeViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: mainStackView.frame.width/2, height: mainStackView.frame.height))
        dateTimeViewContainer.translatesAutoresizingMaskIntoConstraints = false
        dateTimeViewContainer.addSubview(clockImageView)

        let verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.backgroundColor = .white

        timeLabel.text = "21:31:54 UTC"
        timeLabel.font = .systemFont(ofSize: 14)

        dateLabel.text = "Feb. 4, 2022"
        dateLabel.font = .systemFont(ofSize: 14)
        verticalStackView.addArrangedSubview(timeLabel)
        verticalStackView.addArrangedSubview(dateLabel)
        dateTimeViewContainer.addSubview(verticalStackView)
        verticalStackView.rightAnchor.constraint(equalTo: dateTimeViewContainer.rightAnchor, constant: -14).isActive = true
        verticalStackView.centerYAnchor.constraint(equalTo: dateTimeViewContainer.centerYAnchor).isActive = true

        clockImageView.rightAnchor.constraint(equalTo: verticalStackView.leftAnchor, constant: -5).isActive = true
        clockImageView.centerYAnchor.constraint(equalTo: verticalStackView.centerYAnchor).isActive = true



        mainStackView.addArrangedSubview(dateTimeViewContainer)
        self.setNeedsLayout()
        self.layoutIfNeeded()

    }

    private func setupConstraints() {

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }

}
