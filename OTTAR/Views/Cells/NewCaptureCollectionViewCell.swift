//
//  NewCaptureCollectionViewCell.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 4/10/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class NewCaptureCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.setupConstrainsts()

        let configuration = UIImage.SymbolConfiguration(pointSize: 8, weight: .light, scale: .small)
        let cameraSymbol = UIImage(systemName: "camera.fill", withConfiguration: configuration)
        imageView.tintColor = .white
        imageView.backgroundColor = .clear
        imageView.image = cameraSymbol
        self.addLineDashedStroke(pattern: [4, 4], radius: 15, color: UIColor.white.cgColor, thickness: 2.0)

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
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstrainsts() {
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive  = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

}


extension UIView {
    @discardableResult
    func addLineDashedStroke(pattern: [NSNumber]?, radius: CGFloat, color: CGColor, thickness:CGFloat) -> CALayer {
        let borderLayer = CAShapeLayer()

        borderLayer.lineWidth = thickness
        borderLayer.strokeColor = color
        borderLayer.lineDashPattern = pattern
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath

        layer.addSublayer(borderLayer)
        return borderLayer
    }
}
