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
        if (state == true){
            imageViewArrow.image = UIImage(named: "icon_arrow_up")!
        } else {
            imageViewArrow.image = UIImage(named: "icon_arrow_down")!
        }
         imageViewSeparator.hidden = state
    }
    

}
