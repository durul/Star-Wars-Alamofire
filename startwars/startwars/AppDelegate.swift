//
//  AppDelegate.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.

//  xcodebuild -workspace startwars.xcworkspace -scheme startwars clean build | grep [1-9].[0-9]ms | sort -nr > culprits.txt

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let theme = ThemeManager.currentTheme()
        ThemeManager.applyTheme(theme)
        
        return true
    }
}

