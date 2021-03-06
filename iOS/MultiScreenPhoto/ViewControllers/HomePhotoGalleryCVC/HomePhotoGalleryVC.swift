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
import AssetsLibrary

/// HomePhotoGalleryVC extend from BaseVC
///
/// This class is used to display the gallery in a UITableView
class HomePhotoGalleryVC: BaseVC, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, HomePhotoGalleryHeaderViewDelegate, HomePhotoGalleryVCCellDelegate {
    
    // UITableView to diplay the gallery photos
    @IBOutlet weak var tableView: UITableView!
    
    // Data source used to calculate the row to insert and delete
    var dataSourceAlbumCountToInsert = 0
    var dataSourceAlbumCountToRemove = 0
    
    // Identifiers for UITableview cells and header
    let reuseIdentifierTVCell1 = "HomePhotoGalleryVCCell1"
    let reuseIdentifierTVCell2 = "HomePhotoGalleryVCCell2"
    let reuseIdentifierForHeaderView = "HomePhotoGalleryHeaderView"
    
    //Size of the cell
    var cellHeight: CGFloat!
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    // Used to calculate the size of the large photo depending on the screen size
    let screenSizeDivisor = CGFloat(2.03)
   
    //Gallery Instance, this instance contains an Array of albums
    private var gallery = Gallery.sharedInstance
    
    //Welcome view displayed the first time the app runs
    var welcomeView: UIView!
  
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Start searching for avaliables services in the network
        multiScreenManager.startSearching()
        
        // Request for photo library access and retrieve the albums
        retrieveAlbums()
        
        self.tableView.registerNib(UINib(nibName: reuseIdentifierForHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: reuseIdentifierForHeaderView);
        
    }
    
    
    // Request for photo library access and retrieve the albums
    func retrieveAlbums(){
        gallery.retrieveAlbums { (result: Bool!) -> Void in
            if (result == true){
                self.tableView!.reloadData()
            } else {
                self.displayAlertWithTitle("Access", message: "Could not access the photo library")
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add an observer to retreive the album when the app Enter Foreground
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "retrieveAlbums", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Display Welcome View only the first time
        if (!defaults.boolForKey("hideWelcomeView")){
            /// UIView that contains the welcome view
            welcomeView = NSBundle.mainBundle().loadNibNamed("WelcomeView", owner: self, options: nil)[0] as? UIView
            welcomeView.frame =  UIScreen.mainScreen().bounds
            
            /// Adding UIVIew to superView
            addUIViewToWindowSuperView(welcomeView)
            
            defaults.setBool(true, forKey: "hideWelcomeView")
        }
    }
    
    /// Remove observer when viewDidDisappear
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup the navigation bar color and fonts
        setUpNavigationBar()
        
        // Calculate the cell size
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            cellHeight = screenSize.size.height/screenSizeDivisor
        } else {
            cellHeight = screenSize.size.width/screenSizeDivisor
        }
        
        tableView.reloadData()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    // Setup the navigation bar color and fonts
    func setUpNavigationBar(){
       
        //Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bg_subtitlebar_home"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false

        self.navigationController?.navigationBar.tintColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        
        // Align the title to the left
        self.navigationItem.leftBarButtonItem = nil;
        var titleLabel: UIBarButtonItem = UIBarButtonItem(title: "Photos", style: .Plain, target: nil, action: nil)
        titleLabel.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Roboto-Light", size: 20)!], forState: UIControlState.Normal)
        
        /// Adding left space to the title
        var addSpacerButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        addSpacerButton.width = 5
        
        self.navigationItem.leftBarButtonItems = [addSpacerButton, titleLabel]
        
    }
    
    /// Calculate the number of rows for a given section and number of assets for album
    func numberOfRowsInSection(section: Int) -> Int{
        if (gallery.albums.count > 0 && gallery.isAlbumExpandedAtIndex[section]){
            var numRow = Double(gallery.numberOfAssetsAtAlbumIndex[section]) / 5
            var numRowMod = gallery.numberOfAssetsAtAlbumIndex[section] % 5
            if (numRow > 0){
                if (numRowMod != 0){
                    numRow = numRow + 1
                }
            }
            return Int(numRow)
        }
        return 0
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return gallery.albums.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return numberOfRowsInSection(section)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return cellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell: HomePhotoGalleryVCCell
        
        // Selecting the correct cell layout depending on the current index
        if (indexPath.row % 2 == 0){
            cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierTVCell1) as HomePhotoGalleryVCCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierTVCell2) as HomePhotoGalleryVCCell
        }
        // Used to know the section of the cell
        cell.section = indexPath.section
        
        cell.delegate = self
        
        // Adding the photos to the cell
        var currentAssetIndex = indexPath.row * 5
        
        // Index Used to sort the photo in desc order
        var reverseIndex =  0
        
        for (var i=0; i<5; i++) {
            
             // Index Used to sort the photo in desc order
            reverseIndex = gallery.numberOfAssetsAtAlbumIndex[indexPath.section] - currentAssetIndex - 1
            if (reverseIndex<0){
                reverseIndex = gallery.numberOfAssetsAtAlbumIndex[indexPath.section]
            }
            
            /// Retrieve an image from the device photo gallery
            gallery.requestImageAtIndex(indexPath.section, index: reverseIndex, containerId: i, isThumbnail: true, completionHandler: {(image: UIImage!, info: [NSObject: AnyObject]!, assetIndex: Int, containerId: Int ) -> Void in
                // If there is no Image then disable the UIImageVIew
                if (image == nil){
                    cell.buttonPhoto[containerId].enabled = false
                } else {
                    cell.buttonPhoto[containerId].enabled = true
                }
                // Setting an UIImage to the UIImageView
                cell.buttonPhoto[containerId].setImage(image, forState: UIControlState.Normal)
                cell.buttonPhoto[containerId].tag = assetIndex
            })
            currentAssetIndex = currentAssetIndex + 1
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        
        var headerView: HomePhotoGalleryHeaderView
        
        headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseIdentifierForHeaderView) as HomePhotoGalleryHeaderView
        
        // Adding the title to the header
        headerView.headerTitle.setTitle(gallery.albumNameAtIndex(section), forState: UIControlState.Normal)
        headerView.delegate = self
        headerView.section = section
        // Set if header is expanded
        headerView.state = gallery.isAlbumExpandedAtIndex[section]
        
        return headerView
    }
    
    
    // Method called from header delegate to collapse or expand the row
    func headerClicked(section: Int){
        if (gallery.isAlbumExpandedAtIndex[section]){
            collapseSection(section)
        } else {
            expandSection(section)
        }
    }
    
    // Animate the section to collapse
    func collapseSection(section: Int){
        
        dataSourceAlbumCountToRemove = Int(self.numberOfRowsInSection(section))
        var indexPathsToDelete = [NSIndexPath]()
        for (var i=0;i < dataSourceAlbumCountToRemove; i++) {
            indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: section))
        }
        
        gallery.isAlbumExpandedAtIndex[section] = false
        tableView!.beginUpdates()
        tableView!.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.Top)
        tableView!.endUpdates()
        
       
        dataSourceAlbumCountToRemove = 0
        
    }
    
    // Animate the section to expand
    func expandSection(section: Int){
        
        gallery.isAlbumExpandedAtIndex[section] = true
        dataSourceAlbumCountToInsert = Int(self.numberOfRowsInSection(section))
        
        /*
        Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
        */
        
        var indexPathsToInsert = [NSIndexPath]()
        for (var i=0;i < dataSourceAlbumCountToInsert; i++) {
            indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: section))
        }
        
        // style the animation so that there's a smooth flow in either direction
        // apply the updates
        tableView!.beginUpdates()
        tableView!.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: UITableViewRowAnimation.Top)
        tableView!.endUpdates()
        
    }
    
    /// HomePhotoGalleryVCCell Delegate method
    func photoSelected(indexPath: NSIndexPath){
        
         /// UIViewController that shows a detailed photo
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoFullScreenPagerVCID") as PhotoFullScreenPagerVC
        // Setting the current Image Index
        viewController.currentIndex = indexPath.row
        viewController.currentAlbumIndex = indexPath.section
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// Used to calculate the cell Size, depending on the orientation
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            cellHeight = screenSize.size.height/screenSizeDivisor
        } else {
            cellHeight = screenSize.size.width/screenSizeDivisor
        }
        tableView.reloadData()
    }
  
    
}
