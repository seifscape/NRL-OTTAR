//
//  TabViewController.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 2/28/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
        // https://nemecek.be/blog/127/how-to-disable-automatic-transparent-tabbar-in-ios-15
        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = .white
            UITabBar.appearance().standardAppearance = tabBarAppearance

            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }

        //https://nemecek.be/blog/126/how-to-disable-automatic-transparent-navbar-in-ios-15
        //Fix Nav Bar tint issue in iOS 15.0 or later - is transparent w/o code below
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.backgroundColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }

        if #available(iOS 15, *) {
           let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = .white
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.black]
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
           tabBar.standardAppearance = tabBarAppearance
           tabBar.scrollEdgeAppearance = tabBarAppearance
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.blue], for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            tabBar.barTintColor = .black
         }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium, scale: .medium)
        let docSymbol         = UIImage(systemName: "doc.richtext", withConfiguration: configuration)?.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
        // Create Tab one
        let tabOne = UINavigationController.init(rootViewController: CapturePreviewViewController()) 
        let tabOneBarItem = UITabBarItem(title: "", image: docSymbol, selectedImage: nil)
        tabOne.tabBarItem = tabOneBarItem
        self.viewControllers = [tabOne]
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
