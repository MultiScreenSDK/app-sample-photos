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

/// A Gallery represents an instance of the photos contained in the device photo gallery.

/// Use this class to o retreive the photos from the device photo gallery
class Gallery: NSObject {
    
    //iOS library to retreive the photos from the device
    var assetsLibrary: ALAssetsLibrary! = ALAssetsLibrary()
    /// Array of albums
    var albums: [ALAssetsGroup] = []
    /// Array of number of assets by album
    var numberOfAssetsAtAlbumIndex: [Int] = []
    /// Array of albums expanded state (true, false)
    var isAlbumExpandedAtIndex: [Bool] = []
    
    /// Gallery shared instance used as singleton
    class var sharedInstance: Gallery {
        struct Static {
            static var instance: Gallery?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Gallery()
        }
        
        return Static.instance!
    }
    
    override init() {
        super.init()
        isAlbumExpandedAtIndex.removeAll(keepCapacity: false)
    }
    
    
    /// Retrieve albums from the device photo gallery and save the data into the albums Array, numberOfAssetsAtAlbumIndex Array and isAlbumExpandedAtIndex Array.
    ///
    /// :param: completionHandler The callback handler,  return true or false
    func retrieveAlbums(completionHandler: ((Bool!) -> Void)!){
        
        albums.removeAll(keepCapacity: false)
        numberOfAssetsAtAlbumIndex.removeAll(keepCapacity: false)
        
        /// Temporay array of albums expanded state (true, false)
        var tempIsAlbumExpandedAtIndex: [Bool] = []
        
        /// Enumeration Block
        let enumGroupBlock: ALAssetsLibraryGroupsEnumerationResultsBlock = {(assetsGroup: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if (assetsGroup != nil) {
                
                if (assetsGroup.numberOfAssets() > 0){
                    
                    /// Set the Camera Roll to the first position
                    if (UInt32(assetsGroup.valueForProperty("ALAssetsGroupPropertyType").intValue) == ALAssetsGroupSavedPhotos){
                        /// set this album not expanded
                        tempIsAlbumExpandedAtIndex.insert(true, atIndex: 0)
                        /// Adding the assetGroup to the album Array
                        self.albums.insert(assetsGroup, atIndex: 0)
                        /// Adding the number of photos by album assetGroup
                        self.numberOfAssetsAtAlbumIndex.insert(assetsGroup.numberOfAssets(), atIndex: 0)
                    } else {
                        /// set this album not expanded
                        tempIsAlbumExpandedAtIndex.append(false)
                        /// Adding the assetGroup to the album Array
                        self.albums.append(assetsGroup)
                        /// Adding the number of photos by album assetGroup
                        self.numberOfAssetsAtAlbumIndex.append(assetsGroup.numberOfAssets())
                    }
                }
            } else {
                
                if (self.isAlbumExpandedAtIndex.count != tempIsAlbumExpandedAtIndex.count){
                    self.isAlbumExpandedAtIndex = tempIsAlbumExpandedAtIndex
                }
                
                dispatch_async(dispatch_get_main_queue(),{
                    completionHandler(true)
                })
            }
        }
        
        /// On Fail Block
        let enumFail: ALAssetsLibraryAccessFailureBlock = {(error: NSError!) -> () in
            dispatch_async(dispatch_get_main_queue(),{
                completionHandler(false)
            })
        }
        
        // Enumerate the number of assetGroup
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.assetsLibrary.enumerateGroupsWithTypes(0xFFFFFFFF, usingBlock: enumGroupBlock, failureBlock: enumFail)
        })
    }
    
    /// Returns the album name
    /// :param:  album index
    /// :return: the album name
    func albumNameAtIndex(albumIndex: Int) -> String{
        return albums[albumIndex].valueForProperty(ALAssetsGroupPropertyName) as String
    }
    
    
    /// Retrieve an image from the device photo gallery
    ///
    /// :param: album index
    /// :param: image index
    /// :param: UIImageView tag id
    /// :param: isThumbnail true or false
    /// :param: completionHandler The callback handler,  returns UIImage and Info
    func requestImageAtIndex(album: Int, index: Int, containerId:Int, isThumbnail: Bool, completionHandler: ((UIImage!, [NSObject: AnyObject]!, Int, Int) -> Void)!){
        
        
        if (albums.count > album && numberOfAssetsAtAlbumIndex.count > 0 && numberOfAssetsAtAlbumIndex[album] > index){
            
            let assetsGroup:ALAssetsGroup = albums[album]
            
            /// Enumerate asset for a given index
            assetsGroup.enumerateAssetsAtIndexes(NSIndexSet(index: index), options: nil, usingBlock: {
                (asset: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                if (asset != nil) {
                    
                    var image: UIImage
                    
                    if (isThumbnail){
                        // If it is a thumbnail then retrieve a small size photo
                        image = self.thumbnailForAsset(asset)
                    } else {
                        // Retrieve a medium size photo
                        image = self.imageForAsset(asset)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        return completionHandler(image, nil, index, containerId)
                    })
                }
            })
        } else {
            dispatch_async(dispatch_get_main_queue(),{
                return completionHandler(nil, nil, index, containerId)
            })
        }
        
    }
    
    /// Retrieve a medium size photo
    ///
    /// :param: ALAsset
    /// :return: UIImage to be displayed
    func imageForAsset(asset: ALAsset!) -> UIImage{
        var cgImage: CGImageRef
        if (asset.defaultRepresentation() != nil){
            var assetRep: ALAssetRepresentation = asset.defaultRepresentation()
            cgImage = assetRep.fullScreenImage().takeUnretainedValue()
            return UIImage(CGImage: cgImage)!
        }
        return thumbnailForAsset(asset)
    }
    
    
    /// Retrieve a small size photo
    ///
    /// :param: ALAsset
    /// :return: UIImage to be displayed
    func thumbnailForAsset(asset: ALAsset!) -> UIImage{
        var cgImage: CGImageRef
        if (asset.thumbnail() != nil){
            cgImage = asset.aspectRatioThumbnail().takeUnretainedValue()
            return UIImage(CGImage: cgImage)!
        }
        return UIImage(named: "placeholder-image")!
    }
    
}
