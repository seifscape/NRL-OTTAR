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

        // Apply rounded corners
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true

        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = 5.0
        layer.masksToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .light, scale: .medium)
        titleLabel.text = "First Capture"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.clipsToBounds = true
        mainStackView.distribution = .fill
        self.contentView.addSubview(mainStackView)


        let topHorziontalStackView = UIStackView()
        topHorziontalStackView.translatesAutoresizingMaskIntoConstraints = false
        topHorziontalStackView.axis = .horizontal
        topHorziontalStackView.clipsToBounds = true
        topHorziontalStackView.distribution = .equalSpacing

        let timeStackView = UIStackView()
        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        timeStackView.axis = .horizontal
        timeStackView.clipsToBounds = true
        timeStackView.distribution = .fill

        let clockSymbol = UIImage(systemName: "clock.fill", withConfiguration: configuration)
        let clockImageView = UIImageView(image: clockSymbol)
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
        clockImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        clockImageView.contentMode = .scaleAspectFit
        clockImageView.tintColor = .black

        timeStackView.addArrangedSubview(clockImageView)
        timeStackView.addArrangedSubview(timeLabel)
        timeStackView.setCustomSpacing(7, after: clockImageView)


        topHorziontalStackView.addArrangedSubview(titleLabel)
        topHorziontalStackView.addArrangedSubview(timeStackView)

        let bottomHorziontalStackView = UIStackView()
        bottomHorziontalStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomHorziontalStackView.axis = .horizontal
        bottomHorziontalStackView.clipsToBounds = true
        bottomHorziontalStackView.distribution = .equalSpacing

        let locationStackView = UIStackView()
        locationStackView.translatesAutoresizingMaskIntoConstraints = false
        locationStackView.axis = .horizontal
        locationStackView.clipsToBounds = true
        locationStackView.distribution = .fill


        let locationSymbol = UIImage(systemName: "location.fill", withConfiguration: configuration)
        let pinImageView = UIImageView(image: locationSymbol)
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        pinImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        pinImageView.contentMode = .scaleAspectFit
        pinImageView.tintColor = .black


        locationStackView.addArrangedSubview(pinImageView)
        locationStackView.addArrangedSubview(locationLabel)
        locationStackView.setCustomSpacing(2, after: pinImageView)


        let dateStackView = UIStackView()
        dateStackView.translatesAutoresizingMaskIntoConstraints = false
        dateStackView.axis = .horizontal
        dateStackView.clipsToBounds = true
        dateStackView.distribution = .fill


        let calendarSymbol = UIImage(systemName: "calendar", withConfiguration: configuration)
        let calenderImageView = UIImageView(image: calendarSymbol)
        calenderImageView.translatesAutoresizingMaskIntoConstraints = false
        calenderImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        calenderImageView.contentMode = .scaleAspectFit
        calenderImageView.tintColor = .black

        dateStackView.addArrangedSubview(calenderImageView)
        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.setCustomSpacing(12, after: calenderImageView)

        bottomHorziontalStackView.addArrangedSubview(locationStackView)
        bottomHorziontalStackView.addArrangedSubview(dateStackView)


        mainStackView.addArrangedSubview(topHorziontalStackView)
        mainStackView.addArrangedSubview(bottomHorziontalStackView)
        mainStackView.setCustomSpacing(5, after: topHorziontalStackView)
        mainStackView.distribution = .equalSpacing

        mainStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        mainStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true

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
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }

}

//private func setupUI() {
//    titleLabel.text = "First Capture"
//    titleLabel.font = .boldSystemFont(ofSize: 16)
//    titleLabel.textColor = .black
//
//    self.contentView.backgroundColor = .blue
//
//
//    mainStackView.translatesAutoresizingMaskIntoConstraints = false
//    mainStackView.axis = .vertical
//    mainStackView.clipsToBounds = true
//    mainStackView.distribution = .fill
//
//    mainStackView.backgroundColor = .systemBackground
//    self.contentView.addSubview(mainStackView)
//
//    let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .light, scale: .medium)
//    let pinSymbol = UIImage(systemName: "mappin", withConfiguration: configuration)
//    let clockSymbol = UIImage(systemName: "calendar.circle", withConfiguration: configuration)
//    let captureSymbol = UIImage(systemName: "camera.metering.matrix", withConfiguration: configuration)
//
//
//    let captureStackView = UIStackView()
////        captureStackView.translatesAutoresizingMaskIntoConstraints = false
//    captureStackView.axis = .horizontal
//    captureStackView.clipsToBounds = true
//    captureStackView.distribution = .fill
//
//    let captureImageView = UIImageView(image: captureSymbol)
//    captureImageView.contentMode = .scaleAspectFit
//    captureImageView.translatesAutoresizingMaskIntoConstraints = false
//    captureImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
//
//    captureStackView.addArrangedSubview(captureImageView)
//    captureStackView.addArrangedSubview(titleLabel)
////        captureStackView.setCustomSpacing(2, after: captureImageView)
//
//
//    let locationStackView = UIStackView()
////        locationStackView.translatesAutoresizingMaskIntoConstraints = false
//    locationStackView.axis = .horizontal
//    locationStackView.clipsToBounds = true
//    locationStackView.distribution = .fill
//
//    let pinImageView = UIImageView(image: pinSymbol)
//    pinImageView.contentMode = .scaleAspectFit
//    pinImageView.translatesAutoresizingMaskIntoConstraints = false
//    pinImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
//
//
//    locationStackView.addArrangedSubview(pinImageView)
//    locationStackView.addArrangedSubview(locationLabel)
////        locationStackView.setCustomSpacing(2, after: pinImageView)
//
//    let dateStackView = UIStackView()
////        dateStackView.translatesAutoresizingMaskIntoConstraints = false
//    dateStackView.axis = .horizontal
//    dateStackView.clipsToBounds = true
//
//    let clockImageView = UIImageView(image: clockSymbol)
//    clockImageView.contentMode = .scaleAspectFit
//    clockImageView.translatesAutoresizingMaskIntoConstraints = false
//    clockImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
//
//
//    dateStackView.addArrangedSubview(clockImageView)
//    dateStackView.addArrangedSubview(dateLabel)
//    dateStackView.setCustomSpacing(5, after: clockImageView)
//
//
//    mainStackView.addArrangedSubview(captureStackView)
//    mainStackView.addArrangedSubview(locationStackView)
//    mainStackView.addArrangedSubview(dateStackView)
//    mainStackView.distribution = .equalSpacing
//
//    mainStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//    mainStackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//    mainStackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//    mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//
//}
