/*

Copyright (c) 2014 Samsung Electronics

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

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
        
        /// Used to disable the scrollview auto Adjusts
        self.automaticallyAdjustsScrollViewInsets = false;
     
    }
    
    // Request for photo library access and retrieving albums
    func retrieveAlbums(){
        gallery.retrieveAlbums { (result: Bool!) -> Void in
            if (result == true){
                //number of assets in current album
                if (self.gallery.albums.count <= self.currentAlbumIndex || self.gallery.numberOfAssetsAtAlbumIndex[self.currentAlbumIndex] != self.numberOfAssets){
                    self.goBack()
                }
            } else {
                self.displayAlertWithTitle("Access", message: "Could not access the photo library")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Setup the navigation bar color and font
        setUpNavigationBar()
        
        // Start timer to send the image to the TV
        startSendImageTimer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add an observer to retreive the album when the app Enter Foreground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "retrieveAlbums", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendToTv", name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
    }
    
    /// Remove observer when viewDidDisappear
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
         NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    /// Setup the navigation bar color and font
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
    /// Dismiss the current view controller
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
    
    /// Load PhotoFullScreenVC viewController to be added to the pageViewController
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
        
        // Pass the image index to be loaded
        pageContentViewController.pageIndex = index
        pageContentViewController.pageAlbumIndex = currentAlbumIndex
        
        return pageContentViewController
    }
    
    /// Display the hidden navigation bar
    func showNavigationBar(){
        if ((self.navigationController?.navigationBar.hidden) == true){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
        }
    }
    
    /// Update current visible index
    func updateCurrentIndex(index: Int){
        currentIndex = index
    }
    
    /// Hide the navigation bar
    func hiddeNavBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /// Start the timer to send the Photo to the TV
    func startSendImageTimer(){
        timer = NSTimer(timeInterval: 0.1, target: self, selector: Selector("sendToTv"), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    /// Send the current Photo to the TV
    func sendToTv() {
        /// Check if there is an application currently connected
        if (multiScreenManager.isConnected == true){
            /// Set the current photo index
            /// Request the current image at index, from the device photo album
            gallery.requestImageAtIndex(currentAlbumIndex, index: currentIndex, containerId: 0, isThumbnail: false, completionHandler: {(image: UIImage!, info: [NSObject: AnyObject]!, assetIndex: Int, containerId: Int ) -> Void in
                
                /// Send the returned image to the TV
                if (image != nil){
                    self.multiScreenManager.sendPhotoToTv(image)
                }
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        /// Invalidate the timers
        self.timer.invalidate()
        super.viewWillDisappear(animated)
    }
}
