//
//  ParkController.swift
//  Sandy Springs
//
//  Created by aidancbrady on 2/20/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit

class ParkController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var parkName: String!
    var park: ParkData!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        setParkData()
    }
    
    func setParkData()
    {
        park = Parks.parkData[parkName]
        self.navigationItem.title = parkName
        imageView.image = UIImage(named: park.imageUrl)
        phoneLabel.text = park.phone
    }
    
    @IBAction func menuPressed(sender: AnyObject)
    {
        toggleSideMenuView()
    }
    
    struct Parks
    {
        static var parkData = [String: ParkData]()
        
        static func checkParkData()
        {
            if Parks.parkData.count == 0
            {
                Parks.parkData["Abernathy Greenway"] = ParkData(imageUrl: "greenway.jpeg").setPhone("(770) 730-5600").setAmenities("Pavilion", "Picnic Tables", "Playground", "Restrooms")
                Parks.parkData["Abernathy Park"] = ParkData(imageUrl: "abernathy.jpeg").setPhone("(770) 730-5600").setAmenities("Playground", "Tennis Courts")
                Parks.parkData["Allen Road"] = ParkData(imageUrl: "allen.jpeg").setPhone("(770) 730-5600").setAmenities("Basketball", "Courts", "Picnic Tables", "Playground", "Sports Field", "Walking/Hiking", "Trails")
                Parks.parkData["Big Trees Forest Preserve"] = ParkData(imageUrl: "trees.jpeg").setPhone("(770) 730-5600").setAmenities("Restrooms", "Walking/Hiking", "Trails")
                Parks.parkData["Chattahoochee River: East Palisades"] = ParkData(imageUrl: "river_palisades.jpeg").setPhone("(770) 952-0370").setAmenities("Walking/Hiking", "Trails")
                Parks.parkData["Chattahoochee River: Island Ford"] = ParkData(imageUrl: "river_ford.jpeg").setPhone("(770) 730-5600").setAmenities("Fishing", "Walking/Hiking", "Trails")
                Parks.parkData["Chattahoochee River: Powers Island"] = ParkData(imageUrl: "river_powers.jpeg").setPhone("(770) 952-0370").setAmenities("Walking/Hiking", "Trails")
                Parks.parkData["Hammond Park"] = ParkData(imageUrl: "hammond.jpeg").setPhone("(770) 206-2035").setAmenities("Basketball", "Courts", "Gymnastics", "Center", "Pavilion", "Picnic Tables", "Playground", "Restrooms", "Sports Field", "Tennis Courts")
                Parks.parkData["Morgan Falls Ball Fields"] = ParkData(imageUrl: "morgan_fields.jpeg").setPhone("(770) 730-5600").setAmenities("Pavilion", "Picnic Tables", "Playground", "Restrooms", "Sports Field")
                Parks.parkData["Morgan Falls Overlook Park"] = ParkData(imageUrl: "morgan_overlook.jpeg").setPhone("(770) 730-5600").setAmenities("Fishing", "Picnic Tables", "Playground", "Restrooms", "Walking/Hiking", "Trails")
                Parks.parkData["Morgan Falls River Park"] = ParkData(imageUrl: "morgan_river.jpeg").setPhone("(770) 730-5600").setAmenities("Boat Ramp", "Dog Park", "Fishing")
                Parks.parkData["Ridgeview Park"] = ParkData(imageUrl: "ridgeview.jpeg").setPhone("(770) 730-5600").setAmenities("Pavilion", "Picnic Tables", "Playground", "Walking/Hiking", "Trails")
                Parks.parkData["Sandy Springs Tennis Center"] = ParkData(imageUrl: "tennis_center.jpeg").setPhone("(404) 851-1911").setAmenities("Walking/Hiking", "Trails")
                Parks.parkData["Sandy Springs Historical Site"] = ParkData(imageUrl: "historical_site.jpeg").setPhone("(404) 303-6182").setAmenities("Restrooms", "Tennis Courts", "Walking/Hiking", "Trails")
            }
        }
    }
    
    class ParkData
    {
        var imageUrl: String!
        var phone: String!
        var amenities: [String] = [String]()
        
        init(imageUrl: String)
        {
            self.imageUrl = imageUrl
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
    }
}