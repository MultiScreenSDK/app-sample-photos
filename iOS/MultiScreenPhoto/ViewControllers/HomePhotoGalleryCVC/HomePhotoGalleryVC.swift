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
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        // Method to setup the navigation bar color and fonts
        setUpNavigationBar()
    }
    
     // Method to setup the navigation bar color and fonts
    func setUpNavigationBar(){
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Configuring title to left
        self.navigationItem.leftBarButtonItem = nil;
        
        // Setting the navigation Title to the left
        var TitleLabel: UIBarButtonItem = UIBarButtonItem(title: "Photos", style: .Plain, target: nil, action: nil)
        TitleLabel.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Roboto-Light", size: 20)!], forState: UIControlState.Normal)
        
        self.navigationItem.leftBarButtonItems = [TitleLabel]
        self.navigationController?.navigationBar.translucent = false
        
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
        var numRow = numOfRowsInSection(section)
        gallery.setNumOfAssetsByalbumToZero(section)
     
        var indexArray = [NSIndexPath]()
        for (var i=0;i < Int(numRow); i++) {
            var indexPath = NSIndexPath(forRow: i, inSection: section)
            indexArray.append(indexPath)
        }
        
        UIView.animateWithDuration(0.0, animations: { () -> Void in
            self.tableView!.beginUpdates()
            self.tableView!.deleteRowsAtIndexPaths(indexArray, withRowAnimation: UITableViewRowAnimation.None)
            self.tableView!.endUpdates()
        }) { (result) -> Void in
            self.tableView!.reloadData()
        }
        
    }
    
    // Animate the section to expand
    func expandSection(section : Int){
        
        gallery.setIsAlbumExpanded(section, isExpanded: true)
        gallery.setNumOfAssetsByAlbum(section)
        var numRow = numOfRowsInSection(section)
        
        var indexArray = [NSIndexPath]()
        for (var i=0;i < Int(numRow); i++) {
            var indexPath = NSIndexPath(forRow: i, inSection: section)
            indexArray.append(indexPath)
        }
        
        UIView.animateWithDuration(0.0, animations: { () -> Void in
            self.tableView!.beginUpdates()
            self.tableView!.insertRowsAtIndexPaths(indexArray, withRowAnimation: UITableViewRowAnimation.None)
            self.tableView!.endUpdates()
            }) { (result) -> Void in
                self.tableView!.reloadData()
        }
        
        
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        var viewArray = NSBundle.mainBundle().loadNibNamed("HomePhotoGalleryHeaderView", owner: self, options: nil)
        var headerView = viewArray[0] as HomePhotoGalleryHeaderView
        headerView.headerTitle.setTitle(gallery.getAlbumName(section), forState: UIControlState.Normal)
        headerView.delegate = self
        headerView.section = section
        headerView.state = gallery.getIsAlbumExpanded(section)
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
