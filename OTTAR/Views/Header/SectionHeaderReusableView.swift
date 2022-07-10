//
//  SupplementaryHeaderView.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 7/8/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class SectionHeaderReusableView: UICollectionReusableView {
  static var reuseIdentifier: String {
    return String(describing: SectionHeaderReusableView.self)
  }

  // 2
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(
      ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize,
      weight: .bold)
    label.adjustsFontForContentSizeCategory = true
    label.textColor = .label
    label.textAlignment = .center
    label.numberOfLines = 1
      label.textColor = .white
    label.setContentCompressionResistancePriority(
      .defaultHigh,
      for: .horizontal)
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    // 3
      backgroundColor =  OTTARColors.nrlBlue
    addSubview(titleLabel)

    if UIDevice.current.userInterfaceIdiom == .pad {
      NSLayoutConstraint.activate([
        titleLabel.leadingAnchor.constraint(
          equalTo: leadingAnchor,
          constant: 5),
        titleLabel.trailingAnchor.constraint(
          lessThanOrEqualTo: trailingAnchor,
          constant: -5)])
    } else {
      NSLayoutConstraint.activate([
        titleLabel.leadingAnchor.constraint(
          equalTo: readableContentGuide.leadingAnchor),
        titleLabel.trailingAnchor.constraint(
          lessThanOrEqualTo: readableContentGuide.trailingAnchor)
      ])
    }
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(
        equalTo: topAnchor,
        constant: 10),
      titleLabel.bottomAnchor.constraint(
        equalTo: bottomAnchor,
        constant: -10)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
