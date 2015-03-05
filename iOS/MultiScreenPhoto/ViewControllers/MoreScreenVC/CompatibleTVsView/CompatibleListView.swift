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

/// CompatibleListView
///
/// This class is used to display a list of compatible devices
class CompatibleListView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    
    // UITableView to diplay the gallery photos
    @IBOutlet weak var tableView: UITableView!
    
    var modelArray = []
    
    /// Identifier for UITableview cell
    let compatibleTVCell = "CompatibleTVCellID"
    override func awakeFromNib(){
        super.awakeFromNib()
        
        
        /// Configuring the tableView cell and separator style
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: compatibleTVCell)
        
        /// Configuring the tableView separator style
        if tableView.respondsToSelector("setSeparatorInset:") {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector("setLayoutMargins:") {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        tableView.layoutIfNeeded()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        /// populating the inches from a Plist file
        if let path = NSBundle.mainBundle().pathForResource("CompatibleList", ofType: "plist") {
            var modelDict = NSDictionary(contentsOfFile: path)
            modelArray = modelDict?.objectForKey("model") as NSArray
            tableView.reloadData()
        }
        
        /// Add a gesture recognizer to dismiss the current view on tap
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "closeView")
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return modelArray.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var text: String
        
        /// Setting the custom cell view
        var cell: UITableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier(compatibleTVCell, forIndexPath: indexPath) as UITableViewCell
        
        var modelDict = modelArray[indexPath.row] as NSDictionary
        text = modelDict.objectForKey("name") as String
        
        // Set tableView separator style
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.SingleLine
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        
        /// Adding the text for each cell
        cell.textLabel?.textColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        cell.textLabel?.textAlignment = .Left
        cell.textLabel?.attributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont(name: "Roboto-Light", size: 12.0)!])
        cell.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        
        return cell
        
    }
    
    
    /// Closes the current View
    func closeView() {
        self.removeFromSuperview()
    }
    
    /// UIGestureRecognizerDelegate used to disable the tap event if the tapped View is not the main View
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        if (touch.view.tag == 1){
            return true
        }
        return false
    }
    
}
