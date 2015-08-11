//
//  MenuTableController.swift
//  Sandy Springs
//
//  Created by aidancbrady on 1/26/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit

class MenuTableController: UITableViewController
{
    var selectedItem = 0
    var menuData: [(String, Bool, String)] = [(String, Bool, String)]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(24.0, 0, 0, 0)
        tableView.scrollsToTop = false
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        
        self.clearsSelectionOnViewWillAppear = false
        
        menuData.append("Parks", true, "MenuController")
        
        for data in ParkController.Parks.parkData
        {
            menuData.append(data.0, false, "ParkController")
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return menuData[indexPath.row].1 ? 48 : 36
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuData.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell

        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        let data = menuData[indexPath.row]
        
        cell!.textLabel?.text = data.1 ? data.0 : (" - " + data.0)
        
        if data.1
        {
            cell!.textLabel?.font = UIFont.boldSystemFontOfSize(16)
        }
        else {
            cell!.textLabel?.font = UIFont.systemFontOfSize(15)
        }

        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row == selectedItem
        {
            return
        }
        
        selectedItem = indexPath.row
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewControllerWithIdentifier(menuData[selectedItem].2) as! UIViewController
        
        if destController is ParkController
        {
            let park = destController as! ParkController
            
            park.parkName = menuData[selectedItem].0
        }
        
        sideMenuController()?.setContentViewController(destController)
    }
}
