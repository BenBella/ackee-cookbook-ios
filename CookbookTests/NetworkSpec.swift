//
//  CookbookTests.swift
//  CookbookTests
//
//  Created by Lukáš Andrlik on 16/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import XCTest
import Quick
import Nimble
import ReactiveCocoa
import ReactiveSwift
import Swinject
import enum Result.NoError
@testable import Cookbook 

class NetworkSpec: QuickSpec {
    
    override func spec() {
        var container: Container!
        beforeEach {
            container = Container()

            // Registration for the stub network.
            container.register(Networking.self, name: "stub") { _ in StubNetwork() }
            container.register(CookbookAPIServicing.self, name: "stub") { r in CookbookAPIService(network: r.resolve(Networking.self, name: "stub")!, authHandler: nil) }
        }
        
        it("returns recipes.") {
            var recipes: [Recipe]?
            let api = container.resolve(CookbookAPIServicing.self, name: "stub")!
            _ = api.getRecipes().start( { signal in
                switch signal {
                case .failed(_):
                    break
                case let .value(value): do {
                    recipes = value as? [Recipe]
                    expect(recipes).toEventuallyNot(beNil())
                    expect(recipes?.count).toEventually(beGreaterThan(0))
                }
                case .completed, .interrupted:
                    break
                }
            })
        }
        
        it("fills recipes data.") {
            var recipes: [Recipe]?
            let api = container.resolve(CookbookAPIServicing.self, name: "stub")!
            _ = api.getRecipes().start( { signal in
                switch signal {
                case .failed(_):
                    break
                case let .value(value): do {
                    recipes = value as? [Recipe]
                    expect(recipes?[0].id).toEventually(equal("5a9ef37f76925d1000638085"))
                    expect(recipes?[0].name).toEventually(equal("Ackee with butter"))
                    expect(recipes?[0].duration).toEventually(equal(15))
                    expect(recipes?[0].score).toEventually(equal(3.0))
                    expect(recipes?[1].id).toEventually(equal("5aa813f376925d100063809a"))
                    expect(recipes?[1].name).toEventually(equal("Ackee mexican tortilla bake"))
                    expect(recipes?[1].duration).toEventually(equal(180))
                    expect(recipes?[1].score).toEventually(equal(4.333333333333333))
                    }
                case .completed, .interrupted:
                    break
                }
            })
        }
    }
    
}
