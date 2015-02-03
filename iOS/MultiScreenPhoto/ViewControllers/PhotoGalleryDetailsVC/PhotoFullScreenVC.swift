//
//  PhotoFullScreenVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//  Copy from here :  http://www.raywenderlich.com/76436/use-uiscrollview-scroll-zoom-content-swift

import UIKit

class PhotoFullScreenVC: UIViewController,UIScrollViewDelegate {
    
    
    //Gallery Instance, this instance contains an Array of albums
    var gallery = Gallery.sharedInstance
    
    //UIPageViewController used to paginate photos
    var pageViewController : UIPageViewController?
    
    //index of the current photo displayed
    var pageIndex : Int = 0
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 21/255, green: 21/255, blue: 21/255, alpha: 1)
        
        gallery.requestImageAtIndex(gallery.currentAlbum,index: pageIndex, isThumbnail: false, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            self.addScrollView(image)
        })
    }
    

    func addScrollView(image: UIImage){
        scrollView = UIScrollView(frame: view.frame)
        // 1
        
        imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:image.size)
        scrollView.addSubview(imageView)
        
        // 2
        scrollView.delegate = self
        scrollView.contentSize = image.size
        
        
        
        // 3
        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        // 4
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        // 5
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        
        // 6
        view.addSubview(scrollView)
        
        centerScrollViewContents()
    }


    func centerScrollViewContents() {
        
        scrollView.frame =  view.frame
        
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.locationInView(imageView)
        
        // 2
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        // 3
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        // 4
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView!) {
        centerScrollViewContents()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        centerScrollViewContents()
    }
    
    
}
