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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        logoImage.frame = CGRectMake(view.frame.minX+16, navigationController!.navigationBar.frame.maxY+16, view.frame.maxX-32, (view.frame.maxX-32))
    }
    
    @IBAction func menuPressed(sender: AnyObject)
    {
        toggleSideMenuView()
    }
}
