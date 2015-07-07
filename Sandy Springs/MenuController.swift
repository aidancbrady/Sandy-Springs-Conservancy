//
//  MenuController.swift
//  Sandy Springs
//
//  Created by aidancbrady on 1/26/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit

class MenuController: UIViewController
{
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var developerButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        logoImage.frame = CGRectMake(view.frame.minX+16, navigationController!.navigationBar.frame.maxY+16, view.frame.maxX-32, (view.frame.maxX-32))
        welcomeLabel.frame = CGRect(x: view.frame.maxX/2 - welcomeLabel.frame.width/2, y: logoImage.frame.maxY + 8, width: welcomeLabel.frame.width, height: welcomeLabel.frame.height)
        websiteButton.frame = CGRect(x: view.frame.maxX/2 - websiteButton.frame.width/2, y: welcomeLabel.frame.maxY + 32, width: websiteButton.frame.width, height: websiteButton.frame.height)
        developerButton.frame = CGRect(x: view.frame.maxX/2 - developerButton.frame.width/2, y: websiteButton.frame.maxY + 12, width: developerButton.frame.width, height: developerButton.frame.height)
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
