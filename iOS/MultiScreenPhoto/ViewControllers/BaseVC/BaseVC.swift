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

/// BaseVC, it's a reusable UIViewController
///
/// Base class for other View Controllers to reuse methods
/// for the navigation bar
class BaseVC: UIViewController, UIGestureRecognizerDelegate {
    
    /// MultiScreenManager instance that manages the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    /// UIView that contains a list of available services
    var servicesView: ServicesView!
    
    /// UIView that contains the More menu
    var moreMenuView: UIView!
    
    /// Cast icon Image variable
    var imageCastButton: UIImage!
    
    var imageConnectedCastButton: UIImage!
    var imageDisconnectedCastButton: UIImage!
    var imageSettingsButton: UIImage!
    var settingsButton: UIButton!
    var castButton: UIButton!
    var addCastButton: UIBarButtonItem!
    var addSettingsButton: UIBarButtonItem!
    var addSpacerButton: UIBarButtonItem!
    
    /// Alert view to displaye popup messages
    var alertView: UIAlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageConnectedCastButton = UIImage(named: "icon_cast_connect")
        imageDisconnectedCastButton = UIImage(named: "icon_cast_discovered")
        imageSettingsButton = UIImage(named: "btn_more_menu") as UIImage?
        
        /// Configuring setting icon
        settingsButton = UIButton(frame: CGRectMake(0, 0, 20, 22))
        settingsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
        settingsButton.addTarget(self, action: Selector("showMoreMenuView"), forControlEvents: UIControlEvents.TouchUpInside)
        settingsButton.setImage(imageSettingsButton, forState: UIControlState.Normal)
        addSettingsButton = UIBarButtonItem(customView: settingsButton)
        
        /// Configuring Spacer between buttons
        addSpacerButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        addSpacerButton.width = 20

        /// Configuring cast icon
        castButton = UIButton(frame: CGRectMake(0, 0, 22, 17))
        castButton.addTarget(self, action: Selector("showCastMenuView"), forControlEvents: UIControlEvents.TouchUpInside)
        castButton.setBackgroundImage(imageDisconnectedCastButton, forState: UIControlState.Normal)
        addCastButton = UIBarButtonItem(customView: castButton)
    
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add an observer to check for services status and manage the cast icon
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setCastIcon", name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        //configure the Cast icon and Settings icon
        setCastIcon()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove observer
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
    }
    
    /// Add or remove the cast icon from the Navigation bar
    /// Called by the servicesChanged observer
    func setCastIcon() {
        /// Show cast icon only if atleast one service/TV is available
        if (multiScreenManager.services.count > 0 || multiScreenManager.isConnected){
            
            if (multiScreenManager.isConnected == true){
                castButton.setBackgroundImage(imageConnectedCastButton, forState: UIControlState.Normal)
            }
            else {
                castButton.setBackgroundImage(imageDisconnectedCastButton, forState: UIControlState.Normal)
            }
            self.navigationItem.rightBarButtonItems = [addSettingsButton, addSpacerButton, addCastButton]
        }
        else {
            self.navigationItem.rightBarButtonItems = [addSettingsButton]
        }
    }
    
    /// Shows a list of available services
    /// User can connect to a service
    /// User can disconnect from a connected service
    func showCastMenuView(){
        /// UIView that contains a list of available services
        var viewArray = NSBundle.mainBundle().loadNibNamed("ServicesView", owner: self, options: nil)
        servicesView = viewArray[0] as ServicesView
        servicesView.frame = UIScreen.mainScreen().bounds
        
        /// Adding UIVIew to superView
        addUIViewToWindowSuperView(servicesView)
    }
    
    /// Show the More menu
    func showMoreMenuView(){
        
        /// UIView that contains a list of options
        moreMenuView = UIView(frame: UIScreen.mainScreen().bounds)
        moreMenuView.backgroundColor = UIColor.clearColor()
        
        /// Add a gesture recognizer to dismiss the current view on tap
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "closeMoreMenuView")
        tap.delegate = self
        moreMenuView.addGestureRecognizer(tap)
        
        /// Creating and adding Menu Button
        var moreMenuButton = UIButton(frame: CGRectMake(0, 45, 97, 34))
        moreMenuButton.addTarget(self, action: Selector("goToMoreScreenVC"), forControlEvents: UIControlEvents.TouchUpInside)
        moreMenuButton.backgroundColor = UIColor.whiteColor()
        moreMenuButton.setAttributedTitle(NSMutableAttributedString(string: "MORE", attributes: [NSFontAttributeName: UIFont(name: "Roboto-Light", size: 18.0)!]), forState: UIControlState.Normal)
        moreMenuButton.titleLabel?.textColor = UIColor.grayColor()
        moreMenuButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        moreMenuView.addSubview(moreMenuButton)
        
        /// Adding menuButton constraints
        let moreButtonDict = ["button": moreMenuButton]
        moreMenuView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[button(97)]-(20)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: moreButtonDict))
        moreMenuView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(45)-[button(34)]", options: NSLayoutFormatOptions(0), metrics: nil, views: moreButtonDict))
        
        /// Adding UIVIew to superView
        addUIViewToWindowSuperView(moreMenuView)
    }
    
    /// Closes more menu view
    func closeMoreMenuView(){
        moreMenuView.removeFromSuperview()
    }
    
    /// Shows How to use tutorial
    func goToMoreScreenVC(){
        
        /// Close the more menu view
        closeMoreMenuView()
        
        /// UIViewController that contains a detailed tutorial
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("MoreScreenVC") as MoreScreenVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    /// Displays an Alert dialog
    func displayAlertWithTitle( title: NSString, message: NSString) {
        alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
    func addUIViewToWindowSuperView(view: UIView){
        
        /// Adding UIVIew to superView
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var window = UIApplication.sharedApplication().keyWindow
        if (window == nil){
            window = UIApplication.sharedApplication().windows[0] as? UIWindow
        }
        
        window?.subviews[0].addSubview(view)
        
        /// Adding view constraints
        let viewDict = ["view": view]
        window?.subviews[0].addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDict))
        window?.subviews[0].addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDict))
        
    }
}
