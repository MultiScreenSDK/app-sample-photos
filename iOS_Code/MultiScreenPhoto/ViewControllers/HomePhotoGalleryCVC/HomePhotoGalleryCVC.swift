//
//  HomePhotoGalleryCVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import AssetsLibrary

let reuseIdentifierMin = "HomePhotoGalleryCVCCellMin"
let reuseIdentifierMax = "HomePhotoGalleryCVCCellMax"
let reuseIdentifierHeader = "HomePhotoGalleryCVCHeader"


//Gallery Instance, this instance contains an Array of albums
private var gallery = Gallery.sharedInstance


class HomePhotoGalleryCVC: CommonVC, UICollectionViewDataSource, UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate {
    
    //Welcome view displayed the first time the app runs
    var welcomeView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvIntegration.start()
        
        // Requesting photo library access and retrieving albums
        gallery.retrieveAlbums { (result:Bool!) -> Void in
            if(result == true){
                self.collectionView!.reloadData()
            }else{
                self.displayAlertWithTitle("Access",
                    message: "I could not access the photo library")
            }
        }
        
        
        let flow:MyFlowLayout = self.collectionView!.collectionViewLayout as MyFlowLayout
        //self.setUpFlowLayout(flow)
    }
    
    
    
    /*
    func setUpFlowLayout(flow:UICollectionViewFlowLayout) {
        flow.headerReferenceSize = CGSizeMake(50,50) // larger - we will place label within this
        flow.sectionInset = UIEdgeInsetsMake(0, 2, 2, 0) // looks nicer
        // uncomment to crash
        // flow.estimatedItemSize = CGSizeMake(100,30)
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
 /*
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, blockSizeForItemAtIndexPath: NSIndexPath) -> CGSize{
   */
        var widthLarge = CGFloat(186)
        var widthSmall = CGFloat(93)
        
        switch (indexPath.row % 10) {
        case 0:  return CGSizeMake(widthLarge,widthLarge);
        case 1:  return CGSizeMake(widthSmall,widthSmall);
        case 2:  return CGSizeMake(widthSmall,widthSmall);
        case 3:  return CGSizeMake(widthSmall,widthSmall);
        case 4:  return CGSizeMake(widthSmall,widthSmall);
        case 5:  return CGSizeMake(widthSmall,widthSmall);
        case 6:  return CGSizeMake(widthSmall,widthSmall);
        case 7:  return CGSizeMake(widthLarge,widthLarge);
        case 8:  return CGSizeMake(widthSmall,widthSmall);
        case 9:  return CGSizeMake(widthSmall,widthSmall);
        default: return CGSizeMake(widthSmall,widthSmall);

        }

    }
    */

    
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
    
    deinit {
       // NSNotificationCenter.defaultCenter().removeObserver(self, name: ALAssetsLibraryChangedNotification, object: nil)
    }
    
    // MARK: UICollectionViewDataSource
    
     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return gallery.getNumberOfAlbums()
    }
    
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.getNumberOfAssetsForAlbum(section)
    }
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell : HomePhotoGalleryCVCCell
        
        var modIndexRow = indexPath.row % 10
        /*
        if(modIndexRow == 0 || modIndexRow == 7){
             cell  = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierMax, forIndexPath: indexPath) as HomePhotoGalleryCVCCell
            
        }else{
*/
             cell  = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierMin, forIndexPath: indexPath) as HomePhotoGalleryCVCCell
            
  //      }
        
        // return the current image from the asset
        gallery.requestImageAtIndex(indexPath.section,index: indexPath.row, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            cell.imageView.image = image
            //cell.clipsToBounds = true
            //cell.backgroundColor = UIColor(patternImage: image)
            
            
        })
        return cell
    }
    
    
    // Header for each Album
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var homePhotoGalleryHeaderCRV : UICollectionReusableView! = nil
        
        if kind == UICollectionElementKindSectionHeader {
            homePhotoGalleryHeaderCRV = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier:reuseIdentifierHeader, forIndexPath:indexPath) as UICollectionReusableView
            if homePhotoGalleryHeaderCRV.subviews.count == 0 {
                homePhotoGalleryHeaderCRV.addSubview(UILabel(frame:CGRectMake(0,0,30,30)))
            }
            let lab = homePhotoGalleryHeaderCRV.subviews[0] as UILabel
            lab.text = gallery.getAlbumName(indexPath.section)
            lab.textAlignment = .Left
        }
        return homePhotoGalleryHeaderCRV
    }
    
    /*
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
    
    }
    */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "photoGalleryDetailsVCSegue"){
            let viewController:PhotoGalleryDetailsVC = segue.destinationViewController as PhotoGalleryDetailsVC
            let cell = sender as UICollectionViewCell
            let indexPath :NSIndexPath = self.collectionView!.indexPathForCell(cell)!
            viewController.currentIndex = indexPath.row
            gallery.currentAlbum = indexPath.section
        }else if(segue.identifier == "ServicesFoundSegue"){
          
        }
    }
  
    
}
