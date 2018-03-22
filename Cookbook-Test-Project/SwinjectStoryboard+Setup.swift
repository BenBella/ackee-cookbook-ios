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
        defaultContainer.register(CookbookAPIServicing.self) { res in CookbookAPIService(network: res.resolve(Networking.self)!, authHandler: nil) }
        
        // View models
        defaultContainer.register(MasterViewModeling.self) { res in MasterViewModel(api: res.resolve(CookbookAPIServicing.self)!) }
        defaultContainer.register(DetailViewModeling.self) { res in DetailViewModel(api: res.resolve(CookbookAPIServicing.self)!) }
        defaultContainer.register(EditViewModeling.self) { res in EditViewModel(api: res.resolve(CookbookAPIServicing.self)!) }
        
        // Views
        defaultContainer.storyboardInitCompleted(MasterViewController.self) { res, con in
            con.viewModel = res.resolve(MasterViewModeling.self)!
        }
        defaultContainer.storyboardInitCompleted(EditViewController.self) { res, con in
            con.viewModel = res.resolve(EditViewModeling.self)!
        }
    }
}
