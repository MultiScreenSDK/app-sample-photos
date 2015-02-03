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
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 21/255, green: 21/255, blue: 21/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Configuring setting icon
        self.navigationItem.leftBarButtonItems = nil;
        let imageBackButton = UIImage(named: "btn_back_arrow") as UIImage?
        var addBackButton: UIBarButtonItem = UIBarButtonItem(image: imageBackButton, style: .Plain, target: self, action: "goBack")
        self.navigationItem.leftBarButtonItems = [addBackButton]
        self.navigationController?.navigationBar.translucent = false
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
