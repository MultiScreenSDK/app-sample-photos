//
//  WelcomeView.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 19/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// WelcomeView
///
/// This class is used to show the 'Welcome' view the first time the app runs
class WelcomeView: UIView {
    
    // UIButton the close the current view when clicked
    @IBOutlet weak var getStartButton: UIButton!
    
    /// Methos used to close the current View
    @IBAction func getStart(sender: UIButton) {
        self.removeFromSuperview()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        /// Adding borders to the get start button
        getStartButton.layer.cornerRadius = 0
        getStartButton.layer.borderWidth = 0.5
        getStartButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    

}
