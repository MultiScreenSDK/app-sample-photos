//
//  PhotoFullScreenVC.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

class PhotoFullScreenPagerVC: CommonVC , UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate {
    
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
        
        // Method to setup the navigation bar color and fonts
        setUpNavigationBar()
        
        self.navigationController?.interactivePopGestureRecognizer.delegate = self
        
        //number of assets in current album
        numberOfAssets = gallery.getNumOfAssetsByAlbum(gallery.currentAlbum)
        
        // Start timer to send the image to the TV
        startTimer()
        
        //Setting the pageViewController pages
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 10])
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        let startingViewController: PhotoFullScreenVC = viewControllerAtIndex(currentIndex)!
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        
    }
    
    func setUpNavigationBar(){
        
        //Translucent Navigation Bar
    self.navigationController?.navigationBar.setBackgroundImage(getImageWithColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.6), size: CGSize(width: 100, height: 144)), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        // Configuring setting icon
        self.navigationItem.leftBarButtonItems = nil;
        let imageBackButton = UIImage(named: "btn_back_arrow") as UIImage?
        var addBackButton: UIBarButtonItem = UIBarButtonItem(image: imageBackButton, style: .Plain, target: self, action: "goBack")
         self.navigationItem.leftBarButtonItems = [addBackButton]
        
    }
    
    func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
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
        
        var index = (viewController as PhotoFullScreenVC).pageIndex
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index--
        
        return viewControllerAtIndex(index)
    }
    
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
    
    func viewControllerAtIndex(index: Int) -> PhotoFullScreenVC?
    {
        if numberOfAssets == 0 || index >= numberOfAssets || index < 0
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = PhotoFullScreenVC()
        
        
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
            var currentView: PhotoFullScreenVC = pageViewController?.viewControllers.last! as PhotoFullScreenVC
            
            gallery.requestImageAtIndex(gallery.currentAlbum,index: currentView.pageIndex, containerId: 0, isThumbnail: false, completionHandler: {(image: UIImage!, info: [NSObject : AnyObject]!,assetIndex:Int, containerId: Int ) -> Void in
                self.multiScreenManager.sendPhotoToTv(image)
            })
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
        super.viewWillDisappear(animated)
    }
    
    //Return an UIImage from a given UIColor
    //This method is used for the translucent Navigation Bar
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
