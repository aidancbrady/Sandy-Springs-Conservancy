//
//  Utilities.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 6/15/16.
//  Copyright © 2016 aidancbrady. All rights reserved.
//

import Foundation
import UIKit

class Utilities
{
    static var favorites: [String] = [String]()
    
    static func isFavorite(_ name: String) -> Bool
    {
        return favorites.contains(name)
    }
    
    static func formatAmenity(_ name: String) -> String
    {
        var str = name.replacingOccurrences(of: " ", with: "_")
        str = str.replacingOccurrences(of: "/", with: "_")
        return str.lowercased() + ".png"
    }
    
    @discardableResult
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
    
    static func split(_ s:String, separator:String) -> [String]
    {
        if s.range(of: separator) == nil
        {
            return [s.trim()]
        }
        
        var split = s.trim().components(separatedBy: separator)
        
        for i in 0 ..< split.count
        {
            if split[i] == ""
            {
                split.remove(at: i)
            }
        }
        
        return split
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

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

extension Data
{
    func hexString() -> String
    {
        return self.reduce("") { string, byte in
            string + String(format: "%02X", byte)
        }
    }
}

extension UIColor
{
    func lighten(_ amount: CGFloat) -> UIColor
    {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(displayP3Red: r + amount, green: g + amount, blue: b + amount, alpha: a)
    }
}
