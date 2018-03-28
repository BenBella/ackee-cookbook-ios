//
//  Int.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 13/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation

extension Int {
    func createDurationString() -> String {
        return self < 60 ? String(self) + " min." :  String(self/60) + " hr."
    }
}
