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
    @IBOutlet weak var developerButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        logoImage.frame = CGRectMake(view.frame.width/4, navigationController!.navigationBar.frame.maxY+48, view.frame.width/2, view.frame.width/2)
        favoritesLabel.frame = CGRect(x: view.frame.maxX/2 - favoritesLabel.frame.width/2, y: logoImage.frame.maxY + 32, width: favoritesLabel.frame.width, height: favoritesLabel.frame.height)
        favoritesTable.frame = CGRect(x: view.frame.minX, y: favoritesLabel.frame.maxY + 8, width: view.frame.width, height: 208)
        
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        favoritesTable.scrollEnabled = true
        
        websiteButton.frame = CGRect(x: view.frame.maxX/2 - websiteButton.frame.width/2, y: favoritesTable.frame.maxY + 32, width: websiteButton.frame.width, height: websiteButton.frame.height)
        developerButton.frame = CGRect(x: view.frame.maxX/2 - developerButton.frame.width/2, y: websiteButton.frame.maxY + 12, width: developerButton.frame.width, height: developerButton.frame.height)
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
        self.dismissViewControllerAnimated(false, completion: nil)
        
        for i in 0..<menuNavigation.tableController.menuData.count
        {
            menuNavigation.tableController.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0), animated: false)
        }
        
        menuNavigation.tableController.selectedItem = -1
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            usleep(1000*1000)
            dispatch_async(dispatch_get_main_queue(), {
                if menuNavigation.topViewController is ParkController
                {
                    (menuNavigation.topViewController as! ParkController).loadMap()
                }
            })
        })
    }
    
    @IBAction func websitePressed(sender: AnyObject)
    {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://sandyspringsconservancy.org")!)
    }
    
    @IBAction func developerPressed(sender: AnyObject)
    {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://aidancbrady.com/contact")!)
    }
    
    @IBAction func menuPressed(sender: AnyObject)
    {
        toggleSideMenuView()
    }
}
