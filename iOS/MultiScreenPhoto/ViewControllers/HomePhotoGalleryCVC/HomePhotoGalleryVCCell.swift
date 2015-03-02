//
//  CustomTableViewCell1.swift
//  MultiScreenPhoto
/*

Copyright (c) 2014 Samsung Electronics

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/
import UIKit

/// HomePhotoGalleryVCCellDelegate
///
/// This delegate is used to know which photo was selected
protocol HomePhotoGalleryVCCellDelegate {
    func photoSelected(indexPath: NSIndexPath)
}

/// HomePhotoGalleryVCCell
///
/// This class is used to customize the UITableViewCell
class HomePhotoGalleryVCCell: UITableViewCell {
    
    // UIButton Array that contains the Images for each cell
    @IBOutlet var buttonPhoto: [UIButton]!
    
    var delegate: HomePhotoGalleryVCCellDelegate!
    
    // Current photo album index
    var section: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Iterate the Array of Buttons to setup its borders
        for (button) in buttonPhoto {
            button.layer.borderColor = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
            button.layer.borderWidth = 0.5
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
            button.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
            button.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        }
    }
    
    // Method used to capture the event when a photo is selected
    @IBAction func clickedImage(sender: UIButton) {
        delegate.photoSelected(NSIndexPath(forRow: sender.tag, inSection: section))
    }
    

}
