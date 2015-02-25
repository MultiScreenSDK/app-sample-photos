//
//  CompatibleListView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 30/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// CompatibleListView
///
/// This class is used to display a list of compatible devices
class CompatibleListView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
   
    
    // UITableView to diplay the gallery photos
    @IBOutlet weak var tableView: UITableView!
    
    // Data source used to calculate the row to insert and delete
    var dataSourceCountToInsert = 0
    var dataSourceCountToRemove = 0
    
    // Used to determinate which section is expanded
    var expandedSectionIndex = NSNotFound
    
    /// Arrow image that changes depending of the section state (collapsed or expanded)
    @IBOutlet weak var imageViewArrow: UIImageView!
    
    /// UIButton that contains the name of the selected inches
    @IBOutlet weak var selectedInchesTitle: UIButton!
    
    var inchesArray = []
    var modelsArray = []
    var isInchesSectionExpanded = false
    
    /// Identifier for UITableview cell
    let compatibleTVCell = "CompatibleTVCellID"
    override func awakeFromNib(){
        super.awakeFromNib()
        
        
        /// Configuring the tableView cell and separator style
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: compatibleTVCell)
        
        /// Configuring the tableView separator style
        if tableView.respondsToSelector("setSeparatorInset:") {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector("setLayoutMargins:") {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        tableView.layoutIfNeeded()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        /// populating the inches from a Plist file
        if let path = NSBundle.mainBundle().pathForResource("CompatibleList", ofType: "plist") {
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
        return numberOfRowsInSection(section);
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.section == 0){
            return 44
        }else{
            return 27
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var text: String
        
        /// Setting the custom cell view
        var cell: UITableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier(compatibleTVCell, forIndexPath: indexPath) as UITableViewCell
        
        if(indexPath.section == 0){
            var incheDict = inchesArray[indexPath.row] as NSDictionary
            text = incheDict.objectForKey("name") as String
            
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
            
        }else{
            text = modelsArray[indexPath.row] as String
            
            // Set tableView separator style
            tableView.separatorStyle  = UITableViewCellSeparatorStyle.None
            /// Adding color to the cell on click
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        /// Adding the text for each cell
        cell.textLabel?.textColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        cell.textLabel?.textAlignment = .Left
        cell.textLabel?.attributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont(name: "Roboto-Light", size: 12.0)!])
        cell.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(indexPath.section == 0){
            
            ///  If an inches is selected then populate the modelsArray for the given inche
            var selectedInches = inchesArray[indexPath.row] as NSDictionary
            modelsArray = selectedInches.objectForKey("models") as NSArray
            expandSection(1)
            isInchesSectionExpanded = false
            
            imageViewArrow.image = UIImage(named: "icon_arrow_down")!
            /// Change the title of the selectedInchesTitle
            selectedInchesTitle.titleLabel?.text =  selectedInches.objectForKey("name") as? String
            
        }
    }
    
    /// Method used to capture the event when the selectedInchesTitle button is clicked
    /// If it was clicked then expand or collapse the tableView
    @IBAction func dropDownButtonSelected(sender: UIButton) {
        
        if(isInchesSectionExpanded){
            collapseSection(0)
            isInchesSectionExpanded = false
            imageViewArrow.image = UIImage(named: "icon_arrow_down")!
        }else{
            expandSection(0)
            isInchesSectionExpanded = true
            imageViewArrow.image = UIImage(named: "icon_arrow_up")!
        }
        
    }
    
    
    /// Method used to calculate the number of rows for a given section
    func numberOfRowsInSection(section: Int) -> Int{
        if(section == expandedSectionIndex && expandedSectionIndex != NSNotFound){
            if (section == 0){
                return inchesArray.count
            }else{
                return modelsArray.count
            }
        }
        return 0
    }
    
    // Animate the section to collapse
    func collapseSection(section: Int){
        
        expandedSectionIndex = NSNotFound
        
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
    func expandSection(section: Int){
        
        var previousExpandedSectionIndex = expandedSectionIndex;
        
        /*
        Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the current section.
        */
        var indexPathsToDelete = [NSIndexPath]()
        if (previousExpandedSectionIndex != NSNotFound) {
            for (var i=0;i < dataSourceCountToRemove; i++) {
                indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: previousExpandedSectionIndex))
            }
        }
        
        expandedSectionIndex = section;
        dataSourceCountToInsert = self.numberOfRowsInSection(section)
        dataSourceCountToRemove = dataSourceCountToInsert
        
        /*
        Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
        */
        var indexPathsToInsert = [NSIndexPath]()
        for (var i=0;i < dataSourceCountToInsert; i++) {
            indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: expandedSectionIndex))
        }
        
        // style the animation so that there's a smooth flow in either direction
        var insertAnimation: UITableViewRowAnimation
        var deleteAnimation: UITableViewRowAnimation
        if (previousExpandedSectionIndex == NSNotFound || section < previousExpandedSectionIndex) {
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
        if (touch.view.tag == 1){
            return true
        }
        return false
    }
    
}
