//
//  HomePhotoGalleryVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// HomePhotoGalleryVC extend from CommonVC
///
/// This class is used to display the gallery in a UITableView
class HomePhotoGalleryVC: CommonVC, UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate, HomePhotoGalleryHeaderViewDelegate, HomePhotoGalleryVCCellDelegate {
    
    // UITableView to diplay the gallery photos
    @IBOutlet weak var tableView: UITableView!
    
    // Data source used to calculate the row to insert and delete
    var dataSourceAlbumCountToInsert = 0
    var dataSourceAlbumCountToRemove = 0
    
    // Identifiers for UITableview cells
    let reuseIdentifierTVCell1 = "HomePhotoGalleryVCCell1"
    let reuseIdentifierTVCell2 = "HomePhotoGalleryVCCell2"
    
    //Size of the cell
    var cellHeight: CGFloat!
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    // Used to calculate the size of the large photo depending of the screen size
    let screenSizeDivisor = CGFloat(2.03)
   
    //Gallery Instance, this instance contains an Array of albums
    private var gallery = Gallery.sharedInstance
    
    //Welcome view displayed the first time the app runs
    var welcomeView: UIView!
  
    // Used to determinate which section is opened
    var openSectionIndex = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Start searching for avaliables services in the network
        multiScreenManager.startSearching()
        
        // Request for photo library access and retrieving albums
        gallery.retrieveAlbums { (result:Bool!) -> Void in
            if(result == true){
                self.openSectionIndex = self.gallery.getIndexFromCurrentAlbumExpanded()
                self.dataSourceAlbumCountToRemove = self.numOfRowsInSection(self.openSectionIndex)
                self.tableView!.reloadData()
            }else{
                self.displayAlertWithTitle("Access",
                    message: "Could not access the photo library")
                self.openSectionIndex = NSNotFound
            }
        }
        // Calculate the cell size
        cellHeight = screenSize.size.width/screenSizeDivisor
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Display Welcome View only one time
        if(!defaults.boolForKey("hideWelcomeView")){
            
            /// UIView that contains the welcome view
            self.welcomeView = NSBundle.mainBundle().loadNibNamed("WelcomeView", owner: self, options: nil)[0] as? UIView
            self.welcomeView.frame = view.frame
            view.window?.addSubview(welcomeView)
            defaults.setBool(true, forKey: "hideWelcomeView")
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Method to setup the navigation bar color and fonts
        setUpNavigationBar()
    }
    
    
    // Method to setup the navigation bar color and fonts
    func setUpNavigationBar(){
       
        //set the Navigation Bar color
    self.navigationController?.navigationBar.setBackgroundImage(getImageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 100, height: 144)), forBarMetrics: UIBarMetrics.Default)
          self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Align the title to the left
        self.navigationItem.leftBarButtonItem = nil;
        var TitleLabel: UIBarButtonItem = UIBarButtonItem(title: "Photos", style: .Plain, target: nil, action: nil)
        TitleLabel.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Roboto-Light", size: 20)!], forState: UIControlState.Normal)
        
        self.navigationItem.leftBarButtonItems = [TitleLabel]
        
    }
    
    
    /// Method used to calculate the number of rows for a given section and number of assets for album
    func numOfRowsInSection(section: Int)-> Int{
        if(section == openSectionIndex && openSectionIndex != NSNotFound){
            var numRow = Double(gallery.getNumOfAssetsByAlbum(section)) / 5
            var numRowMod = gallery.getNumOfAssetsByAlbum(section) % 5
            if(numRow > 0){
                if(numRowMod != 0){
                    numRow = numRow + 1
                }
            }
            return Int(numRow)
        }
        return 0
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return gallery.getNumOfAlbums()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return numOfRowsInSection(section)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return cellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell : HomePhotoGalleryVCCell
        
        // Selecting the correct cell layout depending of the current index
        if(indexPath.row % 2 == 0){
            cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierTVCell1) as HomePhotoGalleryVCCell
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierTVCell2) as HomePhotoGalleryVCCell
        }
        // Used to know the section of the cell
        cell.section = indexPath.section
        
        cell.delegate = self
        cell.layer.zPosition = CGFloat(indexPath.row) * -1
        
        // Adding the photos to the cell
        var currentAssetIndex = indexPath.row * 5
        for (var i=0; i<5; i++) {
            
            /// Retrieve an image from the device photo gallery
            gallery.requestImageAtIndex(indexPath.section,index: currentAssetIndex, containerId:i, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!, assetIndex:Int, containerId: Int ) -> Void in
                // If there is no Image then disable the UIImageVIew
                if(image == nil){
                    cell.buttonPhoto[containerId].enabled = false
                }else{
                    cell.buttonPhoto[containerId].enabled = true
                }
                // Setting an UIImage to the UIImageView
                cell.buttonPhoto[containerId].setBackgroundImage(image, forState: UIControlState.Normal)
                cell.buttonPhoto[containerId].tag = assetIndex
            })
            currentAssetIndex = currentAssetIndex + 1
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        
        /// UIView that contains the header view for each cell
        var viewArray = NSBundle.mainBundle().loadNibNamed("HomePhotoGalleryHeaderView", owner: self, options: nil)
        var headerView = viewArray[0] as HomePhotoGalleryHeaderView
        
        // Adding the title to the header
        headerView.headerTitle.setTitle(gallery.getAlbumName(section), forState: UIControlState.Normal)
        headerView.delegate = self
        headerView.section = section
        // Set if header is expanded
        headerView.state = gallery.getIsAlbumExpanded(section)
        // Setting the Up and Down Arrow Icon
        headerView.setArrowIcon()
        
        return headerView
    }
    
    /// Method used to update the Arrow icon for each Header
    func updateHeaderView(section : Int){
        var headerView: HomePhotoGalleryHeaderView = tableView!.headerViewForSection(section) as HomePhotoGalleryHeaderView
        headerView.state = gallery.getIsAlbumExpanded(section)
        headerView.setArrowIcon()
    }
    
    // Method called from header delegate to collapse o expand the row
    func headerClicked(section : Int){
        if(gallery.getIsAlbumExpanded(section)){
            collapseSection(section)
        }else{
            expandSection(section)
        }
       
    }
    
    // Animate the section to collapse
    func collapseSection(section : Int){
        
        openSectionIndex = NSNotFound;
        var indexPathsToDelete = [NSIndexPath]()
        for (var i=0;i < dataSourceAlbumCountToRemove; i++) {
            indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: section))
        }
        tableView!.beginUpdates()
        tableView!.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.Top)
        tableView!.endUpdates()
        
        gallery.setIsAlbumExpanded(section, isExpanded: false)
        dataSourceAlbumCountToRemove = 0
        updateHeaderView(section)
        
    }
    
    // Animate the section to expand
    func expandSection(section : Int){
        
        var previousOpenSectionIndex = openSectionIndex;
        
        /*
        Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the current section.
        */
        var indexPathsToDelete = [NSIndexPath]()
        if (previousOpenSectionIndex != NSNotFound) {
            gallery.setIsAlbumExpanded(previousOpenSectionIndex, isExpanded: false)
            updateHeaderView(previousOpenSectionIndex)
            for (var i=0;i < dataSourceAlbumCountToRemove; i++) {
                indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: previousOpenSectionIndex))
            }
        }
        
        openSectionIndex = section;
        dataSourceAlbumCountToInsert = Int(self.numOfRowsInSection(section))
        dataSourceAlbumCountToRemove = dataSourceAlbumCountToInsert
        
        /*
        Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
        */
         gallery.setIsAlbumExpanded(section, isExpanded: true)
        var indexPathsToInsert = [NSIndexPath]()
        updateHeaderView(section)
        for (var i=0;i < dataSourceAlbumCountToInsert; i++) {
            indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: section))
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
        tableView!.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.None)
        tableView!.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: insertAnimation)
        tableView!.endUpdates()
        
    }
    
    /// HomePhotoGalleryVCCell Delegate method
    func photoSelected(indexPath : NSIndexPath){
        
         /// UIViewController that shows a detailed photo
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoFullScreenPagerVCID") as PhotoFullScreenPagerVC
        // Setting the current Image Index
        viewController.currentIndex = indexPath.row
        gallery.currentAlbum = indexPath.section
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// Used to calculate the cell Size, depending of the orientation
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            cellHeight = screenSize.size.height/screenSizeDivisor
        } else {
            cellHeight = screenSize.size.width/screenSizeDivisor
        }
        tableView.reloadData()
    }
  
    
}
