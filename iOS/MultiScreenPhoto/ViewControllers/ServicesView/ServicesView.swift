//
//  ServicesView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit


/// ServicesView
///
/// This class is used to display a list of near services in the same Network
class ServicesView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    /// MultiScreenManager instance that manage the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    /// Identifier for UITableview cell
    let servicesFoundTVCellID = "ServicesFoundTVCell"
    
    /// UITableView to diplay the services
    @IBOutlet weak var tableView: UITableView!
    
    /// Temp array of services
    var services = [AnyObject]()
    
    /// Header View Height Constraint
    @IBOutlet weak var headerViewConstraint: NSLayoutConstraint!
    /// Title of the header
    @IBOutlet weak var title: UILabel!
    /// Cast Icon
    @IBOutlet weak var icon: UIImageView!
    /// Current service connected name
    @IBOutlet weak var serviceConnectedName: UILabel!
    /// Disconnect button
    @IBOutlet weak var disconnectButton: UIButton!
    
    @IBOutlet weak var lineImage: UIImageView!
    override func awakeFromNib(){
        super.awakeFromNib()
        
        // Add an observer to check for services status and manage the cast icon
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTableView", name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        
        /// Adding border and color to disconnect button
        disconnectButton.layer.cornerRadius = 0
        disconnectButton.layer.borderWidth = 0.5
        disconnectButton.layer.borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1).CGColor
        
        /// Configuring the tableView separator style
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:servicesFoundTVCellID)
        if tableView.respondsToSelector("setSeparatorInset:") {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector("setLayoutMargins:") {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        tableView.layoutIfNeeded()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        /// Table row height
        self.tableView.rowHeight = 44
        
        /// Add a gesture recognizer to dismiss the current view on tap
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        tap.addTarget(self, action: "closeView")
        self.addGestureRecognizer(tap)
        
        refreshTableView()
        
    }
    
    /// Method used to reload table view with services not connected
    func refreshTableView(){
        
        /// Populate Temp services array with services not connected
        services = multiScreenManager.getServicesNotConnected()
        
        /// Used to change the Cast icon, depending is a service is connected or not
        if(multiScreenManager.isApplicationConnected()){
            title.text = "Connected to:"
            icon.image = UIImage(named: "icon_cast_connect")
            serviceConnectedName.text =  multiScreenManager.getApplicationCurrentService().name
            /// Used to change the header size
            if(services.count>0){
                headerViewConstraint.constant = 161
            }else{
                headerViewConstraint.constant = 123
            }
            lineImage.backgroundColor = UIColor.whiteColor()
        }else{
            title.text = "Connect to:"
            icon.image = UIImage(named: "icon_cast_discovered")
            lineImage.backgroundColor = UIColor.blackColor()
            headerViewConstraint.constant = 41
        }

        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return services.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        /// Setting the custom cell view
        var cell : UITableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier(servicesFoundTVCellID, forIndexPath: indexPath) as UITableViewCell
        
        // Set tableView separator style
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.SingleLine
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        /// Adding color to the cell on click
        var selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        cell.selectedBackgroundView = selectedView
        cell.selectionStyle = UITableViewCellSelectionStyle.Default
        
        /// Adding the text for each cell
        cell.textLabel?.textColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        cell.textLabel?.textAlignment = .Left
        cell.textLabel?.frame.origin.x = -20
        cell.textLabel?.attributedText = NSMutableAttributedString(string: "\(services[indexPath.row].name)", attributes: [NSFontAttributeName:UIFont(name: "Roboto-Light", size: 14.0)!])
        cell.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        /// If cell is selected then cconnect and start the application
        multiScreenManager.createApplication(services[indexPath.row] as Service, completionHandler: { (success: Bool!) -> Void in
            if((success) == true){
                self.closeView()
            }
        })
    }
    
    /// Method used to capture the event when the disconnectButton button is clicked
    /// this will close the current service connection
    @IBAction func  closeApplication(){
        multiScreenManager.closeApplication({ (success: Bool!) -> Void in
            /// Post a notification to the NSNotificationCenter
            /// this notification is used to update the cast icon
            NSNotificationCenter.defaultCenter().postNotificationName(self.multiScreenManager.servicesChangedObserverIdentifier, object: self)
            self.closeView()
        })
    }
    
    /// Method used to close the current View
    func closeView() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
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
