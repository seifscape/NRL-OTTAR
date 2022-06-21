//
//  Ext+UIWindow.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 6/16/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            let alertController = UIAlertController(title: "Network Manager", message:"Server Endpoint", preferredStyle: UIAlertController.Style.alert)

            alertController.addTextField { (textField) in
                textField.placeholder = APIPreferencesLoader.load().baseURL
            }
            // add an action (button)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] _ in
                guard let textFields = alertController?.textFields else { return }

                if let serverText = textFields[0].text {
                    print("Base URL: \(serverText)")
                }
            }))

            // show the alert
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}
