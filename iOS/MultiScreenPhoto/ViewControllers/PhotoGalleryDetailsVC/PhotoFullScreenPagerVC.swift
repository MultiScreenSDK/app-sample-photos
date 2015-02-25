//
//  PhotoFullScreenVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

/// PhotoFullScreenPagerVC
///
/// This class is used to show the pagination of the current photos album
class PhotoFullScreenPagerVC: BaseVC, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, PhotoFullScreenVCDelegate {
    
    //Gallery Instance, this instance contains an Array of albums
    var gallery = Gallery.sharedInstance
    
    //number of assets in current album
    var numberOfAssets: Int = 0
    
    // Timer to send the image to the TV after a few seconds
    var timer: NSTimer!
    
    //UIPageViewController used to paginate photos
    var pageViewController: UIPageViewController?
    
    //index of the current photo displayed
    var currentIndex: Int = 0
    
    //index of the current Album displayed
    var currentAlbumIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer.delegate = self
        
        // Add an observer to check for if a tv is connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendToTv", name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        
        //number of assets in current album
        numberOfAssets = gallery.numberOfAssetsAtAlbumIndex[currentAlbumIndex]
        
        //Setting the pageViewController pages
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 10])
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        /// Loading the first view controller in the PageViewController, this is the current photo selected view controller
        let startingViewController: PhotoFullScreenVC = viewControllerAtIndex(currentIndex)!
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        
        /// Used to diable the scrollview auto Adjusts
        self.automaticallyAdjustsScrollViewInsets = false;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Method to setup the navigation bar color and font
        setUpNavigationBar()
        
        // Start timer to send the image to the TV
        startSendImageTimer()
    }
    
    /// Remove observer when viewDidDisappear
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
         NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
    }
    
    /// Method to setup the navigation bar color and font
    func setUpNavigationBar(){
        
        //Translucent Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bg_subtitlebar"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = true
        
        // Configuring back icon
        self.navigationItem.leftBarButtonItems = nil;
        let imageBackButton = UIImage(named: "btn_back_arrow") as UIImage?
        let backButton = UIButton(frame: CGRectMake(0, 0, 11, 19))
        backButton.addTarget(self, action: Selector("goBack"), forControlEvents: UIControlEvents.TouchUpInside)
        backButton.setBackgroundImage(imageBackButton, forState: UIControlState.Normal)
        var addBackButton: UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItems = [addBackButton]
        
    }
    /// Method used to dismiss the current view controller
    func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
       
    // MARK: - Page View Controller delegates
    
    /// Delegate used to load the previous Album image
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        
        var index = (viewController as PhotoFullScreenVC).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == numberOfAssets) {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
    /// Delegate used to load the next Album image
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as PhotoFullScreenVC).pageIndex
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index--
        
        return viewControllerAtIndex(index)
        
    }
    
    /// Delegate method that capture when the animation pager stops
    /// If next photo is displayed then start the Timer,
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool){
        
        self.timer.invalidate()
        startSendImageTimer()
        
    }
    
    /// Method used to load PhotoFullScreenVC viewController to be add it to the pageViewController
    /// The returned viewController is the one that displays the photo
    func viewControllerAtIndex(index: Int) -> PhotoFullScreenVC?
    {
        if numberOfAssets == 0 || index >= numberOfAssets || index < 0
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = PhotoFullScreenVC()
         pageContentViewController.delegate = self
        
        // Pass the image index to be load
        pageContentViewController.pageIndex = index
        pageContentViewController.pageAlbumIndex = currentAlbumIndex
        
        return pageContentViewController
    }
    
    /// Method used to display the hidden navigation bar
    func showNavigationBar(){
        if ((self.navigationController?.navigationBar.hidden) == true){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }else{
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
        }
    }
    
    /// Method used to update current visible index
    func updateCurrentIndex(index: Int){
        currentIndex = index
    }
    
    /// Method used to hide the navigation bar
    func hiddeNavBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /// Method used to start the timer to send the Photo to the TV
    func startSendImageTimer(){
        timer = NSTimer(timeInterval: 0.1, target: self, selector: Selector("sendToTv"), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    /// Method used to send the current Photo to the TV
    func sendToTv() {
        /// Check if there is an application current connected
        if(multiScreenManager.isConnected == true){
            /// Set the current photo index
            /// Request the current image at index, from the device photo album
            gallery.requestImageAtIndex(currentAlbumIndex, index: currentIndex, containerId: 0, isThumbnail: false, completionHandler: {(image: UIImage!, info: [NSObject: AnyObject]!, assetIndex: Int, containerId: Int ) -> Void in
                /// Send the returned image to the TV
                self.multiScreenManager.sendPhotoToTv(image)
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        /// Invalidate the timers
        self.timer.invalidate()
        super.viewWillDisappear(animated)
    }
}
