//
//  CastMenuView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit


/// ServicesFoundView
///
/// This class is used to display a list of near services in the same Network
class ServicesFoundView: UIView, UITableViewDelegate, UITableViewDataSource, ServicesFoundHeaderVIewDelegate, UIGestureRecognizerDelegate {
    
    /// MultiScreenManager instance that manage the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    /// Identifier for UITableview cell
    let servicesFoundTVCellID = "ServicesFoundTVCell"

    /// UITableView to diplay the services
    @IBOutlet weak var tableView: UITableView!
    
    /// Temp array of services
    var services = [AnyObject]()
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        /// Configuring the tableView cell
        self.tableView.registerNib(UINib(nibName: servicesFoundTVCellID, bundle: nil), forCellReuseIdentifier: servicesFoundTVCellID)
        self.tableView.rowHeight = 44
        
        /// Add a gesture recognizer to dismiss the current view on tap
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        tap.addTarget(self, action: "closeView")
        self.addGestureRecognizer(tap)
        
        /// Populate Temp services array with services not connected
        services = multiScreenManager.getServicesNotConnected()
        
    }
    
    /// Method used to reload table view with services not connected
    func refreshTableView(){
        services = multiScreenManager.getServicesNotConnected()
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
        var cell : ServicesFoundTVCell
        cell = tableView.dequeueReusableCellWithIdentifier(servicesFoundTVCellID, forIndexPath: indexPath) as ServicesFoundTVCell
        cell.title.text = "\(services[indexPath.row].name)"
        
        /// Adding color to the cell on click
        var selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        cell.selectedBackgroundView = selectedView
        
        return cell
        
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        /// Returning the height of the header depending if an Application is connected
        if(multiScreenManager.isApplicationConnected() == true){
            if(services.count>0){
              return 157
            }else{
              return 123
            }
        }else{
            return 40
        }
    }
    
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        /// UIView that contains the header view
        var viewArray = NSBundle.mainBundle().loadNibNamed("ServicesFoundHeaderVIew", owner: self, options: nil)
        var headerView = viewArray[0] as ServicesFoundHeaderVIew
        
        /// Set the isConnected var will hide or show the header view Outlets
        headerView.isConnected = multiScreenManager.isApplicationConnected()
        
        /// Set the showSwitchToView var will hide or show the swicth to view Outlet
        headerView.showSwitchToView = (services.count>0 && multiScreenManager.isApplicationConnected())
        
        /// If there is an application connected then displays the name of the service
        if(multiScreenManager.isApplicationConnected() == true){
            headerView.service.text =  multiScreenManager.getApplicationCurrentService().name
        }
        headerView.delegate = self
        
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        /// If cell is selected then cconnect and start the application
        multiScreenManager.createApplication(services[indexPath.row] as Service, completionHandler: { (success: Bool!) -> Void in
                /// Post a notification to the NSNotificationCenter
                /// this notification is used to update the cast icon
            NSNotificationCenter.defaultCenter().postNotificationName("updateCastButton", object: self)
            if((success) == true){
                self.removeFromSuperview()
            }
        })
    }
    
    /// Method used to close the current application
    func closeApplication(){
        multiScreenManager.closeApplication({ (success: Bool!) -> Void in
            /// Post a notification to the NSNotificationCenter
            /// this notification is used to update the cast icon
            NSNotificationCenter.defaultCenter().postNotificationName("updateCastButton", object: self)
            self.removeFromSuperview()
        })
    }
    /// Method used to close the current View
    func closeView() {
        self.removeFromSuperview()
    }
    
    /// UIGestureRecognizerDelegate used to disable the tap event if the tapped View is not the main View
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        if (touch.view.tag != 1){
            return true
        }
        return false
    }
    
    
}
