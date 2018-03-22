//
//  MasterViewControllerSpec.swift
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

class MasterViewControllerSpec: QuickSpec {
    
    override func spec() {
        var container: Container!
        beforeEach {
            container = Container()
            
            // Registration for the stub network.
            container.register(Networking.self) { _ in StubNetwork() }.inObjectScope(.container)
            container.register(CookbookAPIServicing.self) { r in StubAPIService(network: r.resolve(Networking.self)!, authHandler: nil) }
            
            // View model
            container.register(MasterViewModeling.self) { r in MasterViewModel(api: r.resolve(CookbookAPIServicing.self)!) }
            
            // View
            container.register(MasterViewController.self) { r in
                let controller = MasterViewController()
                controller.viewModel = r.resolve(MasterViewModeling.self)!
                return controller
            }.inObjectScope(.container)
        }
        
        it("starts fetching recipes information when the view is about appearing.") {
            let controller = container.resolve(MasterViewController.self)!
            controller.viewModel?.contentChangesSignal.observeValues({ changeset in
                expect(changeset.insertions.count).toEventually(equal(6))
            })
            controller.viewWillAppear(true)
        }
    }

}
