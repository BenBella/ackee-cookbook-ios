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
        beforeEach {
            container = Container()
            
            // Registration for the stub network.
            container.register(Networking.self) { _ in StubNetwork() }.inObjectScope(.container)
            container.register(CookbookAPIServicing.self) { r in StubAPIService(network: r.resolve(Networking.self)!, authHandler: nil) }
            
            // View model
            container.register(DetailViewModeling.self) { r in DetailViewModel(api: r.resolve(CookbookAPIServicing.self)!) }
            
            // View
            container.register(DetailViewController.self) { r in
                let controller = DetailViewController()
                controller.viewModel = r.resolve(DetailViewModeling.self)!
                return controller
                }.inObjectScope(.container)
        }
        
        it("starts fetching recipe information when the view is about appearing.") {
            let controller = container.resolve(DetailViewController.self)!
            controller.viewModel?.contentChangesSignal.observeValues({ flag in
                expect(flag).to(equal(true))
            })
            controller.viewWillAppear(true)
        }
    }
    
}
