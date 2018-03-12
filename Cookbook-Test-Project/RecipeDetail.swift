//
//  RecipeDetail.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import Unbox

class RecipeDetail: Recipe {

    var info: String = ""
    var description: String = ""
    var ingredients: [String] = []
    
    // MARK: Init with Unboxer
    convenience required init(unboxer: Unboxer) throws {
        self.init()
        id = try unboxer.unbox(key: "id")
        name = try unboxer.unbox(key: "name")
        duration = try unboxer.unbox(keyPath: "duration")
        score = try unboxer.unbox(keyPath: "score")
        info = try unboxer.unbox(key: "info")
        description = try unboxer.unbox(key: "description")
        ingredients = try unboxer.unbox(keyPath: "ingredients")
    }
    
    static func unboxMany(recipes: [JSONObject]) -> [RecipeDetail] {
        return (try? unbox(dictionaries: recipes, allowInvalidElements: true) as [RecipeDetail]) ?? []
    }
}
