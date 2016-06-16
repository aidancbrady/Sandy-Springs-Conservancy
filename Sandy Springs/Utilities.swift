//
//  Utilities.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 6/15/16.
//  Copyright © 2016 aidancbrady. All rights reserved.
//

import Foundation

class Utilities
{
    static var favorites: [String] = [String]()
    
    static func isFavorite(name: String) -> Bool
    {
        return favorites.contains(name)
    }
    
    static func toggleFavorite(name: String) -> Bool
    {
        var ret = false
        
        if isFavorite(name)
        {
            favorites.removeObject(name)
        }
        else {
            favorites.append(name)
            ret = true
        }
        
        saveFavorites()
        
        return ret
    }
    
    static func saveFavorites()
    {
        NSUserDefaults.standardUserDefaults().setObject(favorites, forKey: "favorites")
    }
    
    static func loadFavorites()
    {
        if let obj = NSUserDefaults.standardUserDefaults().objectForKey("favorites") as? [String]
        {
            favorites = obj
        }
    }
}

extension Array where Element: Equatable
{
    mutating func removeObject(object : Generator.Element)
    {
        if let index = self.indexOf(object)
        {
            self.removeAtIndex(index)
        }
    }
}