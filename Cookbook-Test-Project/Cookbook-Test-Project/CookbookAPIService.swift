//
//  CookbookAPIService.swift
//  Cookbook-Test-Project
//
//  Created by Dominik Vesely on 12/01/2017.
//  Copyright © 2017 Dominik Vesely. All rights reserved.
//

import Foundation
import ReactiveSwift
import Unbox
import Alamofire

/**
 Concrete class for creating api calls to our server
 */
class CookbookAPIService: APIService, CookbookAPIServicing {
    
    override func resourceURL(_ path: String) -> URL {
        let URL = Foundation.URL(string: "https://cookbook.ack.ee/api/v1/")!
        let relativeURL = Foundation.URL(string: path, relativeTo: URL)!
        return relativeURL
    }
    
    internal func getRecipes() -> SignalProducer<Any?, RequestError> {
        return self.request("recipes")
            .mapError { .network($0) }
            // swiftlint:disable:next force_cast
            .map { Recipe.unboxMany(recipes: $0 as! [JSONObject]) }
    }

    internal func getRecipeDetail(id: String) -> SignalProducer<Any?, RequestError> {
        return self.request("recipes/" + id)
            .mapError { .network($0) }
            // swiftlint:disable:next force_cast
            .map { (try? unbox(dictionary: $0 as! JSONObject) as RecipeDetail) ?? RecipeDetail() }
    }
    
    internal func createRecipe(_ parameters: RecipeParameters) -> SignalProducer<Any?, RequestError> {
        return self.request("recipes/", method: .post, parameters: parameters.jsonObject(), encoding: JSONEncoding.default)
            .mapError { .network($0) }
    }
    
    internal func deleteRecipe(id: String) -> SignalProducer<Any?, RequestError> {
        return self.request("recipes/" + id, method: .delete)
            .mapError { .network($0) }
    }
    
    internal func evaluateRecipe(id: String, parameters: EvaluateParameters) -> SignalProducer<Any?, RequestError> {
        return self.request("recipes/" + id + "/ratings", method: .post, parameters: parameters.jsonObject(), encoding: JSONEncoding.default)
            .mapError { .network($0) }
    }
}
