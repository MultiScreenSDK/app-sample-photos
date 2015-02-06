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
class PhotoFullScreenPagerVC: CommonVC , UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate,PhotoFullScreenVCDelegate {
    
    //Gallery Instance, this instance contains an Array of albums
    var gallery = Gallery.sharedInstance
    
    //number of assets in current album
    var numberOfAssets: Int = 0
    
    // Timer to send the image to the TV after a few seconds
    var timer: NSTimer!
    
    // Timer to set the navigation bar hidden
    var navigationTimer: NSTimer!
    
    //UIPageViewController used to paginate photos
    var pageViewController : UIPageViewController?
    
    //index of the current photo displayed
    var currentIndex : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.navigationController?.interactivePopGestureRecognizer.delegate = self
        
        //number of assets in current album
        numberOfAssets = gallery.getNumOfAssetsByAlbum(gallery.currentAlbum)
        
        //Setting the pageViewController pages
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 10])
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
    
    /// Method to setup the navigation bar color and font
    func setUpNavigationBar(){
        
        /// Start the navigation bar hidden time
        navigationBarTimer()
        
        //Translucent Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bg_subtitlebar"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = true
        
        // Configuring back icon
        self.navigationItem.leftBarButtonItems = nil;
        let imageBackButton = UIImage(named: "btn_back_arrow") as UIImage?
        var addBackButton: UIBarButtonItem = UIBarButtonItem(image: imageBackButton, style: .Plain, target: self, action: "goBack")
         self.navigationItem.leftBarButtonItems = [addBackButton]
        
    }
    /// Method used to dismiss the current view controller
    func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
        return false;
    }
    
    // MARK: - Page View Controller delegates
    
    /// Delegate used to load the previous Album image
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        
        var index = (viewController as PhotoFullScreenVC).pageIndex
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index--
        
        return viewControllerAtIndex(index)
    }
    
    /// Delegate used to load the next Album image
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
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
    
    /// Delegate method that capture when the animation pager stops
    /// If next photo is displayed then start the Timer,
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool){
        timer.invalidate()
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
        
        /// Set the current photo index
        currentIndex = index
        
        return pageContentViewController
    }
    
    /// Method used to start the navigation bar timer to be hidden
    func navigationBarTimer(){
        navigationTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("hiddeNavBar"), userInfo: nil, repeats: false)
    }
    
    /// Method used to display the hidden navigation bar
    func showNavigationBar(){
        if(navigationTimer != nil){
            navigationTimer.invalidate()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationBarTimer()
        
    }
    /// Method used to hide the navigation bar
    func hiddeNavBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /// Method used to start the timer to send the Photo to the TV
    func startSendImageTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("sendToTv"), userInfo: nil, repeats: false)
    }
    
    /// Method used to send the current Photo to the TV
    override func sendToTv() {
        /// Check if there is an application current connected
        if(multiScreenManager.isApplicationConnected() == true){
            
            /// Detect the current Photo ViewController displayed
            var currentView: PhotoFullScreenVC = pageViewController?.viewControllers.last! as PhotoFullScreenVC
            
            /// Request the current image at index, from the device photo album
            gallery.requestImageAtIndex(gallery.currentAlbum,index: currentView.pageIndex, containerId: 0, isThumbnail: false, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!,assetIndex:Int, containerId: Int ) -> Void in
                /// Send the returned image to the TV
                self.multiScreenManager.sendPhotoToTv(image)
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        /// Invalidate the timers
        timer.invalidate()
        navigationTimer.invalidate()
        super.viewWillDisappear(animated)
    }
}
