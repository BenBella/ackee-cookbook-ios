//
//  MasterViewModel.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Unbox
import Result

class MasterViewModel: MasterViewModeling {
    
    // MARK: - Dependencies
    var api: CookbookAPIServicing
    
    // MARK: - Input
    let active = MutableProperty(false)
    let refreshSignal: Signal<Void, NoError>
    let refreshObserver: Signal<Void, NoError>.Observer
    
    // MARK: - Output
    var list: MutableProperty<[Recipe]> = MutableProperty([])
    let title = "master.title".localized
    let contentChangesSignal: Signal<RecipeChangeset, NoError>
    let isLoading: MutableProperty<Bool>
    let alertMessageSignal: Signal<RequestError, NoError>
    
    private let contentChangesObserver: Signal<RecipeChangeset, NoError>.Observer
    private let alertMessageObserver: Signal<RequestError, NoError>.Observer
    private var recipes = [Recipe]()
    
    // Actions
    lazy var deleteAction: Action<IndexPath, Any?, RequestError> = { [unowned self] in
        return Action(execute: { [unowned self] indexPath in
            let recipe = self.recipeAt(indexPath)
            return self.api.deleteRecipe(id: recipe.id)
        })
    }()
    
    // MARK: - Lifecycle
    
    init(api: CookbookAPIServicing) {
        self.api = api
        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        self.refreshSignal = refreshSignal
        
        let (contentChangesSignal, contentChangesObserver) = Signal<RecipeChangeset, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading
        
        let (alertMessageSignal, alertMessageObserver) = Signal<RequestError, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        // Trigger refresh when view becomes active
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        
        // Trigger refresh after deleting a recipe
        deleteAction.values
            .filter { $0 != nil }
            .map { _ in () }
            .observe(refreshObserver)
 
        SignalProducer<Void, NoError>(refreshSignal)
            .on(value: { [unowned self] _ in self.isLoading.swap(true) })
            .flatMap(FlattenStrategy.latest) { [unowned self] _ in
                return self.api.getRecipes().flatMapError { error in
                    alertMessageObserver.send(value: error)
                    return SignalProducer(value: [])
                }
            }
            .on(value: {[unowned self]  _ in self.isLoading.swap(false) })
            .combinePrevious([Recipe]())
            .start({ [unowned self] signal in
                // swiftlint:disable force_cast
                let oldRecipes = signal.value!.0 as! [Recipe]
                let newRecipes = signal.value!.1 as! [Recipe]
                // swiftlint:enable force_cast
                self.recipes = newRecipes
                let changeset = Changeset(
                    oldItems: oldRecipes,
                    newItems: newRecipes,
                    contentMatches: Recipe.contentMatches
                )
                self.contentChangesObserver.send(value: changeset)
            })
        
        // Feed deletion errors into alert message signal
                
        deleteAction.errors.observe(alertMessageObserver)
    }
    
    // MARK: - Data Source
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfMatchesInSection(section: Int) -> Int {
        return recipes.count
    }

    func recipeIdAt(_ indexPath: IndexPath) -> String {
        let recipe = recipeAt(indexPath)
        return recipe.id
    }
    
    func recipeNameAt(_ indexPath: IndexPath) -> String {
        let recipe = recipeAt(indexPath)
        return recipe.name
    }
    
    func recipeDurationAt(_ indexPath: IndexPath) -> Int {
        let recipe = recipeAt(indexPath)
        return recipe.duration
    }
    
    func recipeScoreAt(_ indexPath: IndexPath) -> Double {
        let recipe = recipeAt(indexPath)
        return recipe.score
    }
    
    func editViewModel() -> EditViewModel {
        return EditViewModel(api: self.api)
    }
    
    // MARK: Internal Helpers
    
    private func recipeAt(_ indexPath: IndexPath) -> Recipe {
        return recipes[indexPath.row]
    }
}
