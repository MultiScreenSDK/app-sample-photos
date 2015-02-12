//
//  MoreVC.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import MessageUI

/// MoreScreenVC
///
/// This class is used to show the 'How to use' ViewController
class MoreScreenVC: UIViewController,MFMailComposeViewControllerDelegate {
    
    /// Button used to display a list of compatible devices
    @IBOutlet weak var compatibleButton: UIButton!
    
    /// UIView that contains the compatible devices View
    var compatibleTVsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Adding borders to compatibleButton
        compatibleButton.layer.cornerRadius = 0
        compatibleButton.layer.borderWidth = 0.5
        compatibleButton.layer.borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1).CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Method to setup the navigation bar color and fonts
        setUpNavigationBar()
    }
    
    // Method to setup the navigation bar color and fonts
    func setUpNavigationBar(){
        
        /// Set the Navigation Bar color
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bg_subtitlebar_home"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor =  UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        
        /// Configuring the back icon
        self.navigationItem.leftBarButtonItems = nil;
        let imageBackButton = UIImage(named: "btn_back_more") as UIImage?
        let backMoreButton = UIButton(frame: CGRectMake(0,0,65,17))
        backMoreButton.addTarget(self, action: Selector("goBack"), forControlEvents: UIControlEvents.TouchUpInside)
        backMoreButton.setBackgroundImage(imageBackButton, forState: UIControlState.Normal)
        var addBackButton: UIBarButtonItem = UIBarButtonItem(customView: backMoreButton)
        self.navigationItem.leftBarButtonItems = [addBackButton]
        
    }
    /// Methos used to close the current View
    func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /// Method used to capture the event when the compatibleButton button is clicked
    /// If it was clicked then displays the CompatibleTVsView
    @IBAction func compatibleDevices(sender: AnyObject) {
        self.compatibleTVsView = NSBundle.mainBundle().loadNibNamed("CompatibleTVsView", owner: self, options: nil)[0] as? UIView
        self.compatibleTVsView.frame = UIScreen.mainScreen().bounds
        view.window?.addSubview(compatibleTVsView)
        
    }
    
    /// Method used to capture the event when the email is clicked
    @IBAction func contactEmail(sender: UIButton) {
        
        var picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setToRecipients(["multiscreen@sisa.samsung.com"])
        picker.setSubject("")
        picker.setMessageBody("", isHTML: true)
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
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
