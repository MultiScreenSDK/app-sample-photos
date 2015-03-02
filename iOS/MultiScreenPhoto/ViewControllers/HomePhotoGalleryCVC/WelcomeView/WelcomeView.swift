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

/// WelcomeView
///
/// This class is used to show the 'Welcome' view the first time the app runs
class WelcomeView: UIView {
    
    // UIButton the close the current view when clicked
    @IBOutlet weak var getStartButton: UIButton!
    
    /// Methos used to close the current View
    @IBAction func getStart(sender: UIButton) {
        self.removeFromSuperview()
    }
    override func awakeFromNib(){
        super.awakeFromNib()
        /// Adding borders to the get start button
        getStartButton.layer.cornerRadius = 0
        getStartButton.layer.borderWidth = 0.5
        getStartButton.layer.borderColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1).CGColor
    }
  
}
