//
//  CommonVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 20/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

class CommonVC: UIViewController {
    
    var serviceFoundView: UIView!
    var multiScreenManager = MultiScreenManager.sharedInstance

    override func viewDidLoad() {
     super.viewDidLoad()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCastButton", name: "updateCastButton", object: nil)
    
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateCastButton()
    }
    
    func updateCastButton() {
        
        
        
        self.navigationItem.rightBarButtonItem = nil;
        
        let imageSettingButton = UIImage(named: "btn_show_popover_cell") as UIImage?
        
        var addSettingButton: UIBarButtonItem = UIBarButtonItem(image: imageSettingButton, style: .Plain, target: self, action: "showSettings" )
        
        
        if(multiScreenManager.getServices().count > 0){
            
            var imageCastButton: UIImage!

            if(multiScreenManager.isApplicationConnected() == true){
                imageCastButton = UIImage(named: "btn_cast_on")
            }else{
                imageCastButton = UIImage(named: "btn_cast_off")
            }
            
            var addCastButton: UIBarButtonItem = UIBarButtonItem(image: imageCastButton, style: .Plain, target: self, action: "showCastMenuView")
            addCastButton.width = 22
         
            self.navigationItem.rightBarButtonItems = [addSettingButton,addCastButton]
        }else{
            self.navigationItem.rightBarButtonItems = [addSettingButton]
        }
    }
    
    func showCastMenuView(){
            self.serviceFoundView = ServicesFoundView.loadFromNibNamed("ServicesFoundView")
            self.serviceFoundView.frame = view.frame
            view.window?.addSubview(serviceFoundView)
       
    }
    
    func showSettings(){
        
        let detailController = HowToVC(nibName: "HowToVC", bundle: NSBundle.mainBundle())
        self.navigationController?.pushViewController(detailController, animated:true)
    }
    
    deinit {
        // NSNotificationCenter.defaultCenter().removeObserver(self, name: ALAssetsLibraryChangedNotification, object: nil)
    }
    
    /* Just a little method to help us display alert dialogs to the user */
    func displayAlertWithTitle( title:NSString, message:NSString) {
        let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        alertView.alertViewStyle = .Default
        alertView.show()
    }

}
