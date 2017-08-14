//
//  ParkData.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 6/18/16.
//  Copyright © 2016 aidancbrady. All rights reserved.
//

import Foundation

import UIKit
import MapKit

class ParkData
{
    var parkName: String!
    var imageUrls: [String] = [String]()
    var description: String!
    var phone: String!
    var amenities: [String] = [String]()
    var address: String!
    var images: [UIImage] = [UIImage]()
    
    var coords: CLLocationCoordinate2D!
    
    @discardableResult
    func setName(_ name: String) -> ParkData
    {
        self.parkName = name
        
        return self
    }
    
    @discardableResult
    func setDescription(_ description: String) -> ParkData
    {
        self.description = description
        
        return self
    }
    
    @discardableResult
    func setPhone(_ phone: String) -> ParkData
    {
        self.phone = phone
        
        return self
    }
    
    @discardableResult
    func setAmenities(_ amenities: String...) -> ParkData
    {
        self.amenities = amenities
        
        return self
    }
    
    @discardableResult
    func setAddress(_ address: String) -> ParkData
    {
        self.address = address
        
        return self
    }
    
    @discardableResult
    func setCoords(_ x: Double, y: Double) -> ParkData
    {
        coords = CLLocationCoordinate2DMake(x, y)
        
        return self
    }
    
    func setImages(_ controller:ParkController)
    {
        for i in 0..<controller.imageViews.count
        {
            if images.count == controller.imageViews.count
            {
                controller.imageViews[i].image = images[i]
            }
        }
    }
    
    class func initPark(_ data:NSDictionary)
    {
        let park = ParkData()
        
        if let images = data["images"] as? NSArray
        {
            for obj in images
            {
                if let image = obj as? String
                {
                    park.imageUrls.append(image)
                }
            }
        }
        
        park.setName(data["name"] as! String)
        park.setDescription(data["description"] as! String)
        park.setPhone(data["phone"] as! String)
        park.setCoords(data["coordX"] as! Double, y: data["coordY"] as! Double)
        park.setAddress(data["address"] as! String)
        
        if let amenities = data["amenities"] as? NSArray
        {
            for obj in amenities
            {
                if let amenity = obj as? String
                {
                    park.amenities.append(amenity)
                }
            }
        }
        
        ParkController.Parks.parkData[park.parkName] = park
        
        //preload images asynchronously
        
        DispatchQueue.global(qos: .background).async {
            for image in park.imageUrls
            {
                if let url = URL(string: AppDelegate.DATA_URL + image)
                {
                    if let data = try? Data(contentsOf: url)
                    {
                        if let loadedImage = UIImage(data: data)
                        {
                            park.images.append(loadedImage)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                if let window:UIWindow = UIApplication.shared.keyWindow as UIWindow!
                {
                    if var controller:UIViewController = window.rootViewController as UIViewController!
                    {
                        let navigation:MenuNavigation = controller.presentedViewController as! MenuNavigation
                        controller = navigation.viewControllers[0] as UIViewController
                        
                        if controller is ParkController
                        {
                            let parkController = controller as! ParkController
                            
                            if park === parkController.park
                            {
                                park.setImages(parkController)
                            }
                        }
                    }
                }
            }
        }
    }
}
