//
//  HomePhotoGalleryCVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit


let reuseIdentifier = "HomePhotoGalleryCVCCell"
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
    
    // MARK: UICollectionViewDataSource
    
     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return gallery.getNumberOfAlbums()
    }
    
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.getNumberOfAssetsForAlbum(section)
    }
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : HomePhotoGalleryCVCCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as HomePhotoGalleryCVCCell
        
        // return the current image from the asset
        gallery.requestImageAtIndex(indexPath.section,index: indexPath.row, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            cell.imageView.image = image
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
