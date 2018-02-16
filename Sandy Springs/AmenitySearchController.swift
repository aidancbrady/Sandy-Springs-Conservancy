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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //show nav bar
        navigationController!.navigationBar.isHidden = false
    }
    
    func setAmenities(_ selectedAmenities: [String])
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 52
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchResults.count == 0
        {
            return 1
        }
        
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if searchResults.count > 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell") as! FavoriteCell

            cell.parkTitle.text = searchResults[(indexPath as NSIndexPath).row].parkName
            
            return cell
        }
        else {
            return tableView.dequeueReusableCell(withIdentifier: "NoParksCell")! as UITableViewCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if searchResults.count == 0
        {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "ParkController") as! ParkController
        let menuNavigation = self.presentingViewController! as! MenuNavigation
        
        destController.parkName = searchResults[(indexPath as NSIndexPath).row].parkName
        
        hideSideMenuView()
        
        menuNavigation.setViewControllers([destController], animated: true)
        self.dismiss(animated: true, completion: nil)
        
        Utilities.loadPark(menuNavigation)
    }
    
    @IBAction func backPressed(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
