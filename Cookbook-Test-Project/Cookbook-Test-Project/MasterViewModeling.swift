//
//  MasterViewModeling.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 28/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

protocol MasterViewModeling {
    
    typealias RecipeChangeset = Changeset<Recipe>
    
    var active: MutableProperty<Bool> { get }
    var refreshSignal: Signal<Void, NoError> { get }
    var refreshObserver: Signal<Void, NoError>.Observer { get }
    
    var list: MutableProperty<[Recipe]> { get }
    var title: String { get }
    var contentChangesSignal: Signal<RecipeChangeset, NoError> { get }
    var isLoading: MutableProperty<Bool> { get }
    var alertMessageSignal: Signal<RequestError, NoError> { get }
    
    var deleteAction: Action<IndexPath, Any?, RequestError> { get }
    
    func numberOfSections() -> Int
    func numberOfMatchesInSection(section: Int) -> Int
    func recipeIdAt(_ indexPath: IndexPath) -> String
    func recipeNameAt(_ indexPath: IndexPath) -> String
    func recipeDurationAt(_ indexPath: IndexPath) -> Int
    func recipeScoreAt(_ indexPath: IndexPath) -> Double
    func editViewModel() -> EditViewModel
}
