//
//  EvaluateParameters.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 13/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation

struct EvaluateParameters {
    let score: Int
    
    // MARK: - Helpers
    
    func jsonObject() -> JSONObject {
        let jsonObject = [
            "score": score
            ] as JSONObject
        return jsonObject
    }
}
