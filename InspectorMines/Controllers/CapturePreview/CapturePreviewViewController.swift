//
//  CapturePreviewViewController.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 5/12/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit
import FINNBottomSheet

class CapturePreviewViewController: UIViewController {

    var previewContainer = UIView()
    let imagePreview     = UIImageView()
    var safeArea: UILayoutGuide!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presentModal()
    }

    func setupUI() {
        view.backgroundColor = .systemGray
        previewContainer = UIView(frame: .zero)
        previewContainer.backgroundColor = .gray
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        safeArea = self.view.layoutMarginsGuide
        self.view.addSubview(previewContainer)
    }

    func setupConstraints() {
        previewContainer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 50).isActive = true
        previewContainer.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -20).isActive = true
        previewContainer.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 20).isActive = true
        previewContainer.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -100).isActive = true
    }

    private func presentModal() {
        //let viewController = CaptureReviewOptionsViewController()
        let bottomSheetView = BottomSheetView(
            contentView: UIView.makeView(withTitle: "UIView"),
            contentHeights: [100, 100]
        )
        bottomSheetView.present(in: view)
    }
}


// https://gist.github.com/simme/a44cd16f89038cbee8537b89d237386b
extension UITabBarController {
    /// Extends the size of the `UITabBarController` view frame, pushing the tab bar controller off screen.
    /// - Parameters:
    ///   - hidden: Hide or Show the `UITabBar`
    ///   - animated: Animate the change
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        guard let vc = selectedViewController else { return }
        guard tabBarHidden != hidden else { return }

        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = hidden ? height : -height

        UIViewPropertyAnimator(duration: animated ? 0.3 : 0, curve: .easeOut) {
            self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
            self.selectedViewController?.view.frame = CGRect(
                x: 0,
                y: 0,
                width: vc.view.frame.width,
                height: vc.view.frame.height + offsetY
            )

            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }
        .startAnimation()
    }

    /// Is the tab bar currently off the screen.
    private var tabBarHidden: Bool {
        tabBar.frame.origin.y >= UIScreen.main.bounds.height
    }
}

// MARK: - Private extensions

private extension UIView {
    static func makeView(withTitle title: String? = nil) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = .center
        label.textColor = .black
        view.addSubview(label)

        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .white
        borderView.alpha = 0.4
        view.addSubview(borderView)

        let cameraButton = UIButton()
        cameraButton.translatesAutoresizingMaskIntoConstraints = false

        let checkmarkButton = UIButton()
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false

        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .medium)
        let addSymbol = UIImage(systemName: "camera.badge.ellipsis", withConfiguration: configuration)
        let checkmarkSymbol = UIImage(systemName: "checkmark.circle", withConfiguration: configuration)
        cameraButton.tintColor = .black
        checkmarkButton.tintColor = .black

        checkmarkButton.setImage(checkmarkSymbol, for: .normal)
        view.addSubview(checkmarkButton)

        cameraButton.setImage(addSymbol, for: .normal)
        view.addSubview(cameraButton)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),

            checkmarkButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            checkmarkButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),


            borderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 2),
            borderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }
}
