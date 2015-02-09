//
//  ServicesFoundHeaderVIew.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// ServicesFoundHeaderVIewDelegate
///
/// This delegate is used to know when the disconnect button is clicked
protocol ServicesFoundHeaderVIewDelegate {
    func closeApplication()
}

/// ServicesFoundHeaderVIew
///
/// This class is used to customize the Header in the UITableView
class ServicesFoundHeaderVIew: UIView {

    /// Title of the header
    @IBOutlet weak var title: UILabel!
    /// Cast Icon
    @IBOutlet weak var icon: UIImageView!
    /// Current service connected name
    @IBOutlet weak var service: UILabel!
    /// Disconnect button
    @IBOutlet weak var disconnectButton: UIButton!
    
    /// Just lines and background view
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var linebottom: UIImageView!
    @IBOutlet weak var switchToView: UIView!
    
    var delegate : ServicesFoundHeaderVIewDelegate!
    
    /// Variable used to set the header status
    /// If it is not connected then hide the Outlet and changes the cast icon
    var isConnected: Bool = false {
        didSet {
            disconnectButton.hidden = !isConnected
            service.hidden = !isConnected
            line.hidden = !isConnected
            switchToView.hidden = !isConnected
            linebottom.hidden = !isConnected
            disconnectButton.layer.cornerRadius = 0
            disconnectButton.layer.borderWidth = 0.5
            disconnectButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            
            if(isConnected){
                title.text = "Connected to:"
                icon.image = UIImage(named: "icon_cast_connect")
            }else{
                title.text = "Connect to:"
                icon.image = UIImage(named: "icon_cast_discovered")
            }
        }
    }
    
    /// Method used to capture the event when the disconnectButton button is clicked
    /// If it was clicked calls the closeApplication delegate
    @IBAction func disconectService(sender: AnyObject) {
        delegate.closeApplication()
    }
}
