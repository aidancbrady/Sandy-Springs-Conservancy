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
    var tableController = MenuTableController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: tableController, menuPosition: .right)
        sideMenu!.menuWidth = 300
        sideMenu!.delegate = self
        sideMenuAnimationType = .none
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer?)
    {
        if sender!.location(in: self.view).x > sideMenu!.menuWidth
        {
            hideSideMenuView()
        }
        
        sender!.cancelsTouchesInView = false
    }
    
    func sideMenuWillClose()
    {
        DispatchQueue.global(qos: .background).async {
            usleep(1000*1000)
            DispatchQueue.main.async {
                if self.topViewController is ParkController
                {
                    (self.topViewController as! ParkController).loadMap()
                }
            }
        }
    }
}
