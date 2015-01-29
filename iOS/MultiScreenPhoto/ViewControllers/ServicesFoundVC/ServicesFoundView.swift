//
//  ServicesFoundView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

let servicesFoundTVCellID = "ServicesFoundTVCell"

var tvIntegration = TVIntegration.sharedInstance

class ServicesFoundView: UIView, UITableViewDelegate, UITableViewDataSource, ServicesFoundHeaderVIewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var services = [AnyObject]()
    
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
    
    override func awakeFromNib(){
        super.awakeFromNib()
        self.tableView.registerNib(UINib(nibName: servicesFoundTVCellID, bundle: nil), forCellReuseIdentifier: servicesFoundTVCellID)
        
        services.removeAll(keepCapacity: false)
        
        for (value) in tvIntegration.getServices() {
            if(tvIntegration.connectionName != value.name){
                services.append(value)
            }
        }
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
        cell.title.text = "\(services[indexPath.row].name) "
        return cell
        
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        if(tvIntegration.isApplicationConnected() == true){
            return 155
        }else{
            return 55
        }
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        var viewArray = NSBundle.mainBundle().loadNibNamed("ServicesFoundHeaderVIew", owner: self, options: nil)
        var headerView = viewArray[0] as ServicesFoundHeaderVIew
        headerView.isConnected = tvIntegration.isApplicationConnected()
        headerView.service.text =  tvIntegration.connectionName
        headerView.delegate = self
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if(tvIntegration.isApplicationConnected()){
            closeApplication()
        }
        
        tvIntegration.createApplication(tvIntegration.getServiceWithIndex(indexPath.row), completionHandler: { (success: Bool!) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("updateCastButton", object: self)
            if((success) == false){
                tvIntegration.connectionName = ""
            }else{
                tvIntegration.connectionName = self.services[indexPath.row].name
                self.removeFromSuperview()
            }
        })
    }
    
    func closeApplication(){
        
        tvIntegration.closeApplication({ (success: Bool!) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("updateCastButton", object: self)
            self.removeFromSuperview()
        })
    }
    
    @IBAction func close(sender: AnyObject) {
        self.removeFromSuperview()
    }
    
    
}
