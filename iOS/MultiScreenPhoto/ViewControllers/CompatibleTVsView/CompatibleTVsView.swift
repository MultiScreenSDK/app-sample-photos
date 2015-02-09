//
//  CompatibleTVsView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 30/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// CompatibleTVsView
///
/// This class is used to display a list of compatible devices
class CompatibleTVsView: UIView,UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate {
   
    
    // UITableView to diplay the gallery photos
    @IBOutlet weak var tableView: UITableView!
    
    // Data source used to calculate the row to insert and delete
    var dataSourceCountToInsert = 0
    var dataSourceCountToRemove = 0
    
    // Used to determinate which section is opened
    var openSectionIndex = NSNotFound
    
    /// Arrow image that changes depending of the section state (collapsed, or expanded)
    @IBOutlet weak var imageViewArrow: UIImageView!
    
    /// UIButton that contains the name of the selected inches
    @IBOutlet weak var selectedInchesTitle: UIButton!
    
    var inchesArray = []
    var modelsArray = []
    var isExpandedInchesSection = false
    
    /// Identifier for UITableview cell
    let compatibleTVCell = "CompatibleTVCellID"
    override func awakeFromNib(){
        super.awakeFromNib()
        
        
        /// Configuring the tableView cell
        tableView.registerNib(UINib(nibName: "CompatibleTVCell", bundle: nil), forCellReuseIdentifier: compatibleTVCell)
        
        /// populating the inches from a Plist file
        if let path = NSBundle.mainBundle().pathForResource("CompatibleTvsList", ofType: "plist") {
            var inchesDict = NSDictionary(contentsOfFile: path)
            inchesArray = inchesDict?.objectForKey("inches") as NSArray
        }
        
        /// Add a gesture recognizer to dismiss the current view on tap
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "closeView")
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return numOfRowsInSection(section);
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.section == 0){
            return 42
        }else{
            return 27
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var text: String
        
        /// Setting the custom cell view
        var cell : CompatibleTVCell
        cell = tableView.dequeueReusableCellWithIdentifier(compatibleTVCell, forIndexPath: indexPath) as CompatibleTVCell
        
        if(indexPath.section == 0){
            var incheDict = inchesArray[indexPath.row] as NSDictionary
            text = incheDict.objectForKey("name") as String
            cell.imageSeparator.hidden = false
        }else{
            text = modelsArray[indexPath.row] as String
            cell.imageSeparator.hidden = true
        }
        
        cell.title.textColor = UIColor.whiteColor()
        cell.title.textAlignment = .Left
        cell.title.text = text
        //cell.title.attributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:UIFont(name: "Roboto-Light", size: 12.0)!])
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(indexPath.section == 0){
            
            ///  If an inches is selected then populate the modelsArray for the given inche
            var selectedInches = inchesArray[indexPath.row] as NSDictionary
            modelsArray = selectedInches.objectForKey("models") as NSArray
            expandSection(1)
            isExpandedInchesSection = false
            
            imageViewArrow.image = UIImage(named: "icon_arrow_down")!
            /// Change the title of the selectedInchesTitle
            selectedInchesTitle.titleLabel?.text =  selectedInches.objectForKey("name") as? String
            
        }
    }
    
    /// Method used to capture the event when the selectedInchesTitle button is clicked
    /// If it was clicked then expand or collapse the tableView
    @IBAction func dropDownButtonSelected(sender: UIButton) {
        
        if(isExpandedInchesSection){
            collapseSection(0)
            isExpandedInchesSection = false
            imageViewArrow.image = UIImage(named: "icon_arrow_down")!
        }else{
            expandSection(0)
            isExpandedInchesSection = true
            imageViewArrow.image = UIImage(named: "icon_arrow_up")!
        }
        
    }
    
    
    /// Method used to calculate the number of rows for a given section
    func numOfRowsInSection(section: Int)-> Int{
        if(section == openSectionIndex && openSectionIndex != NSNotFound){
            if (section == 0){
                return inchesArray.count
            }else{
                return modelsArray.count
            }
        }
        return 0
    }
    
    // Animate the section to collapse
    func collapseSection(section : Int){
        
        openSectionIndex = NSNotFound
        
        var indexPathsToDelete = [NSIndexPath]()
        for (var i=0;i < dataSourceCountToRemove; i++) {
            indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: section))
        }
        tableView!.beginUpdates()
        tableView!.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.Top)
        tableView!.endUpdates()
        
        dataSourceCountToRemove = 0
        
    }
    
    // Animate the section to expand
    func expandSection(section : Int){
        
        var previousOpenSectionIndex = openSectionIndex;
        
        /*
        Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the current section.
        */
        var indexPathsToDelete = [NSIndexPath]()
        if (previousOpenSectionIndex != NSNotFound) {
            //gallery.setIsAlbumExpanded(previousOpenSectionIndex, isExpanded: false)
            //updateHeaderView(previousOpenSectionIndex)
            for (var i=0;i < dataSourceCountToRemove; i++) {
                indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: previousOpenSectionIndex))
            }
        }
        
        openSectionIndex = section;
        dataSourceCountToInsert = self.numOfRowsInSection(section)
        dataSourceCountToRemove = dataSourceCountToInsert
        
        /*
        Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
        */
        var indexPathsToInsert = [NSIndexPath]()
        for (var i=0;i < dataSourceCountToInsert; i++) {
            indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: openSectionIndex))
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
        
        // apply the updates
        tableView!.beginUpdates()
        tableView!.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: deleteAnimation)
        tableView!.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: insertAnimation)
        tableView!.endUpdates()
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
