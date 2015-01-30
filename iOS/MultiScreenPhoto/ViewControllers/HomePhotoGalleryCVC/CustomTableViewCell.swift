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
    
    @IBOutlet weak var imageView0: UIButton!
    @IBOutlet weak var imageView1: UIButton!
    @IBOutlet weak var imageView2: UIButton!
    @IBOutlet weak var imageView3: UIButton!
    @IBOutlet weak var imageView4: UIButton!
    
    var delegate : CustomTableViewCellDelegate!
    var section : Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView0.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
        imageView0.layer.borderWidth = 0.5
        imageView1.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor

        imageView1.layer.borderWidth = 0.5
        imageView2.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
        imageView2.layer.borderWidth = 0.5
        imageView3.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor

        imageView3.layer.borderWidth = 0.5
        imageView4.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor

        imageView4.layer.borderWidth = 0.5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickedImage(sender: UIButton) {
        delegate.photoSelected(NSIndexPath(forRow: sender.tag, inSection: section))
    }
    

}
