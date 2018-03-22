//
//  String.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    /**
     Translate string to locale
     */
    var localized: String {
        #if DEBUG
            let debugValue = "XXX _ String not localized _ XXX"
            let str = NSLocalizedString(self, tableName: "Localizable", bundle: Bundle.main, value: debugValue, comment: "")
            if str == debugValue {
                print("Error: There is no localization for '\(self)'")
            }
        #endif
        return NSLocalizedString(self, tableName: "Localizable", bundle: Bundle.main, value: self, comment: "")
    }
    
    func localized(_ count: Int) -> String {
        return NSString.localizedStringWithFormat(self.localized as NSString, count) as String
    }
    
    /**
     Uppercase only the first letter in string
     */
    var uppercaseFirst: String {
        return String(prefix(1)).uppercased() + String(dropFirst())
    }
    
    private func matches(pattern: String) -> Bool {
        if let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive]) {
            return regex.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: utf16.count)) != nil
        } else {
            return false
        }
    }
    
    func isValidAbsoluteURL() -> Bool {
        let urlPattern = "((https|http)://)((\\w|-|_)+)(([.]|[/])((\\w|-|_)+))+"
        let test = self.matches(pattern: urlPattern)
        return test
    }
    
    func isValidRelativeURL() -> Bool {
        let urlPattern = "((\\w|-|_)+)(([.]|[/])((\\w|-|_)+))+"
        return self.matches(pattern: urlPattern)
    }
    
    func isValidEntityName() -> Bool {
        let urlPattern = "\\w{3,10}"
        return self.matches(pattern: urlPattern)
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPhoneNumber() -> Bool {
        let phoneRegEx = "^\\+[0-9]{3} [0-9]{3} [0-9]{3} [0-9]{3}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: self)
    }
    
    func createDurationString(duration: Int) -> String {
        return duration < 60 ? String(duration) + " min." :  String(duration/60) + " hr."
    }
}
