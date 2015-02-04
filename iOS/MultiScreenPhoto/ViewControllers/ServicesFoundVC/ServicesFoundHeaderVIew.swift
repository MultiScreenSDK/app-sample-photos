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
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var switchToView: UIView!
    @IBOutlet weak var linebottom: UIImageView!
    
    var delegate : ServicesFoundHeaderVIewDelegate!
    
    var isConnected: Bool = false {
        didSet {
            disconnectButton.hidden = !isConnected
            service.hidden = !isConnected
            line.hidden = !isConnected
            switchToView.hidden = !isConnected
            linebottom.hidden = !isConnected
            disconnectButton.layer.cornerRadius = 2
            disconnectButton.layer.borderWidth = 0.5
            disconnectButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            
            if(isConnected){
                title.text = "Connected to:"
                icon.image = UIImage(named: "btn_cast_on")
            }else{
                title.text = "Select TV"
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
