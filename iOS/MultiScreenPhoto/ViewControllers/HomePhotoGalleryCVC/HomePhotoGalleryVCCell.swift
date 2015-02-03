//
//  CustomTableViewCell1.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 27/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

protocol HomePhotoGalleryVCCellDelegate {
    func photoSelected(indexPath : NSIndexPath)
}

class HomePhotoGalleryVCCell: UITableViewCell {
    
    @IBOutlet var buttonPhoto: [UIButton]!
    
    var delegate : HomePhotoGalleryVCCellDelegate!
    var section : Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        for (button) in buttonPhoto {
            button.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
            button.layer.borderWidth = 0.5
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickedImage(sender: UIButton) {
        delegate.photoSelected(NSIndexPath(forRow: sender.tag, inSection: section))
    }
    

}
