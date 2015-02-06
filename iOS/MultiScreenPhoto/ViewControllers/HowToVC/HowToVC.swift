//
//  HowToVC.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// HowToVC
///
/// This class is used to show the 'How to use' ViewController
class HowToVC: UIViewController {
    
    /// Button used to display a list of compatible devices
    @IBOutlet weak var compatibleButton: UIButton!
    
    /// UIView that contains the compatible devices View
    var compatibleTVsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Adding borders to compatibleButton
        compatibleButton.layer.cornerRadius = 0
        compatibleButton.layer.borderWidth = 0.5
        compatibleButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         // Method to setup the navigation bar color and fonts
        setUpNavigationBar()
    }
    
    // Method to setup the navigation bar color and fonts
    func setUpNavigationBar(){
        
       /// Set the Navigation Bar color
       self.navigationController?.navigationBar.setBackgroundImage(getImageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 100, height: 144)), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        /// Configuring the back icon
        self.navigationItem.leftBarButtonItems = nil;
        let imageBackButton = UIImage(named: "btn-back-more") as UIImage?
        var addBackButton: UIBarButtonItem = UIBarButtonItem(image: imageBackButton, style: .Plain, target: self, action: "goBack")
        self.navigationItem.leftBarButtonItems = [addBackButton]
        //self.navigationController?.navigationBar.translucent = false
        
    }
    /// Methos used to close the current View
    func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /// Method used to capture the event when the compatibleButton button is clicked
    /// If it was clicked then displays the CompatibleTVsView 
    @IBAction func compatibleDevices(sender: AnyObject) {
        self.compatibleTVsView = NSBundle.mainBundle().loadNibNamed("CompatibleTVsView", owner: self, options: nil)[0] as? UIView
        self.compatibleTVsView.frame = view.frame
        view.window?.addSubview(compatibleTVsView)
    
    }
    
    /// Method used to capture the event when the email is clicked
    @IBAction func contactEmail(sender: AnyObject) {
        
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
