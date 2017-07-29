//
//  Theme.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.
//

import UIKit

enum Theme: Int {

    case dark, graphical

  var mainColor: UIColor {
    switch self {
    case .dark:
      return UIColor(red: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    case .graphical:
      return UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 1.0)
    }
  }

    //Customizing the Navigation Bar
  var barStyle: UIBarStyle {
    switch self {
    case .graphical:
      return .default
    case .dark:
      return .black
    }
  }

  var navigationBackgroundImage: UIImage? {
    return self == .graphical ? UIImage(named: "navBackground") : nil
  }

  var tabBarBackgroundImage: UIImage? {
    return self == .graphical ? UIImage(named: "tabBarBackground") : nil
  }

  var backgroundColor: UIColor {
    switch self {
    case .graphical:
      return UIColor(white: 0.9, alpha: 1.0)
    case .dark:
      return UIColor(white: 0.8, alpha: 1.0)
    }
  }

  var secondaryColor: UIColor {
    switch self {
    case .dark:
      return UIColor(red: 34.0/255.0, green: 128.0/255.0, blue: 66.0/255.0, alpha: 1.0)
    case .graphical:
      return UIColor(red: 140.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 1.0)
    }
  }
}

// Enum declaration
let SelectedThemeKey = "SelectedTheme"

// This will let you use a theme in the app.
struct ThemeManager {

    // ThemeManager
  static func currentTheme() -> Theme {
    if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).int8Value {
      return Theme(rawValue: Int(storedTheme))!
    } else {
      return .graphical
    }
  }

  static func applyTheme(_ theme: Theme) {
    // First persist the selected theme using NSUserDefaults.
    UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
    UserDefaults.standard.synchronize()

    // You get your current (selected) theme and apply the main color to the tintColor property of your application’s window.
    let sharedApplication = UIApplication.shared
    sharedApplication.delegate?.window??.tintColor = theme.mainColor

    UINavigationBar.appearance().barStyle = theme.barStyle
    UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)
    UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backArrow")
    UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backArrowMaskFixed")

  }
}
