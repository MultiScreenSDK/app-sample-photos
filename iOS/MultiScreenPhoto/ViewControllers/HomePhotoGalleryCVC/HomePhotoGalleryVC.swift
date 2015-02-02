//
//  HomePhotoGalleryVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

// Identifiers for UITableview cell and Header
let reuseIdentifierTVCell1 = "CustomTableViewCell1"
let reuseIdentifierTVCell2 = "CustomTableViewCell2"
let reuseIdentifierTVHeader = "reuseIdentifierTVHeader"

let screenSizeDivisor = CGFloat(2.03)

//Gallery Instance, this instance contains an Array of albums
private var gallery = Gallery.sharedInstance

//UIViewController to display a gallery of photos
class HomePhotoGalleryVC: CommonVC, UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate, CustomHeaderCellDelegate, CustomTableViewCellDelegate {
    
    //Welcome view displayed the first time the app runs
    var welcomeView: UIView!
    
    //Size of the cell
    var cellHeight: CGFloat!
    
    @IBOutlet weak var tableView: UITableView!
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Method to setup the navigation bar color and fonts
        setUpNavigationBar()
        
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
    
     // Method to setup the navigation bar color and fonts
    func setUpNavigationBar(){
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Configuring title to left
        self.navigationItem.leftBarButtonItem = nil;
        
        // Setting the navigation Title to the left
        var titleLabel = UILabel(frame: CGRectMake(0,0,100,50))
        titleLabel.textAlignment = .Left
        titleLabel.text =  "Photos"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "Roboto-Light", size: 20)
        
        var TitleLabel: UIBarButtonItem = UIBarButtonItem(title: "Photos", style: .Plain, target: nil, action: nil)
        
        TitleLabel.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Roboto-Light", size: 20)!], forState: UIControlState.Normal)
        self.navigationItem.leftBarButtonItems = [TitleLabel]
        
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
        
        var cell : CustomTableViewCell
        var modIndexRow = indexPath.row % 10
        var currentImageIndex = 0
        
        if(indexPath.row % 2 == 0){
        cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierTVCell1) as CustomTableViewCell
            
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierTVCell2) as CustomTableViewCell
        }
        
        cell.delegate = self
        cell.section = indexPath.section
        cell.layer.zPosition = 0

        
        currentImageIndex = indexPath.row * 5
        gallery.requestImageAtIndex(indexPath.section,index: currentImageIndex, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            if(image == nil){
                cell.buttonPhoto0.enabled = false
            }else{
                cell.buttonPhoto0.enabled = true
            }
            cell.buttonPhoto0.setBackgroundImage(image, forState: UIControlState.Normal)
            cell.buttonPhoto0.tag = currentImageIndex
        })
        
        gallery.requestImageAtIndex(indexPath.section,index: currentImageIndex + 1, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            if(image == nil){
                cell.buttonPhoto1.enabled = false
            }else{
                cell.buttonPhoto1.enabled = true
            }
            cell.buttonPhoto1.setBackgroundImage(image, forState: UIControlState.Normal);
            cell.buttonPhoto1.tag = currentImageIndex + 1
        })
        
        gallery.requestImageAtIndex(indexPath.section,index: currentImageIndex + 2, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            if(image == nil){
                cell.buttonPhoto2.enabled = false
            }else{
                cell.buttonPhoto2.enabled = true
            }
            cell.buttonPhoto2.setBackgroundImage(image, forState: UIControlState.Normal)
            cell.buttonPhoto2.tag = currentImageIndex + 2
        })
        
        gallery.requestImageAtIndex(indexPath.section,index: currentImageIndex + 3, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            if(image == nil){
                cell.buttonPhoto3.enabled = false
            }else{
                cell.buttonPhoto3.enabled = true
            }
            cell.buttonPhoto3.setBackgroundImage(image, forState: UIControlState.Normal)
            cell.buttonPhoto3.tag = currentImageIndex + 3
        })
        
        gallery.requestImageAtIndex(indexPath.section,index: currentImageIndex + 4, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            if(image == nil){
                cell.buttonPhoto4.enabled = false
            }else{
                cell.buttonPhoto4.enabled = true
            }
            cell.buttonPhoto4.setBackgroundImage(image, forState: UIControlState.Normal)
            cell.buttonPhoto4.tag = currentImageIndex + 4
        })

        
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
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierTVHeader) as CustomHeaderCell
        
        headerCell.title.setTitle(gallery.getAlbumName(section), forState: UIControlState.Normal)
        
        return headerCell
    }
    
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        var header : CustomHeaderCell  =  view as CustomHeaderCell
        header.delegate = self
        header.section = section
        //header.title.setTitle(gallery.getAlbumName(section), forState: UIControlState.Normal)
        header.state = gallery.getIsAlbumExpanded(section)
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
    }
    
    func photoSelected(indexPath : NSIndexPath){
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoGalleryDetailsVCID") as PhotoGalleryDetailsVC
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
