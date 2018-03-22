//
//  SplitViewController.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 14/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

//import Foundation
import UIKit

extension UISplitViewController {
    
    func toggleMasterView() {
        if self.isCollapsed, let nav = self.viewControllers[0] as? UINavigationController {
            nav.popToRootViewController(animated: false)
        } else {
            self.preferredDisplayMode = .allVisible
        }
    }
}
