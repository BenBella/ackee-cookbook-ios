//
//  Ingredient.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 04/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import Unbox

class Ingredient: Unboxable {
    
    var id: String = ""
    var name: String = ""
    var duration: Int = 0
    var score: Int = 0
    
    // MARK: Init with Unboxer
    convenience required init(unboxer: Unboxer) throws {
        self.init()
        id = try unboxer.unbox(key: "id")
        name = try unboxer.unbox(key: "name")
        duration = try unboxer.unbox(keyPath: "duration")
        score = try unboxer.unbox(keyPath: "score")
    }
    
    static func unboxMany(recipes: [JSONObject]) -> [Ingredient] {
        return (try? unbox(dictionaries: recipes, allowInvalidElements: true) as [Ingredient]) ?? []
    }
    
}
