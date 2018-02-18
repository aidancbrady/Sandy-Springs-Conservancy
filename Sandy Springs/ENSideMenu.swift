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
    public func toggleSideMenuView()
    {
        sideMenuController()?.sideMenu?.toggleMenu()
    }
    
    public func hideSideMenuView()
    {
        sideMenuController()?.sideMenu?.hideSideMenu()
    }
    
    public func showSideMenuView()
    {
        sideMenuController()?.sideMenu?.showSideMenu()
    }
    
    public func sideMenuController() -> ENSideMenuProtocol? {
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
            needUpdateApperance = true
            updateFrame()
        }
    }
    
    fileprivate var menuPosition:ENSideMenuPosition = .left
    open var bouncingEnabled :Bool = true
    fileprivate let sideMenuContainerView =  UIView()
    fileprivate var menuTableViewController : UITableViewController!
    fileprivate var animator : UIDynamicAnimator!
    fileprivate let sourceView : UIView!
    fileprivate var needUpdateApperance : Bool = false
    open weak var delegate : ENSideMenuDelegate?
    fileprivate var isMenuOpen : Bool = false
    
    public init(sourceView: UIView, menuPosition: ENSideMenuPosition)
    {
        self.sourceView = sourceView
        
        super.init()
        
        self.menuPosition = menuPosition
        self.setupMenuView()
    
        animator = UIDynamicAnimator(referenceView:sourceView)
        
        // Add right swipe gesture recognizer
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ENSideMenu.handleGesture(_:)))
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.right
        sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
        
        // Add left swipe gesture recognizer
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ENSideMenu.handleGesture(_:)))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        
        if menuPosition == .left
        {
            sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
            sideMenuContainerView.addGestureRecognizer(leftSwipeGestureRecognizer)
        }
        else {
            sideMenuContainerView.addGestureRecognizer(rightSwipeGestureRecognizer)
            sourceView.addGestureRecognizer(leftSwipeGestureRecognizer)
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
    
    fileprivate func toggleMenu(_ shouldOpen: Bool)
    {
        updateSideMenuApperanceIfNeeded()
        isMenuOpen = shouldOpen
        
        if bouncingEnabled
        {
            animator.removeAllBehaviors()
            
            var gravityDirectionX: CGFloat
            var pushMagnitude: CGFloat
            var boundaryPointX: CGFloat
            var boundaryPointY: CGFloat
            
            if menuPosition == .left
            {
                // Left side menu
                gravityDirectionX = (shouldOpen) ? 1.5 : -1.5
                pushMagnitude = (shouldOpen) ? 20 : -20
                boundaryPointX = (shouldOpen) ? menuWidth : -menuWidth-2
                boundaryPointY = 20
            }
            else {
                // Right side menu
                gravityDirectionX = (shouldOpen) ? -1.5 : 1.5
                pushMagnitude = (shouldOpen) ? -20 : 20
                boundaryPointX = (shouldOpen) ? sourceView.frame.size.width-menuWidth : sourceView.frame.size.width+menuWidth+2
                boundaryPointY =  -20
            }
            
            let gravityBehavior = UIGravityBehavior(items: [sideMenuContainerView])
            gravityBehavior.gravityDirection = CGVector(dx: gravityDirectionX,  dy: 0)
            animator.addBehavior(gravityBehavior)
            
            let collisionBehavior = UICollisionBehavior(items: [sideMenuContainerView])
            collisionBehavior.addBoundary(withIdentifier: "menuBoundary" as NSCopying, from: CGPoint(x: boundaryPointX, y: boundaryPointY),
                to: CGPoint(x: boundaryPointX, y: sourceView.frame.size.height))
            animator.addBehavior(collisionBehavior)
            
            let pushBehavior = UIPushBehavior(items: [sideMenuContainerView], mode: UIPushBehaviorMode.instantaneous)
            pushBehavior.magnitude = pushMagnitude
            animator.addBehavior(pushBehavior)
            
            let menuViewBehavior = UIDynamicItemBehavior(items: [sideMenuContainerView])
            menuViewBehavior.elasticity = 0.25
            animator.addBehavior(menuViewBehavior)
        }
        else {
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
            })
        }
        
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
    
    fileprivate func updateSideMenuApperanceIfNeeded()
    {
        if needUpdateApperance
        {
            var frame = sideMenuContainerView.frame
            frame.size.width = menuWidth
            sideMenuContainerView.frame = frame
            sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).cgPath

            needUpdateApperance = false
        }
    }
    
    open func toggleMenu()
    {
        if isMenuOpen
        {
            toggleMenu(false)
        }
        else {
            updateSideMenuApperanceIfNeeded()
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

