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

class CompatibleTVsView: UIView,UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate {
   
    @IBOutlet weak var contentTVView: UIView!
    @IBOutlet weak var selectedinche: UILabel!
    @IBOutlet weak var selectedincheButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var openSectionIndex = 0
    var sectionInchesExpanded = false
    var currentInches = NSNotFound
    
    var inchesArray = []
    var modelsArray = []
    
    var inchesDict: NSDictionary?
    var inchesCount: Int!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
         let tap = UITapGestureRecognizer()
         tap.addTarget(self, action: "closeView")
         tap.delegate = self
         self.addGestureRecognizer(tap)
        
        var frame = tableView.frame
        frame.size.height = CGFloat(cellCount * 44)
        tableView.frame = frame
        tableView.rowHeight = 25
        currentInches = NSNotFound
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return numOfRowsInSection(section);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell : UITableViewCell
        cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        if(indexPath.section == 0){
            var incheDict = inchesArray[indexPath.row] as NSDictionary
            let text = incheDict.objectForKey("name") as String
            cell.textLabel?.attributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:UIFont(name: "Roboto-Light", size: 14.0)!])
        }else{
           var incheDict: NSString  = modelsArray[indexPath.row] as NSString
            cell.textLabel?.attributedText = NSMutableAttributedString(string: incheDict, attributes: [NSFontAttributeName:UIFont(name: "Roboto-Light", size: 14.0)!])
        }
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.textAlignment = .Center
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(indexPath.section == 0){
            var inchestemparray = []
            if let path = NSBundle.mainBundle().pathForResource("CompatibleTvsList", ofType: "plist") {
                inchesDict = NSDictionary(contentsOfFile: path)
                inchestemparray = inchesDict?.objectForKey("inches") as NSArray
            }
            currentInches = indexPath.row
            var incheDict = inchestemparray[indexPath.row] as NSDictionary
            selectedincheButton.titleLabel?.text =  incheDict.objectForKey("name") as? String
            selectedincheButton.userInteractionEnabled = true
            expandSection(1, previousOpenSectionIndex: 0)
            sectionInchesExpanded = false
        }
    }
    
    func closeView() {
        self.removeFromSuperview()
    }
    
    @IBAction func selectedSize(sender: AnyObject) {
        if let path = NSBundle.mainBundle().pathForResource("CompatibleTvsList", ofType: "plist") {
            inchesDict = NSDictionary(contentsOfFile: path)
            inchesArray = inchesDict?.objectForKey("inches") as NSArray
        }
        sectionInchesExpanded = !sectionInchesExpanded
        selectedincheButton.userInteractionEnabled = false
        expandSection(0,previousOpenSectionIndex: 1)
    }
    
    func setNumberOfRowsInSection(section: Int)-> Int{
        if let path = NSBundle.mainBundle().pathForResource("CompatibleTvsList", ofType: "plist") {
            inchesDict = NSDictionary(contentsOfFile: path)
            inchesArray = inchesDict?.objectForKey("inches") as NSArray
        }
        return 0
    }
    
    func numOfRowsInSection(section: Int)-> Int{
        if(section == 0  && sectionInchesExpanded == true){
            return inchesArray.count
        }
        if(section == 1 && currentInches != NSNotFound){
            
            var modelInchesArray = []
            
            if let path = NSBundle.mainBundle().pathForResource("CompatibleTvsList", ofType: "plist") {
                inchesDict = NSDictionary(contentsOfFile: path)
                modelInchesArray = inchesDict?.objectForKey("inches") as NSArray
            }
            
            modelsArray = modelInchesArray[currentInches].objectForKey("models") as NSArray
            return modelsArray.count
        }
        return 0
    }
    
    
    // Animate the section to expand
    func expandSection(section : Int, previousOpenSectionIndex : Int){
        
        var countOfRowsToInsert: Int = numOfRowsInSection(section)
        var indexPathsToInsert = [NSIndexPath]()
        for (var i=0;i < Int(countOfRowsToInsert); i++) {
            indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: section))
        }
        
        var indexPathsToDelete = [NSIndexPath]()
        
        if (previousOpenSectionIndex != NSNotFound) {
            var countOfRowsToDelete: Int = numOfRowsInSection(previousOpenSectionIndex)
            for (var i=0;i < Int(countOfRowsToDelete); i++) {
                indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: previousOpenSectionIndex))
            }
        }
        
        // style the animation so that there's a smooth flow in either direction
        var insertAnimation : UITableViewRowAnimation
        var deleteAnimation :UITableViewRowAnimation
        if (previousOpenSectionIndex == NSNotFound || section < previousOpenSectionIndex) {
            insertAnimation = UITableViewRowAnimation.Top;
            deleteAnimation = UITableViewRowAnimation.Bottom;
        }
        else {
            insertAnimation = UITableViewRowAnimation.Bottom;
            deleteAnimation = UITableViewRowAnimation.Top
        }
        
        if(previousOpenSectionIndex == 0){
            inchesArray = []
        }else{
            currentInches = NSNotFound
        }
        
        
        // apply the updates
        self.tableView!.beginUpdates()
        self.tableView!.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: insertAnimation)
        self.tableView!.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: deleteAnimation)
        self.tableView!.endUpdates()
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        if (touch.view.tag == 1){
            return true
        }
        return false
    }
    
}
