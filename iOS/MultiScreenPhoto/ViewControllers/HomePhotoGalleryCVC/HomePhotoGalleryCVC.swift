//
//  HomePhotoGalleryCVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

let reuseIdentifierTVCell1 = "CustomTableViewCell1"
let reuseIdentifierTVCell2 = "CustomTableViewCell2"
let reuseIdentifierTVHeader = "reuseIdentifierTVHeader"

//Gallery Instance, this instance contains an Array of albums
private var gallery = Gallery.sharedInstance


class HomePhotoGalleryCVC: CommonVC, UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate, CustomHeaderCellDelegate, CustomTableViewCellDelegate {
    
    //Welcome view displayed the first time the app runs
    var welcomeView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        // Setting the navigation Title to the left
        var titleLabel = UILabel(frame: CGRectMake(0,41,320,50))
        titleLabel.textAlignment = .Left
        titleLabel.text =  "Photos"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "Roboto-Light", size: 25)
        self.navigationItem.titleView = titleLabel
        //self.navigationItem.leftBarButtonItem?.title = "Photos"
        
        
        multiScreenManager.start()
        
        //tableView.estimatedRowHeight = screenSize.size.width/2;
        //tableView.rowHeight = UITableViewAutomaticDimension;
        
        // Requesting photo library access and retrieving albums
        gallery.retrieveAlbums { (result:Bool!) -> Void in
            if(result == true){
                self.tableView!.reloadData()
            }else{
                self.displayAlertWithTitle("Access",
                    message: "I could not access the photo library")
            }
        }
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
        return 50.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return numOfRowsInSection(section)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return screenSize.size.width/2
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
                cell.imageView0.enabled = false
            }else{
                cell.imageView0.enabled = true
            }
            cell.imageView0.setBackgroundImage(image, forState: UIControlState.Normal)
            cell.imageView0.tag = currentImageIndex
        })
        
        gallery.requestImageAtIndex(indexPath.section,index: currentImageIndex + 1, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            if(image == nil){
                cell.imageView1.enabled = false
            }else{
                cell.imageView1.enabled = true
            }
            cell.imageView1.setBackgroundImage(image, forState: UIControlState.Normal);
            cell.imageView1.tag = currentImageIndex + 1
        })
        
        gallery.requestImageAtIndex(indexPath.section,index: currentImageIndex + 2, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            if(image == nil){
                cell.imageView2.enabled = false
            }else{
                cell.imageView2.enabled = true
            }
            cell.imageView2.setBackgroundImage(image, forState: UIControlState.Normal)
            cell.imageView2.tag = currentImageIndex + 2
        })
        
        gallery.requestImageAtIndex(indexPath.section,index: currentImageIndex + 3, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            if(image == nil){
                cell.imageView3.enabled = false
            }else{
                cell.imageView3.enabled = true
            }
            cell.imageView3.setBackgroundImage(image, forState: UIControlState.Normal)
            cell.imageView3.tag = currentImageIndex + 3
        })
        
        gallery.requestImageAtIndex(indexPath.section,index: currentImageIndex + 4, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            if(image == nil){
                cell.imageView4.enabled = false
            }else{
                cell.imageView4.enabled = true
            }
            cell.imageView4.setBackgroundImage(image, forState: UIControlState.Normal)
            cell.imageView4.tag = currentImageIndex + 4
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
  
    
}
