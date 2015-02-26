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
    func headerClicked(section: Int)
}

/// HomePhotoGalleryHeaderView
///
/// This class is used to customize the Header for each section in the UITableView
class HomePhotoGalleryHeaderView: UITableViewHeaderFooterView {

    /// This is the title of the header
    @IBOutlet weak var headerTitle: UIButton!
    /// Arrow image that changes depending of the section state (collapsed or expanded)
    @IBOutlet weak var imageViewArrow: UIImageView!
    
    /// Cell Separator
    @IBOutlet weak var imageViewSeparator: UIImageView!
    
    var delegate: HomePhotoGalleryHeaderViewDelegate!
    
    /// Current photo album index
    var section = 0
    
    /// Current state of the album, expanded = true, collapsed = false
    var state = false
    
    override func drawRect(rect: CGRect)
    {
        setArrowIcon()
    }
    
    /// Method used to capture the event when a header is clicked
    @IBAction func selectedButton(sender: UIButton) {
        state = !state
        setArrowIcon()
        delegate.headerClicked(section)
    }
    
    /// Method used to change the imageViewArrow depending of the current album state
    func setArrowIcon(){
        if(state == true){
            imageViewArrow.image = UIImage(named: "icon_arrow_up")!
        }else{
            imageViewArrow.image = UIImage(named: "icon_arrow_down")!
        }
         imageViewSeparator.hidden = state
    }
    

}
