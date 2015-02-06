//
//  CastMenuView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

let servicesFoundTVCellID = "ServicesFoundTVCell"

protocol ServicesFoundViewDelegate {
    func sendToTv()
}

var multiScreenManager = MultiScreenManager.sharedInstance

class ServicesFoundView: UIView, UITableViewDelegate, UITableViewDataSource, ServicesFoundHeaderVIewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var services = [AnyObject]()
    
    var delegate: ServicesFoundViewDelegate!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        self.tableView.registerNib(UINib(nibName: servicesFoundTVCellID, bundle: nil), forCellReuseIdentifier: servicesFoundTVCellID)
        services = multiScreenManager.getServicesNotConnected()
        self.tableView.rowHeight = 38
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        tap.addTarget(self, action: "closeView")
        self.addGestureRecognizer(tap)
    }
    
    func refreshTableView(){
        services = multiScreenManager.getServicesNotConnected()
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return services.count;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell : ServicesFoundTVCell
        cell = tableView.dequeueReusableCellWithIdentifier(servicesFoundTVCellID, forIndexPath: indexPath) as ServicesFoundTVCell
        cell.title.text = "\(services[indexPath.row].name)"
        var selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        cell.selectedBackgroundView = selectedView
        return cell
        
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        if(multiScreenManager.isApplicationConnected() == true){
            return 160
        }else{
            return 40
        }
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        var viewArray = NSBundle.mainBundle().loadNibNamed("ServicesFoundHeaderVIew", owner: self, options: nil)
        var headerView = viewArray[0] as ServicesFoundHeaderVIew
        headerView.isConnected = multiScreenManager.isApplicationConnected()
        if(multiScreenManager.isApplicationConnected() == true){
            headerView.service.text =  multiScreenManager.getApplicationCurrentService().name
        }
        headerView.delegate = self
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        multiScreenManager.createApplication(services[indexPath.row] as Service, completionHandler: { (success: Bool!) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("updateCastButton", object: self)
            if((success) == true){
                self.delegate.sendToTv()
                self.removeFromSuperview()
            }
        })
    }
    
    func closeApplication(){
        multiScreenManager.closeApplication({ (success: Bool!) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("updateCastButton", object: self)
            self.removeFromSuperview()
        })
    }
    
    func closeView() {
        self.removeFromSuperview()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        if (touch.view.tag == 1){
            return true
        }
        return false
    }
    
    
}
