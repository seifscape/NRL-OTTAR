//
//  RegistrationViewController.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 6/30/21.
//  Copyright © 2021 Apptitude Labs LLC. All rights reserved.
//

import UIKit


class RegistrationViewController: ViewController, CaptureController {
    
    let loginButton = UIButton()
    let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.setupViews()
        self.setupConstraints()
    }
    
    func checkPermissions() {
        
    }
    
    func setupConstraints() {
        loginButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    
    func setupViews() {
        
        self.view.addSubview(loginButton)
        loginButton.setTitle("Login", for: .normal)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.backgroundColor = .gray
        
        self.view.addSubview(titleLabel)
        titleLabel.text = "InspectoreMine"
        titleLabel.sizeToFit()
        titleLabel.font = UIFont.systemFont(ofSize: 32)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

func didLogin() {
    
}


protocol CaptureController {
    func setupConstraints()
    func setupViews()
}
