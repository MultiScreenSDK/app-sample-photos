//
//  CustomTableViewCell1.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 27/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// HomePhotoGalleryVCCellDelegate
///
/// This delegate is used to know which photo was selected
protocol HomePhotoGalleryVCCellDelegate {
    func photoSelected(indexPath : NSIndexPath)
}

/// HomePhotoGalleryVCCell
///
/// This class is used to customize the UITableViewCell
class HomePhotoGalleryVCCell: UITableViewCell {
    
    // UIButton Array that contains the Images for each cell
    @IBOutlet var buttonPhoto: [UIButton]!
    
    var delegate : HomePhotoGalleryVCCellDelegate!
    
    // Current photo album index
    var section : Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Iterate the Array of Buttons to setup its borders
        for (button) in buttonPhoto {
            button.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
            button.layer.borderWidth = 0.5
        }
    }
    
    // Method used to capture the event when a photo is selected
    @IBAction func clickedImage(sender: UIButton) {
        delegate.photoSelected(NSIndexPath(forRow: sender.tag, inSection: section))
    }
    

}
