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
}

/// PhotoFullScreenVC
///
/// This class is used to show a full size photo, allows the panning option
class PhotoFullScreenVC: UIViewController,UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    
    // Gallery Instance, this instance contains an Array of albums
    var gallery = Gallery.sharedInstance
    
    // UIPageViewController used to paginate photos
    var pageViewController : UIPageViewController?
    
    // index of the current photo displayed
    var pageIndex : Int = 0
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var delegate: PhotoFullScreenVCDelegate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        /// Set the view background color
        view.backgroundColor = UIColor(red: 21/255, green: 21/255, blue: 21/255, alpha: 1)
        
        /// Request the current image at index, from the device photo album
        gallery.requestImageAtIndex(gallery.currentAlbum,index: pageIndex, containerId: 0, isThumbnail: false, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!,assetIndex:Int, containerId: Int) -> Void in
            /// Add the Image to the scrollView
            self.addScrollView(image)
        })
        
        //self.automaticallyAdjustsScrollViewInsets = false;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        /// Shows the hidden navigation bar when the current view is loaded
        showNavigationBar()
    }
    
    /// Method used to add the Scrolling image programatically
    func addScrollView(image: UIImage){
        
        /// Configuring the ScrollView content size
        scrollView = UIScrollView(frame: view.frame)
        imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:image.size)
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        scrollView.contentSize = image.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        
        view.addSubview(scrollView)
        
        // Adding a tap recognizer to display the hidden navigation bar on tap
        var singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "showNavigationBar")
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
        /// Center the scrollView to the super view
        centerScrollViewContents()
    }

    /// Method used to center the scrollView Image to the content frame
    func centerScrollViewContents() {
        
        scrollView.frame =  view.frame
        
        let boundsSize = scrollView.bounds.size
        var imageFrame = imageView.frame
        if imageFrame.size.width < boundsSize.width {
          imageFrame.origin.x = (boundsSize.width - imageFrame.size.width) / 2.0
        } else {
            imageFrame.origin.x = 0.0
        }
        if imageFrame.size.height < boundsSize.height {
            imageFrame.origin.y = (boundsSize.height - imageFrame.size.height) / 2.0
        } else {
            imageFrame.origin.y = 0.0
        }
        
        imageView.frame = imageFrame
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
    
    // Delegate used to center the image to the scrollView when the device is rotated.
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        centerScrollViewContents()
    }
    
    
}
