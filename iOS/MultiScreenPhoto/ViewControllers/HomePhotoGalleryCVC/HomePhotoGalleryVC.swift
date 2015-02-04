//
//  HomePhotoGalleryVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

// Identifiers for UITableview cell and Header
let reuseIdentifierTVCell1 = "HomePhotoGalleryVCCell1"
let reuseIdentifierTVCell2 = "HomePhotoGalleryVCCell2"

let screenSizeDivisor = CGFloat(2.03)

//Gallery Instance, this instance contains an Array of albums
private var gallery = Gallery.sharedInstance

//UIViewController to display a gallery of photos
class HomePhotoGalleryVC: CommonVC, UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate, HomePhotoGalleryHeaderViewDelegate, HomePhotoGalleryVCCellDelegate {
    
    //Welcome view displayed the first time the app runs
    var welcomeView: UIView!
    
    //Size of the cell
    var cellHeight: CGFloat!
    
    @IBOutlet weak var tableView: UITableView!
    var openSectionIndex = 0
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        //Start searching for avaliables services in the network
        multiScreenManager.startSearching()
        
        //tableView.estimatedRowHeight = screenSize.size.width/2;
        //tableView.rowHeight = UITableViewAutomaticDimension;
        
        // Request for photo library access and retrieving albums
        gallery.retrieveAlbums { (result:Bool!) -> Void in
            if(result == true){
                self.tableView!.reloadData()
            }else{
                self.displayAlertWithTitle("Access",
                    message: "Could not access the photo library")
            }
        }
        
        // Calculate the cell size
        cellHeight = screenSize.size.width/screenSizeDivisor
        
        openSectionIndex = NSNotFound
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        // Method to setup the navigation bar color and fonts
        setUpNavigationBar()
    }
    
     // Method to setup the navigation bar color and fonts
    func setUpNavigationBar(){
        
        /*
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 21.0/255.0, green: 21.0/255.0, blue: 21.0/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.opaque = true
        */
        //Translucent Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(getImageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 100, height: 144)), forBarMetrics: UIBarMetrics.Default)
          self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Configuring title to left
        self.navigationItem.leftBarButtonItem = nil;
        
        // Setting the navigation Title to the left
        var TitleLabel: UIBarButtonItem = UIBarButtonItem(title: "Photos", style: .Plain, target: nil, action: nil)
        TitleLabel.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Roboto-Light", size: 20)!], forState: UIControlState.Normal)
        
        self.navigationItem.leftBarButtonItems = [TitleLabel]
        //self.navigationController?.navigationBar.translucent = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Display Welcome View
        if(!defaults.boolForKey("hideWelcomeView")){
            
            self.welcomeView = NSBundle.mainBundle().loadNibNamed("WelcomeView", owner: self, options: nil)[0] as? UIView
            self.welcomeView.frame = view.frame
            view.window?.addSubview(welcomeView)
            
            defaults.setBool(true, forKey: "hideWelcomeView")
            
        }
    }
    
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
        var modIndexRow = indexPath.row % 10
        var currentAssetIndex = 0
        
        if(indexPath.row % 2 == 0){
        cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierTVCell1) as HomePhotoGalleryVCCell
            
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierTVCell2) as HomePhotoGalleryVCCell
        }
        
        cell.delegate = self
        cell.section = indexPath.section
        cell.layer.zPosition = 0

        currentAssetIndex = indexPath.row * 5
        for (var i=0; i<5; i++) {
            gallery.requestImageAtIndex(indexPath.section,index: currentAssetIndex, containerId:i, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!, assetIndex:Int, containerId: Int ) -> Void in
                if(image == nil){
                    cell.buttonPhoto[containerId].enabled = false
                }else{
                    cell.buttonPhoto[containerId].enabled = true
                }
                cell.buttonPhoto[containerId].setBackgroundImage(image, forState: UIControlState.Normal)
                cell.buttonPhoto[containerId].tag = assetIndex
            })
            currentAssetIndex = currentAssetIndex + 1
        }
        
        return cell
    }
    
    
    // Animate the section to collapse
    func collapseSection(section : Int){
        
        gallery.setIsAlbumExpanded(section, isExpanded: false)
      
        var countOfRowsToDelete: Int = numOfRowsInSection(section)
        var indexPathsToDelete = [NSIndexPath]()
        for (var i=0;i < Int(countOfRowsToDelete); i++) {
            indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: section))
        }
        gallery.setNumOfAssetsByalbumToZero(section)
        self.tableView!.beginUpdates()
        self.tableView!.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.Top)
        self.tableView!.endUpdates()
        
        self.openSectionIndex = NSNotFound;
        
    }
    
    // Animate the section to expand
    func expandSection(section : Int){
        
        
        gallery.setIsAlbumExpanded(section, isExpanded: true)
        gallery.setNumOfAssetsByAlbum(section)
        /*
        Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
        */
        var countOfRowsToInsert: Int = numOfRowsInSection(section)
        var indexPathsToInsert = [NSIndexPath]()
        for (var i=0;i < Int(countOfRowsToInsert); i++) {
            indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: section))
        }
        
        var indexPathsToDelete = [NSIndexPath]()

        var previousOpenSectionIndex = openSectionIndex;
       
        
        if (previousOpenSectionIndex != NSNotFound) {
            gallery.setIsAlbumExpanded(previousOpenSectionIndex, isExpanded: false)
           // var sectionHeader = HomePhotoGalleryHeaderView   setArrowIcon//[previousOpenSection.headerView toggleOpenWithUserAction:NO];
            var countOfRowsToDelete: Int = numOfRowsInSection(previousOpenSectionIndex)
            for (var i=0;i < Int(countOfRowsToDelete); i++) {
                indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: previousOpenSectionIndex))
            }
            gallery.setNumOfAssetsByalbumToZero(previousOpenSectionIndex)
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
        self.tableView!.beginUpdates()
        self.tableView!.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: insertAnimation)
        self.tableView!.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: deleteAnimation)
        self.tableView!.endUpdates()
        
        self.openSectionIndex = section;
        
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        var viewArray = NSBundle.mainBundle().loadNibNamed("HomePhotoGalleryHeaderView", owner: self, options: nil)
        var headerView = viewArray[0] as HomePhotoGalleryHeaderView
        headerView.headerTitle.setTitle(gallery.getAlbumName(section), forState: UIControlState.Normal)
        headerView.delegate = self
        headerView.section = section
        headerView.state = gallery.getIsAlbumExpanded(section)
        headerView.setArrowIcon()
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
    }
    
    func photoSelected(indexPath : NSIndexPath){
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoFullScreenPagerVCID") as PhotoFullScreenPagerVC
        viewController.currentIndex = indexPath.row
        gallery.currentAlbum = indexPath.section
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func numOfRowsInSection(section: Int)-> Int{
        var numRow = Double(gallery.getNumOfAssetsByAlbum(section)) / 5
        if(numRow > 0){
            numRow = numRow + 1
        }
        return Int(numRow)
    }
    
    
    
    // Used to calculate the cell Size, depending of the orientation
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            cellHeight = screenSize.size.height/screenSizeDivisor
        } else {
            cellHeight = screenSize.size.width/screenSizeDivisor
        }
        tableView.reloadData()
    }
  
    
}
