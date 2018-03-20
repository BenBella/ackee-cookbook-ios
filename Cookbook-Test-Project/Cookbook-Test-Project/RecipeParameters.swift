//
//  RecipeParameters.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation

struct RecipeParameters {
    let name: String
    let description: String
    let ingredients: [String]
    let duration: Int
    let info: String
    
    // MARK: - Helpers
    
   func jsonObject() -> JSONObject {
        let jsonObject = [
            "name": name,
            "description": description,
            "ingredients": ingredients,
            "duration": duration,
            "info": info
            ] as JSONObject
        return jsonObject
    }
}

