//
//  DetailViewModeling.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 28/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

protocol DetailViewModeling {
    
    var recipeId: String? { get set }
    var active: MutableProperty<Bool> { get }
    var refreshSignal: Signal<Void, NoError> { get }
    var refreshObserver: Signal<Void, NoError>.Observer { get }
    
    var title: String { get }
    var item: MutableProperty<RecipeDetail> { get }
    var contentChangesSignal: Signal<Bool, NoError> { get }
    var isLoading: MutableProperty<Bool> { get }
    var alertMessageSignal: Signal<RequestError, NoError> { get }
    var recipeIngredientsLabelTitle: String { get }
    var recipeDescriptionLabelTitle: String { get }
    var recipeScoreEvaluateLabelTitle: String { get }
    var recipeName: String { get }
    var recipeDuration: Int { get }
    var recipeScore: Double { get }
    var recipeInfo: String { get }
    var recipeDescription: String { get }
    var recipeIngredients: [String] { get }
    
    var evaluateAction: Action<Int, Any?, RequestError> { get set }
}
