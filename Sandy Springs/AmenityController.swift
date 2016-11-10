//
//  AmenityController.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 6/17/16.
//  Copyright © 2016 aidancbrady. All rights reserved.
//

import Foundation

import UIKit

class AmenityController: UIViewController
{
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var amenityList: [String] = [String]()
    var selectedAmenities: [String] = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if amenityList.count == 0
        {
            for data in ParkController.Parks.parkData
            {
                for amenity in data.1.amenities
                {
                    if(!amenityList.contains(amenity))
                    {
                        amenityList.append(amenity)
                    }
                }
            }
        }
        
        let scroll = UIScrollView(frame: CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.height))
        let titleLabel = UILabel(frame: CGRect(x: scroll.frame.minX, y: scroll.frame.minY + 16, width: scroll.frame.width, height: 20))
        titleLabel.text = "Tap desired amenities:"
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = UIColor.darkGray
        scroll.addSubview(titleLabel)
        
        //Amenity layout
        let margins = 20
        let amenityWidth = view.frame.width-CGFloat(margins*2)
        let perRow = Int(amenityWidth/110)
        let rows = Int(ceil(Float(amenityList.count)/Float(perRow)))
        
        let amenityView = UIView(frame: CGRect(x: view.frame.minX, y: titleLabel.frame.maxY + 8, width: view.frame.width, height: CGFloat(rows*110) - 10))
        
        for i in 0..<rows
        {
            for j in 0..<perRow
            {
                let index = i*perRow + j
                
                if index > amenityList.count-1
                {
                    break
                }
                
                let startX = (Int(amenityWidth)/perRow)/2 - 110/2
                let amenity = AmenityView(amenityName: amenityList[index], xPos: margins + (Int(amenityWidth)/perRow)*j + startX, yPos: 110*i)
                amenity.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onAmenityTapped)))
                amenityView.addSubview(amenity)
            }
        }
        
        scroll.addSubview(amenityView)
        scroll.contentSize = CGSize(width: view.frame.width, height: amenityView.frame.maxY)
        view.addSubview(scroll)
        
        searchButton.isEnabled = false
    }
    
    func onAmenityTapped(_ sender: UITapGestureRecognizer?)
    {
        let amenityView = sender!.view as! AmenityView
        
        if selectedAmenities.contains(amenityView.amenityName)
        {
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                amenityView.backgroundColor = nil
            })
            
            selectedAmenities.removeObject(amenityView.amenityName)
            
            if selectedAmenities.count == 0
            {
                searchButton.isEnabled = false
            }
        }
        else {
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                amenityView.backgroundColor = UIColor.groupTableViewBackground
            })
            
            selectedAmenities.append(amenityView.amenityName)
            searchButton.isEnabled = true
        }
    }
    
    @IBAction func menuPressed(_ sender: AnyObject)
    {
        toggleSideMenuView()
    }
    
    @IBAction func searchPressed(_ sender: AnyObject)
    {
        if selectedAmenities.count > 0
        {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let destController = (mainStoryboard.instantiateViewController(withIdentifier: "AmenitySearchNavigation") as! UINavigationController).viewControllers[0] as! AmenitySearchController
            destController.setAmenities(selectedAmenities)
            self.present(destController.navigationController!, animated: true, completion: nil)
        }
    }
}
