//
//  CompatibleTVsView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 30/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

//let compatibleDeviceTVCellID = "compatibleDeviceTVCell"

var cellCount = 100

class CompatibleTVsView: UIView,UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var contentTVView: UIView!

    @IBOutlet weak var tableView: UITableView!
   
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
         let tap = UITapGestureRecognizer()
         tap.addTarget(self, action: "closeView")
         //self.addGestureRecognizer(tap)
        
        var frame = tableView.frame
        frame.size.height = CGFloat(cellCount * 44)
        tableView.frame = frame
        
  
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 5;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell : UITableViewCell
        cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        cell.textLabel?.text =  "DEMO"
        return cell
        
    }
    
    @IBAction func closeView() {
        self.removeFromSuperview()
    }
    
    @IBAction func selectedSize(sender: AnyObject) {
        
    }
    
}
