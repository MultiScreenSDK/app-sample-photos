//
//  CastMenuView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

let servicesFoundTVCellID = "ServicesFoundTVCell"

var multiScreenManager = MultiScreenManager.sharedInstance

class CastMenuView: UIView, UITableViewDelegate, UITableViewDataSource, ServicesFoundHeaderVIewDelegate {
    
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
        services = multiScreenManager.getServicesNotConnected()
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "closeView")
        //self.addGestureRecognizer(tap)
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
        
        return cell
        
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        if(multiScreenManager.isApplicationConnected() == true){
            return 180
        }else{
            return 55
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
    
    @IBAction func closeView() {
        self.removeFromSuperview()
    }
    
    
}
