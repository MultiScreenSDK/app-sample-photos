//
//  CommonVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 20/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

let updateCastButtonObserverIdentifier = "updateCastButton"

// Common UIViewController to reuse code for navigation bar
class CommonVC: UIViewController {
    
    // UIView that contains a list of available services
    var castMenuView: UIView!
    // MultiScreenManager instance that manage the interaction with the TV
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add an observer to check for services status and manage the cast icon
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCastButton", name: updateCastButtonObserverIdentifier, object: nil)
        
        //Method to configure the Cast icon and Settings icon
        updateCastButton()
    }
    
    
    // Method called by the updateCastButton observer
    // Add or remove the cast icon to the Navigation bar
    func updateCastButton() {
        
        //Cast icon Image variable
        var imageCastButton: UIImage!
        
        // Configuring setting icon
        self.navigationItem.rightBarButtonItem = nil;
        let imageSettingButton = UIImage(named: "btn_show_popover_cell") as UIImage?
        var addSettingButton: UIBarButtonItem = UIBarButtonItem(image: imageSettingButton, style: .Plain, target: self, action: "showSettings")
        
        //Configuring cast icon
        //Check if there is services availables
        if(multiScreenManager.getServices().count > 0){
            //Check if there is an application current connected
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
    
    // UIView that contains a list of available services
    // User can connect to a selected service
    // User can disconnect from a selected service
    func showCastMenuView(){
        self.castMenuView = CastMenuView.loadFromNibNamed("CastMenuView")
        self.castMenuView.frame = view.frame
        view.window?.addSubview(castMenuView)
        
    }
    
    // UIViewController that contains a turorial of How to use the app
    func showSettings(){
        let detailController = HowToVC(nibName: "HowToVC", bundle: NSBundle.mainBundle())
        self.navigationController?.pushViewController(detailController, animated:true)
    }
    
    //Remove observer when deinit
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: updateCastButtonObserverIdentifier, object: nil)
    }
    
    /* Method to help us display alert dialogs to the user */
    func displayAlertWithTitle( title:NSString, message:NSString) {
        let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
}
