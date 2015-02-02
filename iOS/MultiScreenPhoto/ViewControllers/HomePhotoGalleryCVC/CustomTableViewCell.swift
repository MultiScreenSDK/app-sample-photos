//
//  CustomTableViewCell1.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 27/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

protocol CustomTableViewCellDelegate {
    func photoSelected(indexPath : NSIndexPath)
}

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var buttonPhoto0: UIButton!
    @IBOutlet weak var buttonPhoto1: UIButton!
    @IBOutlet weak var buttonPhoto2: UIButton!
    @IBOutlet weak var buttonPhoto3: UIButton!
    @IBOutlet weak var buttonPhoto4: UIButton!
    
    var delegate : CustomTableViewCellDelegate!
    var section : Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // Initialization code
        
        buttonPhoto0.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
        buttonPhoto0.layer.borderWidth = 0.5
        buttonPhoto1.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
        buttonPhoto1.layer.borderWidth = 0.5
        buttonPhoto2.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
        buttonPhoto2.layer.borderWidth = 0.5
        buttonPhoto3.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
        buttonPhoto3.layer.borderWidth = 0.5
        buttonPhoto4.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
        buttonPhoto4.layer.borderWidth = 0.5

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickedImage(sender: UIButton) {
        delegate.photoSelected(NSIndexPath(forRow: sender.tag, inSection: section))
    }
    

}
