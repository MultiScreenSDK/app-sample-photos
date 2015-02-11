//
//  PhotoFullScreenVC.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 2/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

class PhotoFullScreenVC2: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage!
    
    //Gallery Instance, this instance contains an Array of albums
    var gallery = Gallery.sharedInstance
    
    //UIPageViewController used to paginate photos
    var pageViewController : UIPageViewController?
    
    //index of the current photo displayed
    var pageIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale=0.5;
        scrollView.maximumZoomScale=6;
        scrollView.zoomScale = 0.1
        scrollView.delegate=self;
        scrollView.bounces = false;
        
        imageView.image = UIImage()
        
        gallery.requestImageAtIndex(gallery.currentAlbum,index: pageIndex, isThumbnail: false, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            self.imageView.image = image
            self.imageView.center = self.scrollView.center
            self.scrollView.contentSize = self.imageView.frame.size;
            self.imageView.contentMode = .ScaleAspectFill
        })
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!)->UIView
    {
        return self.imageView!
    }
    
    
}
