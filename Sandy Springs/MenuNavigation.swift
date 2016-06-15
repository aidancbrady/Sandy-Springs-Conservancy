//
//  MenuNavigation.swift
//  Sandy Springs
//
//  Created by aidancbrady on 1/26/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit

class MenuNavigation: ENSideMenuNavigationController, ENSideMenuDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: MenuTableController(), menuPosition: .Left)
        sideMenu!.menuWidth = self.view.frame.width*(4/5)
        sideMenu!.delegate = self
        sideMenuAnimationType = .None
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }
    
    func onTap(sender: UITapGestureRecognizer?)
    {
        if sender!.locationInView(self.view).x > sideMenu!.menuWidth
        {
            hideSideMenuView()
        }
        
        sender!.cancelsTouchesInView = false
    }
    
    func sideMenuWillClose()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            usleep(1000*1000)
            dispatch_async(dispatch_get_main_queue(), {
                if self.topViewController is ParkController
                {
                    (self.topViewController as! ParkController).loadMap()
                }
            })
        })
    }
}
