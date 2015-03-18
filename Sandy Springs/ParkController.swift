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
    
    var parkName: String!
    var park: Park!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        setParkData()
    }
    
    func setParkData()
    {
        park = Park.parkData[parkName]
        self.navigationItem.title = parkName
        imageView.image = UIImage(named: park.imageUrl)
    }
    
    @IBAction func menuPressed(sender: AnyObject)
    {
        toggleSideMenuView()
    }
    
    struct Park
    {
        static var parkData = [String: Park]()
        
        var imageUrl: String!
        var desc: String!
        
        init(imageUrl: String)
        {
            self.imageUrl = imageUrl
        }
        
        init(imageUrl: String, desc: String)
        {
            self.imageUrl = imageUrl
            self.desc = desc
        }
        
        static func checkParkData()
        {
            if Park.parkData.count == 0
            {
                Park.parkData["Abernathy Greenway"] = Park(imageUrl: "greenway.jpeg")
                Park.parkData["Abernathy Park"] = Park(imageUrl: "abernathy.jpeg")
                Park.parkData["Allen Road"] = Park(imageUrl: "allen.jpeg")
                Park.parkData["Big Trees Preserve"] = Park(imageUrl: "trees.jpeg")
                Park.parkData["Chattahoochee River: Island Ford"] = Park(imageUrl: "river_ford.jpeg")
                Park.parkData["Chattahoochee River: Powers Island"] = Park(imageUrl: "river_powers.jpeg")
                Park.parkData["Chattahoochee River: East Palisades"] = Park(imageUrl: "river_palisades.jpeg")
                Park.parkData["Hammond Park"] = Park(imageUrl: "hammond.jpeg")
                Park.parkData["Morgan Falls Overlook Park"] = Park(imageUrl: "morgan_overlook.jpeg")
                Park.parkData["Morgan Falls Ball Fields"] = Park(imageUrl: "morgan_fields.jpeg")
                Park.parkData["Morgan Falls River Park"] = Park(imageUrl: "morgan_river.jpeg")
                Park.parkData["Ridgeview Park"] = Park(imageUrl: "ridgeview.jpeg")
                Park.parkData["Sandy Springs Tennis Center"] = Park(imageUrl: "tennis_center.jpeg")
                Park.parkData["Sandy Springs Historical Site"] = Park(imageUrl: "historical_site.jpeg")
            }
        }
    }
}