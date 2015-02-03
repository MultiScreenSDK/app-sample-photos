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

class MoreMenuView: UIView {
    
    var delegate: MoreMenuViewDelegate!

    @IBAction func moreOptionSelected(sender: AnyObject) {
        self.removeFromSuperview()
        delegate.goToHowToView()
    }

}
