//
//  BaseVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 20/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// BaseVC, it's a reusable UIViewController
///
/// This class is inherited from other View Controllers to reuse methods 
/// for the navigation bar
class BaseVC: UIViewController, UIGestureRecognizerDelegate {
    
    /// MultiScreenManager instance that manage the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    /// UIView that contains a list of available services
    var servicesView: ServicesView!
    
    /// UIView that contains the More menu
    var moreMenuView: UIView!
    
    /// Cast icon Image variable
    var imageCastButton: UIImage!
    
    /// Alert view to displaye popup messages
    var alertView: UIAlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Method to configure the Cast icon and Settings icon
        setCastIcon()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add an observer to check for services status and manage the cast icon
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setCastIcon", name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        setCastIcon()
    }
    
    /// Remove observer when viewDidDisappear
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
    }
    
    /// Method called by the servicesChanged observer
    /// Add or remove the cast icon from the Navigation bar
    func setCastIcon() {
        
        /// Configuring setting icon
        self.navigationItem.rightBarButtonItem = nil;
        let imageSettingsButton = UIImage(named: "btn_more_menu") as UIImage?
        let settingsButton = UIButton(frame: CGRectMake(0,0,20,22))
        settingsButton.imageEdgeInsets = UIEdgeInsetsMake(0,8,0,8)
        
        settingsButton.addTarget(self, action: Selector("showMoreMenuView"), forControlEvents: UIControlEvents.TouchUpInside)
        settingsButton.setImage(imageSettingsButton, forState: UIControlState.Normal)
        var addSettingsButton: UIBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        /// Configuring Spacer between buttons
        var addSpacerButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        addSpacerButton.width = 20
        
        /// Configuring cast icon
        /// Check if there is services availables
        if(multiScreenManager.getServices().count > 0){
            
            /// Check if there is an application current connected
            if(multiScreenManager.isApplicationConnected() == true){
                imageCastButton = UIImage(named: "icon_cast_connect")
            }else{
                imageCastButton = UIImage(named: "icon_cast_discovered")
            }
            
            let castButton = UIButton(frame: CGRectMake(0,0,22,17))
            castButton.addTarget(self, action: Selector("showCastMenuView"), forControlEvents: UIControlEvents.TouchUpInside)
            castButton.setBackgroundImage(imageCastButton, forState: UIControlState.Normal)
            var addCastButton: UIBarButtonItem = UIBarButtonItem(customView: castButton)
            
            self.navigationItem.rightBarButtonItems = [addSettingsButton,addSpacerButton,addCastButton]
        
        }else{
            self.navigationItem.rightBarButtonItems = [addSettingsButton]
        }
    }
    
    /// Method to show a list of available services
    /// User can connect to a selected service
    /// User can disconnect from a selected service
    func showCastMenuView(){
        /// UIView that contains a list of available services
        var viewArray = NSBundle.mainBundle().loadNibNamed("ServicesView", owner: self, options: nil)
        self.servicesView = viewArray[0] as ServicesView
        self.servicesView.frame = UIScreen.mainScreen().bounds
       view.window?.addSubview(self.servicesView)
    }
    
    /// Method to show the More menu
    func showMoreMenuView(){
        
        /// UIView that contains a list of options
        moreMenuView = UIView(frame: UIScreen.mainScreen().bounds)
        moreMenuView.backgroundColor = UIColor.clearColor()
        
        /// Add a gesture recognizer to dismiss the current view on tap
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "closeMoreMenuView")
        tap.delegate = self
        moreMenuView.addGestureRecognizer(tap)
        
        /// Creating and adding Menu Button
        var moreMenuButton = UIButton(frame: CGRectMake(0,45,97,34))
        moreMenuButton.addTarget(self, action: Selector("goToMoreScreenVC"), forControlEvents: UIControlEvents.TouchUpInside)
        moreMenuButton.backgroundColor = UIColor.whiteColor()
        moreMenuButton.setAttributedTitle(NSMutableAttributedString(string: "MORE", attributes: [NSFontAttributeName:UIFont(name: "Roboto-Light", size: 18.0)!]), forState: UIControlState.Normal)
        moreMenuButton.titleLabel?.textColor = UIColor.grayColor()
        moreMenuButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        moreMenuView.addSubview(moreMenuButton)
        
        /// Adding UIVIew to superView
        moreMenuView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.window?.addSubview(moreMenuView)
        
        /// Adding menuButton constraints
        let moreButtonDict = ["button": moreMenuButton]
        moreMenuView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[button(97)]-(20)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: moreButtonDict))
        moreMenuView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(45)-[button(34)]", options: NSLayoutFormatOptions(0), metrics: nil, views: moreButtonDict))
        
        /// Adding moreMenuView constraints
        let moreViewDict = ["view": moreMenuView]
        view.window?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: moreViewDict))
        view.window?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: moreViewDict))
    }
    
    /// Method used to close the more menu view
    func closeMoreMenuView(){
        moreMenuView.removeFromSuperview()
    }
    
    /// Method that shows a How to use tutorial
    func goToMoreScreenVC(){
        
        /// Method used to close the more menu view
        closeMoreMenuView()
        
        /// UIViewController that contains a detailed tutorial
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("MoreScreenVC") as MoreScreenVC
        self.navigationController?.pushViewController(viewController, animated:true)
    }
    
    
    /// Method that displays an Alert dialogs
    func displayAlertWithTitle( title:NSString, message:NSString) {
        alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
}
