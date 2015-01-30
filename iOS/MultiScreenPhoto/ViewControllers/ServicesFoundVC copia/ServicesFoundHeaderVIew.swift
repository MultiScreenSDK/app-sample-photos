//
//  ServicesFoundHeaderVIew.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

protocol ServicesFoundHeaderVIewDelegate {
    func closeApplication()
}

class ServicesFoundHeaderVIew: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var service: UILabel!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var line: UIImageView!
    
    var delegate : ServicesFoundHeaderVIewDelegate!
    
    var isConnected: Bool = false {
        didSet {
            connectedLabel.hidden = !isConnected
            disconnectButton.hidden = !isConnected
            service.hidden = !isConnected
            line.hidden = !isConnected
            
            disconnectButton.layer.cornerRadius = 4
            disconnectButton.layer.borderWidth = 0.5
            disconnectButton.layer.borderColor = UIColor.whiteColor().CGColor
            
            if(isConnected){
                title.text = "CONNECTED TO"
                icon.image = UIImage(named: "btn_cast_on")
            }else{
                title.text = "SELECT THE TV"
                icon.image = UIImage(named: "btn_cast_off")
            }
            
        }
    }
    
    override func awakeFromNib(){
        super.awakeFromNib()
    }
    
    @IBAction func dicconectService(sender: AnyObject) {
        delegate.closeApplication()
    }
}
