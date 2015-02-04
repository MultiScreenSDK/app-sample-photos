//
//  HowToVC.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

class HowToVC: UIViewController {
    
    @IBOutlet weak var compatibleButton: UIButton!
    
    var compatibleTVsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        compatibleButton.layer.cornerRadius = 2
        compatibleButton.layer.borderWidth = 0.2
        compatibleButton.layer.borderColor = UIColor.whiteColor().CGColor
       // self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()//UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigationBar()
    }
    
    // Method to setup the navigation bar color and fonts
    func setUpNavigationBar(){
        
       self.navigationController?.navigationBar.setBackgroundImage(getImageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 100, height: 144)), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        
        // Configuring setting icon
        self.navigationItem.leftBarButtonItems = nil;
        let imageBackButton = UIImage(named: "btn-back-more") as UIImage?
        var addBackButton: UIBarButtonItem = UIBarButtonItem(image: imageBackButton, style: .Plain, target: self, action: "goBack")
        self.navigationItem.leftBarButtonItems = [addBackButton]
        //self.navigationController?.navigationBar.translucent = false
        
    }
    
    func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func compatibleDevices(sender: AnyObject) {
        
        self.compatibleTVsView = NSBundle.mainBundle().loadNibNamed("CompatibleTVsView", owner: self, options: nil)[0] as? UIView
        self.compatibleTVsView.frame = view.frame
        view.window?.addSubview(compatibleTVsView)
    
    }

    @IBAction func contactEmail(sender: AnyObject) {
    }
    
    //Return an UIImage from a given UIColor
    //This method is used for the translucent Navigation Bar
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
