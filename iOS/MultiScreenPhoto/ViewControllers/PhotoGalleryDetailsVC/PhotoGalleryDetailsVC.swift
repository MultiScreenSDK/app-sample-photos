//
//  PhotoGalleryDetailsVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

class PhotoGalleryDetailsVC: CommonVC , UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate {
    
    //Gallery Instance, this instance contains an Array of albums
    var gallery = Gallery.sharedInstance
    
    //number of assets in current album
    var numberOfAssets: Int = 0
    
    // Timer to send the image to the TV after a few seconds
    var timer: NSTimer!
    
    //UIPageViewController used to paginate photos
    var pageViewController : UIPageViewController?
    
    //index of the current photo displayed
    var currentIndex : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer.delegate = self
        
        //number of assets in current album
        numberOfAssets = gallery.getNumOfAssetsByAlbum(gallery.currentAlbum)
        
        // Start timer to send the image to the TV
        startTimer()
        
        //Setting the pageViewController pages
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 10])
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        let startingViewController: PhotoPageContentVC = viewControllerAtIndex(currentIndex)!
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
        return false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        
        var index = (viewController as PhotoPageContentVC).pageIndex
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as PhotoPageContentVC).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == numberOfAssets) {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> PhotoPageContentVC?
    {
        if numberOfAssets == 0 || index >= numberOfAssets || index < 0
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = PhotoPageContentVC()
        
        
        //pageContentViewController.titleText = pageTitles[index]
        pageContentViewController.pageIndex = index
        currentIndex = index
        
        return pageContentViewController
    }
    
    // If next photo is displayed then start the Timer,
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool){
        timer.invalidate()
        startTimer()
        
    }
    
    func startTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("sendToTv"), userInfo: nil, repeats: false)
    }
    
    func sendToTv() {
        
        if(multiScreenManager.isApplicationConnected() == true){
            var currentView: PhotoPageContentVC = pageViewController?.viewControllers.last! as PhotoPageContentVC
            
            gallery.requestImageAtIndex(gallery.currentAlbum,index: currentView.pageIndex, isThumbnail: false, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
                self.multiScreenManager.sendPhotoToTv(image)
            })
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
        super.viewWillDisappear(animated)
    }
    
}
