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

class DataManager {
    
    static let cacheDataDir = "/CacheDownloads/"
    
    class func loadData() -> Bool {
        let reachability = SCNetworkReachabilityCreateWithName(nil, "server.aidancbrady.com")!
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        SCNetworkReachabilityGetFlags(reachability, &flags)
        let connected = flags.contains(.reachable)
        
        if let storedVersion = getStoredVersion() {
            do {
                if !connected {
                    print("Offline, using existing data")
                    try localLoadData()
                    asyncLoadExtraImages(remote: false)
                    return true
                }
                
                if let url = URL(string: Constants.DATA_URL + Constants.DATA_FILE) {
                    if let data = try? Data(contentsOf: url) {
                        let raw: Any? = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        
                        if let top = raw as? NSDictionary {
                            if let version = top["version"] as? Double {
                                if version != storedVersion {
                                    print("Downloading new data from server")
                                    Operations.setNetworkActivity(true)
                                    try remoteLoadData(fileData: data)
                                    asyncLoadExtraImages(remote: true)
                                    Operations.setNetworkActivity(false)
                                } else {
                                    print("Loading existing data from file storage")
                                    try localLoadData()
                                    asyncLoadExtraImages(remote: false)
                                }
                                return true
                            }
                        }
                    }
                }
            } catch {
                print("Data management process failed")
                resetCache()
                return false
            }
        }
        else {
            if !connected {
                return false
            }
            
            do {
                if let url = URL(string: Constants.DATA_URL + Constants.DATA_FILE) {
                    if let data = try? Data(contentsOf: url) {
                        print("Downloading initial copy of data from server")
                        Operations.setNetworkActivity(true)
                        try remoteLoadData(fileData: data)
                        asyncLoadExtraImages(remote: true)
                        Operations.setNetworkActivity(false)
                    }
                }
            } catch {
                print("Failed to download fresh data")
                resetCache()
                return false
            }
        }
        
        return true
    }
    
    private class func localLoadData() throws {
        let cacheDir = getCachePath()
        let dataFile = cacheDir + Constants.DATA_FILE
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: dataFile)) {
            let raw: Any? = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            if let top = raw as? NSDictionary {
                try loadBackgrounds(data: top, remote: false)
                
                if let parks = top["parks"] as? NSArray {
                    for obj in parks {
                        if let park = obj as? NSDictionary {
                            let parkObj = ParkData.initPark(park)
                            try loadImages(park: parkObj, cacheDir: cacheDir, primary: true, remote: false)
                        }
                    }
                }
            }
        }
    }
    
    private class func loadBackgrounds(data: NSDictionary, remote: Bool) throws {
        if let backgrounds = data["backgrounds"] as? NSArray {
            for obj in backgrounds {
                if let image = obj as? String {
                    let cacheDir = getCachePath()
                    let dir = remote ? Constants.DATA_URL : cacheDir
                    let testURL = remote ? URL(string: dir + image) : URL(fileURLWithPath: dir + image)
                    
                    if !remote {
                        // if we're loading a secondary image locally, make sure it exists
                        checkMissingImage(cacheDir: cacheDir, image: image)
                    }
                    
                    if let url = testURL {
                        if let data = try? Data(contentsOf: url) {
                            if remote {
                                let localFile = cacheDir + image
                                try data.write(to: URL(fileURLWithPath: localFile))
                            }
                            
                            if let loadedImage = UIImage(data: data) {
                                MenuController.backgrounds.append(loadedImage)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private class func remoteLoadData(fileData: Data) throws {
        let cacheDir = getCachePath()
        let manager = FileManager.default
        var isDir = ObjCBool(true)
        
        if manager.fileExists(atPath: cacheDir, isDirectory: &isDir) {
            let enumerator = manager.enumerator(atPath: cacheDir)!
            
            // clear stored files
            for case let fileURL as URL in enumerator {
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
        
        if let top = raw as? NSDictionary {
            try loadBackgrounds(data: top, remote: true)
            
            if let parks = top["parks"] as? NSArray {
                for obj in parks {
                    if let park = obj as? NSDictionary {
                        let parkObj = ParkData.initPark(park)
                        try loadImages(park: parkObj, cacheDir: cacheDir, primary: true, remote: true)
                    }
                }
            }
        }
    }
    
    private class func checkMissingImage(cacheDir: String, image: String) {
        let manager = FileManager.default
        if !manager.fileExists(atPath: cacheDir + image) {
            let localURL = URL(fileURLWithPath: cacheDir + image)
            let remoteURL = URL(string: Constants.DATA_URL + image)
            Operations.setNetworkActivity(true)
            
            do {
                if let downloadURL = remoteURL {
                    if let data = try? Data(contentsOf: downloadURL) {
                        try data.write(to: localURL)
                    }
                }
                
                print("Loaded missing secondary image '" + image + "'")
            } catch {
                print("Failed to reload missing secondary image")
            }
            
            Operations.setNetworkActivity(false)
        }
    }
    
    private class func asyncLoadExtraImages(remote: Bool) {
        let cacheDir = getCachePath()
        DispatchQueue.global(qos: .background).async {
            do {
                for park in ParkController.Parks.parkData {
                    try loadImages(park: park.value, cacheDir: cacheDir, primary: false, remote: remote)
                }
                
                print("Completed asynchronous image load")
            } catch {
                print("Failed to load extra images")
            }
        }
    }
    
    private class func loadImages(park: ParkData, cacheDir: String, primary: Bool, remote: Bool) throws {
        do {
            var didInitial = false
            
            for image in park.imageUrls {
                let dir = remote ? Constants.DATA_URL : cacheDir
                let testURL = remote ? URL(string: dir + image) : URL(fileURLWithPath: dir + image)
                
                if primary || didInitial {
                    if !remote && !primary {
                        // if we're loading a secondary image locally, make sure it exists
                        checkMissingImage(cacheDir: cacheDir, image: image)
                    }
                    
                    if let url = testURL {
                        if let data = try? Data(contentsOf: url) {
                            if remote {
                                let localFile = cacheDir + image
                                try data.write(to: URL(fileURLWithPath: localFile))
                            }
                            
                            if let loadedImage = UIImage(data: data) {
                                park.images.append(loadedImage)
                            }
                        }
                    }
                }
                
                if primary {
                    return
                }
                
                didInitial = true
            }
        } catch {
            print("Failed to load images")
        }
    }
    
    private class func getStoredVersion() -> Double? {
        let dataFile = getCachePath() + Constants.DATA_FILE
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: dataFile)) {
            let raw: Any? = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            if let top = raw as? NSDictionary {
                if let version = top["version"] as? Double {
                    return version
                }
            }
        }
        
        return nil
    }
    
    private class func getCachePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cacheDir = paths.first!
        return cacheDir + cacheDataDir
    }
    
    private class func resetCache() {
        let cacheDir = getCachePath()
        var isDir = ObjCBool(true)
        let manager = FileManager.default
        
        do {
            if manager.fileExists(atPath: cacheDir, isDirectory: &isDir) {
                let enumerator = manager.enumerator(atPath: cacheDir)!
                
                // clear stored files
                for case let fileURL as URL in enumerator {
                    try manager.removeItem(at: fileURL)
                }
                
                print("Cleared old files")
            }
        } catch {
            print("Error resetting data cache")
        }
    }
}
