//
//  DataManager.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 1/19/18.
//  Copyright © 2018 aidancbrady. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class DataManager
{
    static let cacheDataDir = "/CacheDownloads/"
    
    class func loadData() -> Bool
    {
        let reachability = SCNetworkReachabilityCreateWithName(nil, "server.aidancbrady.com")!
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        SCNetworkReachabilityGetFlags(reachability, &flags)
        let connected = flags.contains(.reachable)
        
        if let storedVersion = getStoredVersion()
        {
            do {
                if !connected
                {
                    print("Offline, using existing data")
                    try localLoadData()
                    return true
                }
                
                if let url = URL(string: Constants.DATA_URL + Constants.DATA_FILE)
                {
                    if let data = try? Data(contentsOf: url)
                    {
                        let raw: Any? = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        
                        if let top = raw as? NSDictionary
                        {
                            if let version = top["version"] as? Double
                            {
                                if version != storedVersion
                                {
                                    print("Downloading new data from server")
                                    try remoteLoadData(fileData: data)
                                    return true
                                }
                                else {
                                    print("Loading existing data from file storage")
                                    try localLoadData()
                                    return true
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Data management process failed")
                return false
            }
        }
        else {
            if !connected
            {
                return false
            }
            
            do {
                if let url = URL(string: Constants.DATA_URL + Constants.DATA_FILE)
                {
                    if let data = try? Data(contentsOf: url)
                    {
                        try remoteLoadData(fileData: data)
                    }
                }
            } catch {
                print("Failed to download fresh data")
                return false
            }
        }
        
        return true
    }
    
    private class func localLoadData() throws
    {
        let cacheDir = getCachePath()
        let dataFile = cacheDir + Constants.DATA_FILE
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: dataFile))
        {
            let raw: Any? = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            if let top = raw as? NSDictionary
            {
                if let parks = top["parks"] as? NSArray
                {
                    for obj in parks
                    {
                        if let park = obj as? NSDictionary
                        {
                            let parkObj = ParkData.initPark(park)
                            try loadImages(park: parkObj, cacheDir: cacheDir, remote: false)
                        }
                    }
                }
            }
        }
    }
    
    private class func remoteLoadData(fileData: Data) throws
    {
        let cacheDir = getCachePath()
        let manager = FileManager.default
        var isDir = ObjCBool(true)
        
        if manager.fileExists(atPath: cacheDir, isDirectory: &isDir)
        {
            let enumerator = manager.enumerator(atPath: cacheDir)!
            
            // clear stored files
            for case let fileURL as URL in enumerator
            {
                try manager.removeItem(at: fileURL)
            }
            
            print("Cleared old files")
        }
        else {
            try manager.createDirectory(at: URL(fileURLWithPath: cacheDir), withIntermediateDirectories: true, attributes: nil)
            print("Created data directory")
        }
        
        let dataFile = cacheDir + Constants.DATA_FILE
        
        try fileData.write(to: URL(fileURLWithPath: dataFile))
        print("Downloaded file data")
        
        let raw: Any? = try JSONSerialization.jsonObject(with: fileData, options: .mutableContainers)
        
        if let top = raw as? NSDictionary
        {
            if let parks = top["parks"] as? NSArray
            {
                for obj in parks
                {
                    if let park = obj as? NSDictionary
                    {
                        let parkObj = ParkData.initPark(park)
                        try loadImages(park: parkObj, cacheDir: cacheDir, remote: true)
                    }
                }
            }
        }
    }
    
    private class func loadImages(park: ParkData, cacheDir: String, remote: Bool) throws
    {
        do {
            for image in park.imageUrls
            {
                let dir = remote ? Constants.DATA_URL : cacheDir
                let testURL = remote ? URL(string: dir + image) : URL(fileURLWithPath: dir + image)
                
                if let url = testURL
                {
                    if let data = try? Data(contentsOf: url)
                    {
                        if remote
                        {
                            let localFile = cacheDir + image
                            try data.write(to: URL(fileURLWithPath: localFile))
                        }
                        
                        if let loadedImage = UIImage(data: data)
                        {
                            park.images.append(loadedImage)
                        }
                    }
                }
            }
        } catch {
            print("Failed to load images")
        }
    }
    
    private class func getStoredVersion() -> Double?
    {
        let dataFile = getCachePath() + Constants.DATA_FILE
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: dataFile))
        {
            let raw: Any? = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            if let top = raw as? NSDictionary
            {
                if let version = top["version"] as? Double
                {
                    return version
                }
            }
        }
        
        return nil
    }
    
    private class func getCachePath() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cacheDir = paths.first!
        return cacheDir + cacheDataDir
    }
}
