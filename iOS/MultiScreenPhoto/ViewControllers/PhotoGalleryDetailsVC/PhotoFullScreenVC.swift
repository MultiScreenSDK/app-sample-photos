//
//  PhotoFullScreenVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.

import UIKit

/// PhotoFullScreenVCDelegate
///
/// This delegate is used to know when the user tap the image
/// This will shows the hidden navigation bar
protocol PhotoFullScreenVCDelegate {
    func showNavigationBar()
    func updateCurrentIndex(Index: Int)
}

/// PhotoFullScreenVC
///
/// This class is used to show a full size photo, allows the panning option
class PhotoFullScreenVC: UIViewController,UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    
    // Gallery Instance, this instance contains an Array of albums
    var gallery = Gallery.sharedInstance
    
    // index of the current photo displayed
    var pageIndex : Int = 0
    
    // index of the current Album displayed
    var pageAlbumIndex : Int = 0
    
    var scrollView: UIScrollView!
    var image: UIImage!
    var imageView: UIImageView!
    
    var delegate: PhotoFullScreenVCDelegate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        /// Set the view background color
        view.backgroundColor = UIColor(red: 21/255, green: 21/255, blue: 21/255, alpha: 1)
        
        /// Request the current image at index, from the device photo album
        gallery.requestImageAtIndex(pageAlbumIndex,index: pageIndex, containerId: 0, isThumbnail: false, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!,assetIndex:Int, containerId: Int) -> Void in
            /// Add the Image to the scrollView
            self.image = image
            self.imageView.image = image
            self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:image.size)
            
            self.updateScrollView()
            
        })
        
        //self.automaticallyAdjustsScrollViewInsets = false;
        
        /// Configuring the ScrollView content size
        scrollView = UIScrollView(frame: view.frame)
        scrollView.delegate = self
        
        imageView = UIImageView()
        scrollView.addSubview(imageView)
        
        view.addSubview(scrollView)
        
        // Adding a tap recognizer to display the hidden navigation bar on tap
        var singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "showNavigationBar")
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        delegate.updateCurrentIndex(pageIndex)
        updateScrollView()
    }
    
    override func viewWillLayoutSubviews(){
        updateScrollView()
    }
    
    /// Method used to set the scrollView zooming scale and content size
    func updateScrollView(){
        
        if((image) != nil){
            /// Configuring the ScrollView content size
            scrollView.contentSize = image.size
        }
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        scrollView.frame =  view.frame
        
        centerScrollViewContents()
    }

    /// Method used to center the scrollView Image to the content frame
    func centerScrollViewContents() {
        var offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
        var offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
        
        imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
            scrollView.contentSize.height * 0.5 + offsetY);
    }
    
    /// Method used to show the hidden navigation bar
    func showNavigationBar(){
        delegate.showNavigationBar()
    }
    
    // MARK: - Scroll View delegates
    
    /// Delegate used to zoom the Image
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return imageView
    }
    /// Delegate used to center the Image when zooming
    func scrollViewDidZoom(scrollView: UIScrollView!) {
        centerScrollViewContents()
    }
    
    
    
}
