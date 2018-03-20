//
//  Changeset.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation

struct Changeset<T: Equatable> {
    
    var deletions: [IndexPath]
    var modifications: [IndexPath]
    var insertions: [IndexPath]
    
    typealias ContentMatches = (T, T) -> Bool
    
    init(oldItems: [T], newItems: [T], contentMatches: ContentMatches) {
        
        deletions = oldItems.difference(otherArray: newItems).map { item in
            return Changeset.indexPathForIndex(index: oldItems.index(of: item)!)
        }
        
        modifications = oldItems.intersection(otherArray: newItems)
            .filter({ item in
                let newItem = newItems[newItems.index(of: item)!]
                return !contentMatches(item, newItem)
            })
            .map({ item in
                return Changeset.indexPathForIndex(index: oldItems.index(of: item)!)
            })
        
        insertions = newItems.difference(otherArray: oldItems).map { item in
            return IndexPath.init(row: newItems.index(of: item)!, section: 0)
        }
    }
    
    private static func indexPathForIndex(index: Int) -> IndexPath {
        return IndexPath.init(row: index, section: 0)
    }
}
