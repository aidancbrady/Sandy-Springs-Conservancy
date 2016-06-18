//
//  AmenitySearchController.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 6/17/16.
//  Copyright © 2016 aidancbrady. All rights reserved.
//

import Foundation

import UIKit

class AmenitySearchController: UITableViewController
{
    var selectedAmenities: [String] = [String]()
    var searchResults: [ParkData] = [ParkData]()
    
    func setAmenities(selectedAmenities: [String])
    {
        self.selectedAmenities = selectedAmenities
        
        for park in ParkController.Parks.parkData
        {
            var valid = true
            
            for amenity in selectedAmenities
            {
                if !park.1.amenities.contains(amenity)
                {
                    valid = false
                    break
                }
            }
            
            if valid
            {
                searchResults.append(park.1)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 52
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchResults.count == 0
        {
            return 1
        }
        
        return searchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if searchResults.count > 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteCell") as! FavoriteCell

            cell.parkTitle.text = searchResults[indexPath.row].parkName
            
            return cell
        }
        else {
            return tableView.dequeueReusableCellWithIdentifier("NoParksCell")! as UITableViewCell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if searchResults.count == 0
        {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewControllerWithIdentifier("ParkController") as! ParkController
        let menuNavigation = self.presentingViewController! as! MenuNavigation
        
        destController.parkName = searchResults[indexPath.row].parkName
        
        hideSideMenuView()
        
        menuNavigation.setViewControllers([destController], animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
        
        Utilities.loadPark(menuNavigation)
    }
    
    @IBAction func backPressed(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}