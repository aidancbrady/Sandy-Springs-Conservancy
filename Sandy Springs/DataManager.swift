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
    
    private var totalDownloadCount = 0
    private var downloaded = 0
    
    init(delegate: DataManagerDelegate) {
        self.delegate = delegate
        connected = Utilities.isConnected()
        cacheDir = DataManager.getCachePath()
        cacheFile = cacheDir + Constants.DATA_FILE
    }
    
    func loadData() -> Bool {
        // reset park cache
        Constants.parkData.removeAll()
        if let storedVersion = getStoredVersion() {
            print("Cache has data version \(storedVersion)")
            if connected {
                if let url = URL(string: Constants.DATA_URL + Constants.DATA_FILE), let data = try? Data(contentsOf: url) {
                    if let remoteJSON = data.parseJSON(), let remoteVersion = getVersion(json: remoteJSON) {
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
        do {
            return try loadData(url: URL(fileURLWithPath: cacheFile))
        } catch {
            print("Failed to load local data cache")
            try? resetCache()
            return false
        }
    }
    
    private func remoteLoadData(fileData: Data) -> Bool {
        let cacheURL = URL(fileURLWithPath: cacheFile)
        do {
            try resetCache()
            try fileData.write(to: cacheURL)
            print("Downloaded file data")
            return try loadData(url: cacheURL)
        } catch {
            print("Failed to download file data")
            try? resetCache()
            return false
        }
    }
    
    private func loadData(url: URL) throws -> Bool {
        if let data = url.parseJSON() {
            // set the total items to download for accurate progress indication
            totalDownloadCount += (data["backgrounds"] as! NSArray).count
            totalDownloadCount += (data["parks"] as! NSArray).count
            
            loadProperties(data: data)
            try loadBackgrounds(data: data)
            try loadParks(data: data)
            asyncLoadExtraImages()
            return true
        }
        return false
    }
    
    private func loadParks(data: NSDictionary) throws {
        if let parks = data["parks"] as? NSArray {
            for obj in parks {
                if let park = obj as? NSDictionary {
                    let parkObj = ParkData.initPark(park)
                    try loadImages(park: parkObj, cacheDir: cacheDir, primary: true)
                    updateProgress()
                }
            }
        }
    }
    
    private func loadBackgrounds(data: NSDictionary) throws {
        if let backgrounds = data["backgrounds"] as? NSArray {
            for obj in backgrounds {
                if let image = obj as? String {
                    let url = URL(fileURLWithPath: cacheDir + image)
                    downloadIfNeeded(image: image)
                    updateProgress()
                    if let data = try? Data(contentsOf: url), let loadedImage = UIImage(data: data) {
                        MenuController.backgrounds.append(loadedImage)
                    } else {
                        throw DataError.primaryPhoto(image)
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
            } catch {
                print("Failed to load image '" + image + "'")
            }
             
            Operations.setNetworkActivity(false)
        }
    }
    
    private func asyncLoadExtraImages() {
        DispatchQueue.global(qos: .background).async {
            for park in Constants.parkData {
                try? self.loadImages(park: park.value, cacheDir: self.cacheDir, primary: false)
            }
            print("Completed asynchronous image load")
        }
    }
    
    private func loadImages(park: ParkData, cacheDir: String, primary: Bool) throws {
        var didInitial = false
        
        for image in park.imageUrls {
            let url = URL(fileURLWithPath: cacheDir + image)
            
            if primary || didInitial {
                downloadIfNeeded(image: image)
                if let data = try? Data(contentsOf: url), let loadedImage = UIImage(data: data) {
                    park.images.append(loadedImage)
                } else if primary {
                    // fail if we can't load a primary image
                    throw DataError.primaryPhoto(image)
                }
            }
            if primary {
                return
            }
            didInitial = true
        }
    }
    
    private func getStoredVersion() -> Double? {
        if let json = URL(fileURLWithPath: cacheFile).parseJSON() {
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
    
    private class func getCachePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cacheDir = paths.first!
        return cacheDir + DataManager.cacheDataDir
    }
    
    private func resetCache() throws {
        var isDir = ObjCBool(true)
        
        if FileManager.default.fileExists(atPath: cacheDir, isDirectory: &isDir) {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: cacheDir))
            print("Cleared old files")
        }
        try FileManager.default.createDirectory(at: URL(fileURLWithPath: cacheDir), withIntermediateDirectories: true, attributes: nil)
    }
    
    private func updateProgress() {
        downloaded = downloaded + 1
        delegate.progressCallback(progress: Double(downloaded) / Double(totalDownloadCount))
    }
}

public protocol DataManagerDelegate {
    func progressCallback(progress: Double)
}

enum DataError: Error {
    case primaryPhoto(String)
}
