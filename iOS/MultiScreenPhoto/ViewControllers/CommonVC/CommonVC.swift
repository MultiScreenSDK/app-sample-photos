//
//  CommonVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 20/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// CommonVC, it's a reusable UIViewController
///
/// This class is inherited from other View Controllers to reuse methods 
/// for the navigation bar
class CommonVC: UIViewController, MoreMenuViewDelegate {
    
    /// MultiScreenManager instance that manage the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    /// Observer identifier for cast notification
    let updateCastButtonObserverIdentifier = "updateCastButton"
    
    /// UIView that contains a list of available services
    var castMenuView: ServicesFoundView!
    
    /// UIView that contains the More menu
    var moreMenuView: MoreMenuView!
    
    /// Cast icon Image variable
    var imageCastButton: UIImage!
    
    /// Alert view to displaye popup messages
    var alertView: UIAlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Method to configure the Cast icon and Settings icon
        updateCastButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add an observer to check for services status and manage the cast icon
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCastButton", name: updateCastButtonObserverIdentifier, object: nil)
        updateCastButton()
    }
    
    /// Remove observer when viewDidDisappear
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: updateCastButtonObserverIdentifier, object: nil)
    }
    
    /// Method called by the updateCastButton observer
    /// Add or remove the cast icon from the Navigation bar
    func updateCastButton() {
        
        /// Configuring setting icon
        self.navigationItem.rightBarButtonItem = nil;
        let imageSettingsButton = UIImage(named: "btn_more_menu") as UIImage?
        let settingsButton = UIButton(frame: CGRectMake(0,0,20,22))
        settingsButton.imageEdgeInsets = UIEdgeInsetsMake(0,8,0,8)
        
        settingsButton.addTarget(self, action: Selector("showSettings"), forControlEvents: UIControlEvents.TouchUpInside)
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
        var viewArray = NSBundle.mainBundle().loadNibNamed("ServicesFoundView", owner: self, options: nil)
        self.castMenuView = viewArray[0] as ServicesFoundView
        self.castMenuView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
       view.window?.addSubview(self.castMenuView)
    }
    
    /// Method to show the More menu
    func showSettings(){
        /// UIView that contains a list of options
        var viewArray = NSBundle.mainBundle().loadNibNamed("MoreMenuView", owner: self, options: nil)
        self.moreMenuView = viewArray[0] as MoreMenuView
        self.moreMenuView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        self.moreMenuView.delegate = self
        view.window?.addSubview(self.moreMenuView)
    }
    
    /// Method that shows a How to use tutorial
    func goToHowToView(){
        /// UIViewController that contains a detailed tutorial
        let detailController = HowToVC(nibName: "HowToVC", bundle: NSBundle.mainBundle())
        self.navigationController?.pushViewController(detailController, animated:true)
    }
    
    
    /// Method that displays an Alert dialogs
    func displayAlertWithTitle( title:NSString, message:NSString) {
        alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
    /// Return an UIImage from a given UIColor
    /// This method is used for the translucent Navigation Bar
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
  
    
}
