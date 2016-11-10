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
    
    static func isFavorite(_ name: String) -> Bool
    {
        return favorites.contains(name)
    }
    
    static func toggleFavorite(_ name: String) -> Bool
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
        UserDefaults.standard.set(favorites, forKey: "favorites")
    }
    
    static func loadFavorites()
    {
        if let obj = UserDefaults.standard.object(forKey: "favorites") as? [String]
        {
            favorites = obj
        }
    }
    
    static func loadPark(_ menuNavigation: MenuNavigation)
    {
        for i in 0..<menuNavigation.tableController.menuData.count
        {
            menuNavigation.tableController.tableView.deselectRow(at: IndexPath(row: i, section: 0), animated: false)
        }
        
        menuNavigation.tableController.selectedItem = -1
        
        DispatchQueue.global(qos: .background).async {
            usleep(1000*1000)
            DispatchQueue.main.async {
                if menuNavigation.topViewController is ParkController
                {
                    (menuNavigation.topViewController as! ParkController).loadMap()
                }
            }
        }
    }
}

extension Array where Element: Equatable
{
    mutating func removeObject(_ object : Iterator.Element)
    {
        if let index = self.index(of: object)
        {
            self.remove(at: index)
        }
    }
}
