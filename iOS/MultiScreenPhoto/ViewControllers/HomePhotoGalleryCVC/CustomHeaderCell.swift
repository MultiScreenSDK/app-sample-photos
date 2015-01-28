//
//  CustomHeaderCell.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 27/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit



protocol CustomHeaderCellDelegate {
    func expandSection(section : Int)
    func collapseSection(section : Int)
}

class CustomHeaderCell: UITableViewCell {
    
    @IBOutlet weak var title: UIButton!
    @IBOutlet weak var imageViewArrow: UIImageView!
    @IBOutlet weak var imageViewSeparator : UIImageView!
    
    var delegate: CustomHeaderCellDelegate!
    var section : Int!
    var state = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func drawRect(rect: CGRect)
    {
        var image: UIImage
        
        if(state == false){
            image = UIImage(named: "icon-arrow-down")!
        }else{
            image = UIImage(named: "icon-arrow-up")!
        }
        imageViewArrow.image = image
        
        if(section == 0){
            imageViewSeparator.hidden = true
        }
        
    }


    @IBAction func headerClicked(sender: UIButton) {
        
        if(state == false){
            state = true
            delegate.expandSection(self.section)
        }else{
            state = false
            delegate.collapseSection(self.section)
        }
        
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
