//
//  MoreMenuView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 3/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

protocol MoreMenuViewDelegate {
    func goToHowToView()
}

class MoreMenuView: UIView,UIGestureRecognizerDelegate {
    
    var delegate: MoreMenuViewDelegate!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "closeView")
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
    }

    func closeView() {
        self.removeFromSuperview()
    }

    @IBAction func moreOptionSelected(sender: AnyObject) {
        self.removeFromSuperview()
        delegate.goToHowToView()
    }
    
  
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        if (touch.view.tag == 1){
            return true
        }
        return false
    }

}
