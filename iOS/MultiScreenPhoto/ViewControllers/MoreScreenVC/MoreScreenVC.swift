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
import MessageUI

/// MoreScreenVC
///
/// This class is used to show the 'How to use' ViewController
class MoreScreenVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    /// Button used to display a list of compatible devices
    @IBOutlet weak var compatibleButton: UIButton!
    
    /// UIView that contains the compatible devices View
    var compatibleListView: UIView!
    
    @IBOutlet weak var iconCastDiscoveredConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Adding borders to compatibleButton
        compatibleButton.layer.cornerRadius = 0
        compatibleButton.layer.borderWidth = 0.5
        compatibleButton.layer.borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1).CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Setup the navigation bar color and fonts
        setUpNavigationBar()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // Setup the navigation bar color and fonts
    func setUpNavigationBar(){
        
        /// Set the Navigation Bar color
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bg_subtitlebar_home"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor =  UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        
        /// Configuring the back icon
        self.navigationItem.leftBarButtonItems = nil;
        let imageBackButton = UIImage(named: "btn_back_more") as UIImage?
        let backMoreButton = UIButton(frame: CGRectMake(0, 0, 65, 17))
        backMoreButton.addTarget(self, action: Selector("goBack"), forControlEvents: UIControlEvents.TouchUpInside)
        backMoreButton.setBackgroundImage(imageBackButton, forState: UIControlState.Normal)
        var addBackButton: UIBarButtonItem = UIBarButtonItem(customView: backMoreButton)
        self.navigationItem.leftBarButtonItems = [addBackButton]
        
    }
    /// Close the current View
    func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /// Capture the event when the compatibleButton is clicked
    /// If it was clicked then displays the CompatibleListView
    @IBAction func compatibleDevices(sender: AnyObject) {
        compatibleListView = NSBundle.mainBundle().loadNibNamed("CompatibleListView", owner: self, options: nil)[0] as? UIView
        compatibleListView.frame = UIScreen.mainScreen().bounds
        
        /// Adding UIVIew to superView
        compatibleListView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var window = UIApplication.sharedApplication().keyWindow
        if (window == nil){
            window = UIApplication.sharedApplication().windows[0] as? UIWindow
        }
        
        window?.subviews[0].addSubview(compatibleListView)
        
        /// Adding compatibleListView constraints
        let compatibleListViewDict = ["view": compatibleListView]
        window?.subviews[0].addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: compatibleListViewDict))
        window?.subviews[0].addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: compatibleListViewDict))
    }
    
    /// Capture the event when the email is clicked
    @IBAction func contactEmail(sender: UIButton) {
        if(MFMailComposeViewController.canSendMail()) {
            var picker = MFMailComposeViewController()
            picker.mailComposeDelegate = self
            picker.setToRecipients(["multiscreen@sisa.samsung.com"])
            picker.setSubject("")
            picker.setMessageBody("", isHTML: true)
            
            presentViewController(picker, animated: true, completion: nil)
        } else {
            self.displayAlertWithTitle("", message: "Please set up a Mail account in order to send email")
        }
    }
    
    // MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    /// Used to change iconcastposition
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            iconCastDiscoveredConstraint.constant = 0
        } else {
            iconCastDiscoveredConstraint.constant = -8.5
        }
    }

    /// Displays an Alert dialog
    func displayAlertWithTitle( title: NSString, message: NSString) {
        var  alertView:UIAlertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
}
