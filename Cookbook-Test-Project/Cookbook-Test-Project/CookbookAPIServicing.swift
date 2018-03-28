//
//  CookbookAPIServicing.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 21/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol CookbookAPIServicing {
    func getRecipes() -> SignalProducer<Any?, RequestError>
    func getRecipeDetail(id: String) -> SignalProducer<Any?, RequestError>
    func createRecipe(_ parameters: RecipeParameters) -> SignalProducer<Any?, RequestError>
    func deleteRecipe(id: String) -> SignalProducer<Any?, RequestError>
    func evaluateRecipe(id: String, parameters: EvaluateParameters) -> SignalProducer<Any?, RequestError>
}
