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
    
    func setName(name: String) -> ParkData
    {
        self.parkName = name
        
        return self
    }
    
    func setDescription(description: String) -> ParkData
    {
        self.description = description
        
        return self
    }
    
    func setPhone(phone: String) -> ParkData
    {
        self.phone = phone
        
        return self
    }
    
    func setAmenities(amenities: String...) -> ParkData
    {
        self.amenities = amenities
        
        return self
    }
    
    func setAddress(address: String) -> ParkData
    {
        self.address = address
        
        return self
    }
    
    func setCoords(x: Double, y: Double) -> ParkData
    {
        coords = CLLocationCoordinate2DMake(x, y)
        
        return self
    }
    
    func setImages(controller:ParkController)
    {
        for i in 0..<controller.imageViews.count
        {
            if images.count == controller.imageViews.count
            {
                controller.imageViews[i].image = images[i]
            }
        }
    }
    
    class func initPark(data:NSDictionary)
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            for image in park.imageUrls
            {
                if let url = NSURL(string: AppDelegate.DATA_URL + image)
                {
                    if let data = NSData(contentsOfURL: url)
                    {
                        if let loadedImage = UIImage(data: data)
                        {
                            park.images.append(loadedImage)
                        }
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                if let window:UIWindow = UIApplication.sharedApplication().keyWindow as UIWindow!
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
            })
        })
    }
}