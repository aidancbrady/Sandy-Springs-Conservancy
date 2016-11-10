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
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        
        self.clearsSelectionOnViewWillAppear = false
        
        menuData.append(("Home", true, "MenuController"))
        menuData.append(("Park Map", true, "MapController"))
        menuData.append(("Amenity Search", true, "AmenityController"))
        
        for data in ParkController.Parks.parkData
        {
            menuData.append((data.0, false, "ParkController"))
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return menuData[(indexPath as NSIndexPath).row].1 ? 48 : 36
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!

        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
            cell!.backgroundColor = UIColor.clear
            cell!.textLabel?.textColor = UIColor.darkGray
            let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        let data = menuData[(indexPath as NSIndexPath).row]
        
        cell!.textLabel?.text = data.1 ? data.0 : (" " + data.0)
        
        if data.1
        {
            cell!.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        }
        else {
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 15)
        }

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath as NSIndexPath).row == selectedItem
        {
            hideSideMenuView()
            return
        }
        
        selectedItem = (indexPath as NSIndexPath).row
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewController(withIdentifier: menuData[selectedItem].2) as UIViewController
        
        if destController is ParkController
        {
            let park = destController as! ParkController
            
            park.parkName = menuData[selectedItem].0
        }
        
        sideMenuController()?.setContentViewController(destController)
    }
}
