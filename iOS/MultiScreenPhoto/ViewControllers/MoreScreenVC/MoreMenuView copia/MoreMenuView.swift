//
//  MoreMenuView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 3/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// MoreMenuViewDelegate
///
/// This delegate is used to know when the more button is pressed
protocol MoreMenuViewDelegate {
    func goToMoreScreenVC()
}

/// MoreMenuView
///
/// This class is used to show the 'More' Menu
class MoreMenuView: UIView,UIGestureRecognizerDelegate {
    
    var delegate: MoreMenuViewDelegate!
    
    
    override func awakeFromNib(){
        super.awakeFromNib()
        /// Add a gesture recognizer to dismiss the current view on tap
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "closeView")
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
    }
    /// Method used to close the current View
    func closeView() {
        self.removeFromSuperview()
    }
    
    /// Method used to capture the event when the more button is clicked
    /// If is clicked then call the MoreMenuViewDelegate
    @IBAction func moreOptionSelected(sender: AnyObject) {
        self.removeFromSuperview()
        delegate.goToMoreScreenVC()
    }
    
    /// UIGestureRecognizerDelegate used to disable the tap event if the tapped View is not the main View
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        if (touch.view.tag == 1){
            return true
        }
        return false
    }

}
