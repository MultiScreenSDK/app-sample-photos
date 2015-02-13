//
//  HomePhotoGalleryHeaderView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 2/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// HomePhotoGalleryHeaderViewDelegate
///
/// This delegate is used to know which header was clicked
protocol HomePhotoGalleryHeaderViewDelegate {
    func headerClicked(section : Int)
}

/// HomePhotoGalleryHeaderView
///
/// This class is used to customize the Header for each section in the UITableView
class HomePhotoGalleryHeaderView: UITableViewHeaderFooterView {

    /// This is the title of the header
    @IBOutlet weak var headerTitle: UIButton!
    /// Arrow image that changes depending of the section state (collapsed, or expanded)
    @IBOutlet weak var imageViewArrow: UIImageView!
    
    /// Cell Separator
    @IBOutlet weak var imageViewSeparator : UIImageView!
    
    var delegate: HomePhotoGalleryHeaderViewDelegate!
    
    /// Current photo album index
    var section = 0
    
    /// Current state of the album, expanded = true, collapsed = false
    var state = false
    
    override func awakeFromNib(){
        super.awakeFromNib()
        /// Adding borders to the get start button
        let gradient = CAGradientLayer()
        gradient.frame = imageViewSeparator.bounds;
        let color: CGFloat = 24/255
        let black = UIColor(red: color, green: color, blue: color, alpha: 0.7).CGColor
        let black2 = UIColor(red: color, green: color, blue: color, alpha: 0.7).CGColor
        let black3 = UIColor(red: color, green: color, blue: color, alpha: 0.4).CGColor
        let black4 = UIColor(red: color, green: color, blue: color, alpha: 0.3).CGColor
        let black5 = UIColor(red: color, green: color, blue: color, alpha: 0.1).CGColor
        let black6 = UIColor(red: color, green: color, blue: color, alpha: 0.1).CGColor
        gradient.colors = [UIColor.clearColor().CGColor,black6,black5,black4,black3,black2,black]
        imageViewSeparator.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    override func drawRect(rect: CGRect)
    {
        setArrowIcon()
    }
    
    /// Method used to capture the event when a header is clicked
    @IBAction func selectedButton(sender: UIButton) {
        delegate.headerClicked(section)
    }
    
    /// Method used to change the imageViewArrow depending of the current album state
    func setArrowIcon(){
        if(state == true){
            imageViewArrow.image = UIImage(named: "icon_arrow_up")!
        }else{
            imageViewArrow.image = UIImage(named: "icon_arrow_down")!
        }
        /// If the header is the first in the list then hidde the separator image.
        if(section == 0){
            imageViewSeparator.hidden = true
        }
    }
    

}
