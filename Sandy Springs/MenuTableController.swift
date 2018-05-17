//
//  MenuTableController.swift
//  Sandy Springs
//
//  Created by aidancbrady on 1/26/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit
import MessageUI

class MenuTableController: UITableViewController, MFMailComposeViewControllerDelegate
{
    var menuData: [(String, Bool, String)] = [(String, Bool, String)]()
    var parkData: [(String, Bool, String)] = [(String, Bool, String)]()
    var displayedData: [(String, Bool, String)] = [(String, Bool, String)]()
    var dropdownActive = false
    var dropdownImage: UIImageView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(24.0, 0, 0, 0)
        tableView.scrollsToTop = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        
        self.clearsSelectionOnViewWillAppear = false
        
        menuData.append(("Home", true, "MenuController"))
        menuData.append(("About", true, "AboutController"))
        menuData.append(("Park List", true, "ParkSearchController"))
        menuData.append(("Park Map", true, "MapController"))
        menuData.append(("Amenity Search", true, "AmenityController"))
        menuData.append(("Show Parks", true, "dropdown"))
        menuData.append(("Donate", true, "donate"))
        menuData.append(("Contact & Support", true, "contact"))
        
        for data in ParkController.Parks.parkData
        {
            parkData.append((data.0, false, "ParkController"))
        }
        
        for data in menuData
        {
            if data.1
            {
                displayedData.append(data)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true)
        hideSideMenuView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return displayedData[(indexPath as NSIndexPath).row].1 ? 48 : 36
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return displayedData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let data = displayedData[(indexPath as NSIndexPath).row]
        let cellType = data.2 == "dropdown" ? "dropdownCell" : "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellType)

        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellType)
            cell!.backgroundColor = UIColor.clear
            cell!.textLabel?.textColor = UIColor.darkGray
            let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
            
            if cellType == "dropdownCell"
            {
                let size = cell!.frame.height/2
                let yStart = cell!.frame.height/2 - size/2 + 2
                let imageView = UIImageView(frame: CGRect(x: cell!.contentView.frame.maxX-size-35, y: cell!.frame.minY + yStart, width: size, height: size))
                imageView.image = UIImage(named: dropdownActive ? "up" : "down")
                imageView.contentMode = .scaleToFill
                cell!.addSubview(imageView)
                dropdownImage = imageView
            }
        }
        
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
        let selectedItem = (indexPath as NSIndexPath).row
        
        if displayedData[selectedItem].2 == "dropdown"
        {
            dropdownActive = !dropdownActive
            
            let range = selectedItem+1...selectedItem+parkData.count
            let paths = range.map{return IndexPath(row: $0, section: indexPath.section)}
            dropdownImage?.image = UIImage(named: dropdownActive ? "up" : "down")
            tableView.beginUpdates()
            
            if dropdownActive
            {
                tableView.cellForRow(at: indexPath)!.textLabel!.text = "Hide Parks"
                displayedData[selectedItem].0 = "Hide Parks"
                displayedData.insert(contentsOf: parkData, at: selectedItem+1)
                tableView.insertRows(at: paths, with: .top)
            }
            else {
                tableView.cellForRow(at: indexPath)!.textLabel!.text = "Show Parks"
                displayedData[selectedItem].0 = "Show Parks"
                displayedData.removeSubrange(range)
                tableView.deleteRows(at: paths, with: .top)
            }
            
            tableView.endUpdates()
            tableView.deselectRow(at: indexPath, animated: true)
            
            return
        }
        else if displayedData[selectedItem].2 == "contact"
        {
            if MFMailComposeViewController.canSendMail()
            {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([Constants.DEV_EMAIL])
                tableView.deselectRow(at: indexPath, animated: true)
                
                Utilities.getTopViewController()?.present(mail, animated: true)
            }
            
            return
        }
        else if displayedData[selectedItem].2 == "donate"
        {
            if let url = URL(string: Constants.DONATE_SITE)
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            hideSideMenuView()
            
            return
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewController(withIdentifier: displayedData[selectedItem].2) as UIViewController
        
        if destController is ParkController
        {
            let park = destController as! ParkController
            
            park.parkName = displayedData[selectedItem].0
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if displayedData[selectedItem].2 == "MenuController"
        {
            sideMenuController()?.setContentViewController(destController)
        }
        else {
            sideMenuController()?.present(destController)
        }
    }
}
