//
//  SideMenu.swift
//  SwiftSideMenu
//
//  Created by Evgeny on 24.07.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

@objc public protocol ENSideMenuDelegate
{
    @objc optional func sideMenuWillOpen()
    @objc optional func sideMenuWillClose()
}

@objc public protocol ENSideMenuProtocol
{
    var sideMenu : ENSideMenu? { get }
    func setContentViewController(_ contentViewController: UIViewController)
    func present(_ viewController: UIViewController)
}

public enum ENSideMenuAnimation : Int
{
    case none
    case `default`
}

public enum ENSideMenuPosition : Int
{
    case left
    case right
}

public extension UIViewController
{
    func toggleSideMenuView()
    {
        sideMenuController()?.sideMenu?.toggleMenu()
    }
    
    func hideSideMenuView()
    {
        sideMenuController()?.sideMenu?.hideSideMenu()
    }
    
    func showSideMenuView()
    {
        sideMenuController()?.sideMenu?.showSideMenu()
    }
    
    func sideMenuController() -> ENSideMenuProtocol? {
        var iteration : UIViewController? = self.parent
        
        if iteration == nil
        {
            return topMostController()
        }
        
        repeat {
            if iteration is ENSideMenuProtocol
            {
                return iteration as? ENSideMenuProtocol
            }
            else if iteration?.parent != nil && iteration?.parent != iteration
            {
                iteration = iteration!.parent;
            }
            else {
                iteration = nil;
            }
        } while (iteration != nil)
        
        return iteration as? ENSideMenuProtocol
    }
    
    internal func topMostController() -> ENSideMenuProtocol?
    {
        var topController : UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        
        while topController?.presentedViewController is ENSideMenuProtocol
        {
            topController = topController?.presentedViewController;
        }
        
        return topController as? ENSideMenuProtocol
    }
}

open class ENSideMenu : NSObject
{
    open var menuWidth : CGFloat = 100.0 {
        didSet {
            needUpdateAppearance = true
            updateFrame()
        }
    }
    
    open var menuPosition : ENSideMenuPosition = .left
    fileprivate let sideMenuContainerView =  UIView()
    fileprivate var menuTableViewController : UITableViewController!
    fileprivate let sourceView : UIView!
    fileprivate var needUpdateAppearance : Bool = false
    open weak var delegate : ENSideMenuDelegate?
    fileprivate var isMenuOpen : Bool = false
    
    public init(sourceView: UIView, menuPosition: ENSideMenuPosition)
    {
        self.sourceView = sourceView
        
        super.init()
        
        self.menuPosition = menuPosition
        self.setupMenuView()
        
        // Add right swipe gesture recognizer
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ENSideMenu.handleGesture(_:)))
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizer.Direction.right
        sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
        
        // Add left swipe gesture recognizer
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ENSideMenu.handleGesture(_:)))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.left
        
        if menuPosition == .left
        {
            sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
            sourceView.addGestureRecognizer(leftSwipeGestureRecognizer)
            sideMenuContainerView.addGestureRecognizer(leftSwipeGestureRecognizer)
        }
        else {
            sideMenuContainerView.addGestureRecognizer(rightSwipeGestureRecognizer)
            sourceView.addGestureRecognizer(leftSwipeGestureRecognizer)
            sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
        }
    }

    public convenience init(sourceView: UIView, menuTableViewController: UITableViewController, menuPosition: ENSideMenuPosition)
    {
        self.init(sourceView: sourceView, menuPosition: menuPosition)
        
        self.menuTableViewController = menuTableViewController
        self.menuTableViewController.tableView.frame = sideMenuContainerView.bounds
        self.menuTableViewController.tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        sideMenuContainerView.addSubview(self.menuTableViewController.tableView)
    }
    
    fileprivate func updateFrame()
    {
        let menuFrame = CGRect(
            x: (menuPosition == .left) ?
                isMenuOpen ? 0 : -menuWidth-1.0 :
                isMenuOpen ? sourceView.frame.size.width - menuWidth : sourceView.frame.size.width+1.0,
            y: sourceView.frame.origin.y,
            width: menuWidth,
            height: sourceView.frame.size.height
        )
        
        sideMenuContainerView.frame = menuFrame
    }

    fileprivate func setupMenuView()
    {
        // Configure side menu container
        updateFrame()

        sideMenuContainerView.backgroundColor = UIColor.clear
        sideMenuContainerView.clipsToBounds = false
        sideMenuContainerView.layer.masksToBounds = false;
        sideMenuContainerView.layer.shadowOffset = (menuPosition == .left) ? CGSize(width: 1.0, height: 1.0) : CGSize(width: -1.0, height: -1.0);
        sideMenuContainerView.layer.shadowRadius = 1.0;
        sideMenuContainerView.layer.shadowOpacity = 0.125;
        sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).cgPath
        
        sourceView.addSubview(sideMenuContainerView)
        
        if NSClassFromString("UIVisualEffectView") != nil
        {
            // Add blur view
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light)) as UIVisualEffectView
            visualEffectView.frame = sideMenuContainerView.bounds
            visualEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            sideMenuContainerView.addSubview(visualEffectView)
        }
    }
    
    func toggleMenu(_ shouldOpen: Bool, closeCompletion: (() -> Void)? = nil)
    {
        updateSideMenuAppearanceIfNeeded()
        isMenuOpen = shouldOpen
        
        var destFrame : CGRect
        
        if menuPosition == .left
        {
            destFrame = CGRect(x: (shouldOpen) ? -2.0 : -menuWidth, y: 0, width: menuWidth, height: sideMenuContainerView.frame.size.height)
        }
        else {
            destFrame = CGRect(x: (shouldOpen) ? sourceView.frame.size.width-menuWidth : sourceView.frame.size.width+2.0,
                                    y: 0,
                                    width: menuWidth,
                                    height: sideMenuContainerView.frame.size.height)
        }
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.sideMenuContainerView.frame = destFrame
        }, completion: {(success) in
            closeCompletion?()
        })
        
        if shouldOpen
        {
            delegate?.sideMenuWillOpen?()
        }
        else {
            delegate?.sideMenuWillClose?()
        }
    }
    
    @objc internal func handleGesture(_ gesture: UISwipeGestureRecognizer) {
        toggleMenu((self.menuPosition == .right && gesture.direction == .left)
            || (self.menuPosition == .left && gesture.direction == .right))
    }
    
    fileprivate func updateSideMenuAppearanceIfNeeded()
    {
        if needUpdateAppearance
        {
            var frame = sideMenuContainerView.frame
            frame.size.width = menuWidth
            sideMenuContainerView.frame = frame
            sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).cgPath

            needUpdateAppearance = false
        }
    }
    
    open func toggleMenu()
    {
        if isMenuOpen
        {
            toggleMenu(false)
        }
        else {
            updateSideMenuAppearanceIfNeeded()
            toggleMenu(true)
        }
    }
    
    open func showSideMenu()
    {
        if !isMenuOpen
        {
            toggleMenu(true)
        }
    }
    
    open func hideSideMenu()
    {
        if isMenuOpen
        {
            toggleMenu(false)
        }
    }
}

