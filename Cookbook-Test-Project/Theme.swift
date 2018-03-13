//
//  Theme.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import UIKit

open class Theme {
    
    open static var current = Theme()
    var color: Color = Color()
    var font: Font = Font()
    
    init() {}
    
    // MARK: - Theme definitions
    
    open class Color {
        init() {}
        open let clear = UIColor.clear
        open let white = UIColor(hex:"FFFFFF")
        open let black = UIColor(hex:"000000")
        open let transparentBlack = UIColor(rgba:"#0000006D")
        open let blue = UIColor(hex:"0000FF")
        open let pink = UIColor(hex:"FF00FF")
        open let lightGray = UIColor(hex:"D3D3D7")
        open let dimGray = UIColor(hex:"A1A1A1")
        open let darkGray = UIColor(hex:"030303")
        open let transparentGreen = UIColor(rgba:"#0000FFC8")
    }
    
    open class Font {
        init() {}
        open let bigTitle: UIFont = .systemFont(ofSize: 34)
        open let bigTitleBold: UIFont = .boldSystemFont(ofSize: 34)
        open let title: UIFont = .systemFont(ofSize: 17)
        open let titleBold: UIFont = .boldSystemFont(ofSize: 17)
        open let text: UIFont = .systemFont(ofSize: 15)
        open let textBold: UIFont = .boldSystemFont(ofSize: 15)
        open let subText: UIFont = .systemFont(ofSize: 12)
        open let subTextBold: UIFont = .boldSystemFont(ofSize: 12)
        open let smallText: UIFont = .systemFont(ofSize: 10)
        open let smallTextBold: UIFont = .boldSystemFont(ofSize: 10)
    }
    
    // MARK: - Appearance
    
    open func setupAppearance() {
        UIApplication.shared.statusBarStyle = .lightContent
        //UIView.appearance().backgroundColor = color.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = color.white
        UINavigationBar.appearance().tintColor = color.blue
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: color.darkGray]
    }
    
}

public extension UIFont {
    public static var theme: Theme.Font {
        return Theme.current.font
    }
}

public extension UIColor {
    
    public static var theme: Theme.Color {
        return Theme.current.color
    }
}

