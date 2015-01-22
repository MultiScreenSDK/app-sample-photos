//
//  CommonVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 20/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit



class CommonVC: UIViewController {
    
    var tvIntegration = TVIntegration.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
  
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNavbarButton", name: "updateCastButton", object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavbarButton()
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    /* Just a little method to help us display alert dialogs to the user */
    func displayAlertWithTitle( title:NSString, message:NSString) {
        let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
    func updateNavbarButton() {
        // println("[NavBar] NavBArUpdating")
        
        self.navigationItem.rightBarButtonItem = nil;
        
        let imageSettingButton = UIImage(named: "btn_show_popover_cell") as UIImage?
        
        var addSettingButton: UIBarButtonItem = UIBarButtonItem(image: imageSettingButton, style: .Plain, target: self, action: "showSettings" )
        
        
        if(tvIntegration.getServices().count > 0){
            
            var imageCastButton: UIImage!

            if(tvIntegration.isApplicationConnected() == true){
                imageCastButton = UIImage(named: "btn_cast_on")
            }else{
                imageCastButton = UIImage(named: "btn_cast_off")
            }
            
            
            var addCastButton: UIBarButtonItem = UIBarButtonItem(image: imageCastButton, style: .Plain, target: self, action: "showServicesFound" )
         
            self.navigationItem.rightBarButtonItems = [addSettingButton,addCastButton]
        }else{
            self.navigationItem.rightBarButtonItems = [addSettingButton]
        }
    }
    
    func showServicesFound(){
        
        if(tvIntegration.isApplicationConnected() == true){
            tvIntegration.closeApplication({ (success: Bool!) -> Void in
                
            NSNotificationCenter.defaultCenter().postNotificationName("updateCastButton", object: self)
                
                if((success) == true){
                    self.displayAlertWithTitle("Connect",
                        message: "TV disconnected")
                }
            })
            
        }else{
            let servicesFoundVC = self.storyboard?.instantiateViewControllerWithIdentifier("ServicesFoundVC") as ServicesFoundVC
            
            self.navigationController?.presentViewController(servicesFoundVC, animated: true, completion: nil)
        }
        
        
    }
    
    func showSettings(){
        self.displayAlertWithTitle("Settings",
            message: "Available soon!")
    }

}
