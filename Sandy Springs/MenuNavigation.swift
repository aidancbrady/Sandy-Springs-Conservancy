//
//  MenuNavigation.swift
//  Sandy Springs
//
//  Created by aidancbrady on 1/26/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit

class MenuNavigation: ENSideMenuNavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: MenuTableController(), menuPosition: .Left)
        sideMenu!.menuWidth = 220
        sideMenuAnimationType = .None
    }
}
