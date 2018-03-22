//
//  SwinjectStoryboard.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 15/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import SwinjectStoryboard

extension SwinjectStoryboard {
    
    @objc class func setup() {
        
        // Networking
        defaultContainer.register(Networking.self) { _ in Network() }.inObjectScope(.container)
        defaultContainer.register(CookbookAPIServicing.self) { r in CookbookAPIService(network: r.resolve(Networking.self)!, authHandler: nil) }
        
        // View models
        defaultContainer.register(MasterViewModeling.self) { r in MasterViewModel(api: r.resolve(CookbookAPIServicing.self)!) }
        defaultContainer.register(DetailViewModeling.self) { r in DetailViewModel(api: r.resolve(CookbookAPIServicing.self)!) }
        defaultContainer.register(EditViewModeling.self) { r in EditViewModel(api: r.resolve(CookbookAPIServicing.self)!) }
        
        // Views
        defaultContainer.storyboardInitCompleted(MasterViewController.self) { r, c in
            c.viewModel = r.resolve(MasterViewModeling.self)!
        }
        defaultContainer.storyboardInitCompleted(EditViewController.self) { r, c in
            c.viewModel = r.resolve(EditViewModeling.self)!
        }
    }
}

