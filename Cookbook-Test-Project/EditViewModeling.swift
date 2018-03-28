//
//  EditViewModeling.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 28/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

protocol EditViewModeling {
    
    var alertMessageSignal: Signal<RequestError, NoError> { get }
    
    var title: String { get }
    var inputIsValid: MutableProperty<Bool> { get }
    var name: MutableProperty<String> { get }
    var duration: MutableProperty<Int> { get }
    var score: MutableProperty<Double> { get }
    var info: MutableProperty<String> { get }
    var description: MutableProperty<String> { get }
    var ingredients: MutableProperty<[String]> { get }
    var recipeNameLabelTitle: String { get }
    var recipeInfoTextLabelTitle: String { get }
    var recipeIngredientsLabelTitle: String { get }
    var recipeIngredientAddButtonTitle: String { get }
    var recipeDescriptionLabelTitle: String { get }
    var recipeDurationLabelTitle: String { get }
    
    var saveAction: Action<Void, Any?, RequestError> { get set }
}
