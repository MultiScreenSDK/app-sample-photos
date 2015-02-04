//
//  WelcomeView.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 19/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

class WelcomeView: UIView {
    
    @IBOutlet weak var getStartButton: UIButton!
    
    @IBAction func getStart(sender: UIButton) {
        self.removeFromSuperview()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        getStartButton.layer.cornerRadius = 1
        getStartButton.layer.borderWidth = 0.5
        getStartButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    

}
