//
//  DetailViewControllerSpec.swift
//  CookbookTests
//
//  Created by Lukáš Andrlik on 21/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import ReactiveSwift
import Swinject
import enum Result.NoError
@testable import Cookbook

class DetailViewControllerSpec: QuickSpec {
    
    override func spec() {
        var container: Container!
        
        // SUT
        
        // 1. given
        beforeEach {
            container = Container()
            
            // Registration for the stub network.
            container.register(Networking.self) { _ in StubNetwork() }.inObjectScope(.container)
            container.register(CookbookAPIServicing.self) { res in StubAPIService(network: res.resolve(Networking.self)!, authHandler: nil) }
            
            // View model
            container.register(DetailViewModeling.self) { res in DetailViewModel(api: res.resolve(CookbookAPIServicing.self)!) }
            
            // View
            container.register(DetailViewController.self) { res in
                let controller = DetailViewController()
                controller.viewModel = res.resolve(DetailViewModeling.self)!
                return controller
                }.inObjectScope(.container)
        }
        
        it("starts fetching recipe information when the view is about appearing.") {
            let controller = container.resolve(DetailViewController.self)!
            controller.viewModel?.contentChangesSignal.observeValues({ flag in
                // 2. then
                expect(flag).to(equal(true))
            })
            // 2. when
            controller.viewWillAppear(true)
        }
    }
    
}
