//
//  StubAPIService.swift
//  CookbookTests
//
//  Created by Lukáš Andrlik on 21/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import ReactiveSwift
import Unbox
import Alamofire

/**
 Stub class for creating api calls to our server
 */

class StubAPIService : APIService, CookbookAPIServicing {
 
    override func resourceURL(_ path: String) -> URL {
        return Foundation.URL(string: path)!
    }
    
    internal func getRecipes() -> SignalProducer<Any?, RequestError> {
        return self.request("recipes")
            .mapError { .network($0) }
            .map { Recipe.unboxMany(recipes: $0 as! [JSONObject]) }
    }
    
    internal func getRecipeDetail(id: String) -> SignalProducer<Any?, RequestError> {
        return self.request("recipe")
            .mapError { .network($0) }
            .map { (try? unbox(dictionary: $0 as! JSONObject) as RecipeDetail) ?? RecipeDetail() }
    }
    
    internal func createRecipe(_ parameters: RecipeParameters) -> SignalProducer<Any?, RequestError> {
        return self.request("recipe", method: .post, parameters: parameters.jsonObject(), encoding: JSONEncoding.default)
            .mapError { .network($0) }
    }
    
    internal func deleteRecipe(id: String) -> SignalProducer<Any?, RequestError> {
        return self.request("recipe" + id, method: .delete)
            .mapError { .network($0) }
    }
    
    internal func evaluateRecipe(id: String, parameters: EvaluateParameters) -> SignalProducer<Any?, RequestError> {
        return self.request("recipe/ratings", method: .post, parameters: parameters.jsonObject(), encoding: JSONEncoding.default)
            .mapError { .network($0) }
    }
}

