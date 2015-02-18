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
    override func awakeFromNib(){
        super.awakeFromNib()
        /// Adding borders to the get start button
        getStartButton.layer.cornerRadius = 0
        getStartButton.layer.borderWidth = 0.5
        getStartButton.layer.borderColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1).CGColor
    }
  
}
