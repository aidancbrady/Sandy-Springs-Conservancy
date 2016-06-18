//
//  MenuController.swift
//  Sandy Springs
//
//  Created by aidancbrady on 1/26/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit

class MenuController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var favoritesLabel:UILabel!
    @IBOutlet weak var favoritesTable: UITableView!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var amenitySearchButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        logoImage.frame = CGRectMake(view.frame.width/4, navigationController!.navigationBar.frame.maxY+48, view.frame.width/2, view.frame.width/2)
        favoritesLabel.frame = CGRect(x: view.frame.maxX/2 - favoritesLabel.frame.width/2, y: logoImage.frame.maxY + 32, width: favoritesLabel.frame.width, height: favoritesLabel.frame.height)
        
        let tableStartY = favoritesLabel.frame.maxY + 8
        let bottomHeight = CGFloat(16+42+8+42+16)
        favoritesTable.frame = CGRect(x: view.frame.minX, y: tableStartY, width: view.frame.width, height: (view.frame.height-bottomHeight)-tableStartY)
        
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        favoritesTable.scrollEnabled = true
        
        amenitySearchButton.frame = CGRect(x: view.frame.minX + 16, y: favoritesTable.frame.maxY + 16, width: view.frame.width - 32, height: 42)
        
        websiteButton.frame = CGRect(x: view.frame.minX + 16, y: amenitySearchButton.frame.maxY + 8, width: view.frame.width - 32, height: 42)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 52
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if Utilities.favorites.count == 0
        {
            return 1
        }
        
        return Utilities.favorites.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if Utilities.favorites.count > 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteCell") as! FavoriteCell
            
            cell.parkTitle.text = Utilities.favorites[indexPath.row]
            
            return cell
        }
        else {
            return tableView.dequeueReusableCellWithIdentifier("NoFavoriteCell")! as UITableViewCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if Utilities.favorites.count == 0
        {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewControllerWithIdentifier("ParkController") as! ParkController
        let menuNavigation = self.navigationController as! MenuNavigation
        
        destController.parkName = Utilities.favorites[indexPath.row]
        
        hideSideMenuView()
        menuNavigation.setViewControllers([destController], animated: true)
        
        Utilities.loadPark(menuNavigation)
    }
    
    @IBAction func websitePressed(sender: AnyObject)
    {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://sandyspringsconservancy.org")!)
    }
    
    @IBAction func amenitySearchPressed(sender: AnyObject)
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuNavigation = self.navigationController as! MenuNavigation
        let destController = mainStoryboard.instantiateViewControllerWithIdentifier("AmenityController") as! AmenityController
        menuNavigation.setViewControllers([destController], animated: true)
    }
    
    @IBAction func menuPressed(sender: AnyObject)
    {
        toggleSideMenuView()
    }
    
    @IBAction func mapPressed(sender: AnyObject)
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuNavigation = self.navigationController as! MenuNavigation
        let destController = mainStoryboard.instantiateViewControllerWithIdentifier("MapController") as! MapController
        menuNavigation.setViewControllers([destController], animated: true)
    }
}
