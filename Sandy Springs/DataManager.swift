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
    
    private static let cacheDataDir = "/CacheDownloads/"
    
    private let delegate: DataManagerDelegate
    
    private let connected: Bool
    private let cacheDir: String
    private let cacheFile: String
    
    init(delegate: DataManagerDelegate) {
        self.delegate = delegate
        connected = Utilities.isConnected()
        cacheDir = DataManager.getCachePath()
        cacheFile = cacheDir + Constants.DATA_FILE
    }
    
    func loadData() -> Bool {
        // reset park cache
        Constants.parkData.removeAll()
        let connected = Utilities.isConnected()
        
        if let storedVersion = getStoredVersion() {
            if connected {
                if let url = URL(string: Constants.DATA_URL + Constants.DATA_FILE), let data = try? Data(contentsOf: url) {
                    if let remoteJSON = parseJSON(data: data), let remoteVersion = getVersion(json: remoteJSON) {
                        if storedVersion != remoteVersion {
                            print("Fetching updated data copy...")
                            return remoteLoadData(fileData: data)
                        }
                    }
                }
            }
            print("Loading local data cache...")
            return localLoadData()
        }
        
        if connected, let url = URL(string: Constants.DATA_URL + Constants.DATA_FILE), let data = try? Data(contentsOf: url) {
            print("Downloading initial data copy...")
            return remoteLoadData(fileData: data)
        }
        print("Failed to load park data")
        return false
    }
    
    private func localLoadData() -> Bool {
        if let data = parseJSON(url: URL(fileURLWithPath: cacheFile)) {
            loadProperties(data: data)
            loadBackgrounds(data: data)
            loadParks(data: data)
            asyncLoadExtraImages()
            return true
        }
        return false
    }
    
    private func remoteLoadData(fileData: Data) -> Bool {
        let cacheURL = URL(fileURLWithPath: cacheFile)
        do {
            try resetCache()
            try fileData.write(to: cacheURL)
            print("Downloaded file data")
        } catch {
            print("Failed to download file data")
            return false
        }
        
        if let data = parseJSON(url: cacheURL) {
            loadProperties(data: data)
            loadBackgrounds(data: data)
            loadParks(data: data)
            asyncLoadExtraImages()
            return true
        }
        return false
    }
    
    private func loadParks(data: NSDictionary) {
        if let parks = data["parks"] as? NSArray {
            var count = 0
            for obj in parks {
                delegate.progressCallback(progress: Double(count) / Double(parks.count))
                if let park = obj as? NSDictionary {
                    let parkObj = ParkData.initPark(park)
                    loadImages(park: parkObj, cacheDir: cacheDir, primary: true)
                }
                count = count + 1
            }
        }
    }
    
    private func loadBackgrounds(data: NSDictionary) {
        if let backgrounds = data["backgrounds"] as? NSArray {
            for obj in backgrounds {
                if let image = obj as? String {
                    let url = URL(fileURLWithPath: cacheDir + image)
                    downloadIfNeeded(image: image)
                    
                    if let data = try? Data(contentsOf: url), let loadedImage = UIImage(data: data) {
                        MenuController.backgrounds.append(loadedImage)
                    }
                }
            }
        }
    }
    
    private func loadProperties(data: NSDictionary) {
        if let website_url = data["website_url"] as? String {
            Constants.WEBSITE = website_url
        }
        if let donate_url = data["donate_url"] as? String {
            Constants.DONATE_SITE = donate_url
        }
    }
    
    private func downloadIfNeeded(image: String) {
        let manager = FileManager.default
        if connected && !manager.fileExists(atPath: cacheDir + image) {
            let localURL = URL(fileURLWithPath: cacheDir + image)
            let remoteURL = URL(string: Constants.DATA_URL + image)
            Operations.setNetworkActivity(true)
             
            do {
                if let downloadURL = remoteURL {
                    if let data = try? Data(contentsOf: downloadURL) {
                        try data.write(to: localURL)
                    }
                }
                 
                print("Loaded image '" + image + "'")
            } catch {
                print("Failed to load image '" + image + "'")
            }
             
            Operations.setNetworkActivity(false)
        }
    }
    
    private func asyncLoadExtraImages() {
        DispatchQueue.global(qos: .background).async {
            for park in Constants.parkData {
                self.loadImages(park: park.value, cacheDir: self.cacheDir, primary: false)
            }
            print("Completed asynchronous image load")
        }
    }
    
    private func loadImages(park: ParkData, cacheDir: String, primary: Bool) {
        var didInitial = false
        
        for image in park.imageUrls {
            let url = URL(fileURLWithPath: cacheDir + image)
            
            if primary || didInitial {
                downloadIfNeeded(image: image)
                
                if let data = try? Data(contentsOf: url), let loadedImage = UIImage(data: data) {
                    park.images.append(loadedImage)
                }
            }
            
            if primary {
                return
            }
            didInitial = true
        }
    }
    
    private func getStoredVersion() -> Double? {
        if let json = parseJSON(url: URL(fileURLWithPath: cacheFile)) {
            return getVersion(json: json)
        }
        return nil
    }
    
    private func getVersion(json: NSDictionary) -> Double? {
        if let version = json["version"] as? Double {
            return version
        }
        return nil
    }
    
    private func parseJSON(url: URL) -> NSDictionary? {
        if let data = try? Data(contentsOf: url) {
            return parseJSON(data: data)
        }
        return nil
    }
    
    private func parseJSON(data: Data) -> NSDictionary? {
        if let top = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
            return top
        }
        return nil
    }
    
    private class func getCachePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cacheDir = paths.first!
        return cacheDir + DataManager.cacheDataDir
    }
    
    private func resetCache() throws {
        var isDir = ObjCBool(true)
        let manager = FileManager.default
        
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
    }
}

public protocol DataManagerDelegate {
    func progressCallback(progress: Double)
}
