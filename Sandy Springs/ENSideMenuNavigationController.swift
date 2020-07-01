//
//  RootNavigationViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

open class ENSideMenuNavigationController: UINavigationController, ENSideMenuProtocol
{
    open var sideMenu : ENSideMenu?
    open var sideMenuAnimationType : ENSideMenuAnimation = .default
    
    // MARK: - Life cycle
    open override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    public init(menuTableViewController: UITableViewController, contentViewController: UIViewController?)
    {
        super.init(nibName: nil, bundle: nil)
        
        if contentViewController != nil
        {
            self.viewControllers = [contentViewController!]
        }

        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: menuTableViewController, menuPosition:.left)
        view.bringSubviewToFront(navigationBar)
    }

    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    open override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    open func setContentViewController(_ contentViewController: UIViewController)
    {
        self.hideSideMenuView()
        
        switch sideMenuAnimationType
        {
            case .none:
                self.viewControllers = [contentViewController]
                break
            default:
                contentViewController.navigationItem.hidesBackButton = true
                self.setViewControllers([contentViewController], animated: true)
                break
        }
    }
    
    open func present(_ viewController: UIViewController)
    {
        self.hideSideMenuView()
        
        let oldController = Utilities.getTopViewController()!
        var differentParks = false
        
        if oldController is ParkController && viewController is ParkController
        {
            differentParks = (oldController as! ParkController).park.parkName != (viewController as! ParkController).parkName
        }
        
        if type(of: oldController) != type(of: viewController) || differentParks
        {
            self.pushViewController(viewController, animated: true)
        }
    }
}
