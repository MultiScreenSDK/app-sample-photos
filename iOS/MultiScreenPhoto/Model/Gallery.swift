//
//  Gallery.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import AssetsLibrary

/// A Gallery represents an instance of the photos contained in the device photo gallery.

/// Use this class to o retreive the photos from the device photo gallery
class Gallery: NSObject {
    
    //iOS library to retreive the photos from the device
    var assetsLibrary: ALAssetsLibrary!
    /// Array of albums
    var albums:[ALAssetsGroup] = []
    /// Array of numbers of assets by album
    var numOfAssetsByalbum:[Int] = []
    /// Array of albums state (true, false)
    var isAlbumExpanded:[Bool] = []
    
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
    
    /// Retrieve albums from the device photo gallery and save the data into the albums Array, numOfAssetsByalbum Array and isAlbumExpanded Array.
    ///
    /// :param: completionHandler The callback handler,  return true or false
    func retrieveAlbums(completionHandler: ((Bool!) -> Void)!){
        
        assetsLibrary = ALAssetsLibrary()
        
        self.albums = []
        self.numOfAssetsByalbum = []
        self.isAlbumExpanded = []
        
        /// Enumeration Block
        let enumGroupBlock: ALAssetsLibraryGroupsEnumerationResultsBlock = {(assetsGroup: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if (assetsGroup != nil) {
                
                if(self.albums.count > 0){
                    ///if albums > 0 then set the other album expanded to false
                    self.isAlbumExpanded.append(false)
                }else{
                     ///if albums == 0 then set this album as expanded
                    self.isAlbumExpanded.append(true)
                }
                /// Adding the assetGroup to the album Array
                self.albums.append(assetsGroup)
                
                /// Adding the number of photos by album assetGroup
                self.numOfAssetsByalbum.append(assetsGroup.numberOfAssets())
            }else{
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
    
    // Returns the number of albums
    func getNumOfAlbums() -> Int{
        return albums.count
    }
    
    /// Returns the album name
    /// :param:  album index
    /// :return: the album name
    func getAlbumName(albumIndex : Int) -> String{
        return albums[albumIndex].valueForProperty(ALAssetsGroupPropertyName) as String
    }
    
    /// Updates the number of assets for a given album
    /// :param:  album index
    func setNumOfAssetsByAlbum(albumIndex : Int){
        numOfAssetsByalbum.insert(albums[albumIndex].numberOfAssets(), atIndex:albumIndex)
    }
    
    /// Set the the number of assets for a given album and count
    /// :param:  album index
    /// :param:  number of assets
    func setNumOfAssetsByAlbum(albumIndex : Int, count: Int){
        numOfAssetsByalbum.insert(count, atIndex:albumIndex)
    }
    
    /// Returns the number of assets for a given album
    /// :param:  album index
    func getNumOfAssetsByAlbum(albumIndex : Int)->Int{
        if(numOfAssetsByalbum.count > 0){
            return numOfAssetsByalbum[albumIndex]
        }else{
            return 0
        }
    }
    
    /// Set isAlbumExpanded to true or false for a given album
    /// :param:  album index
    /// :param:  true or false
    func setIsAlbumExpanded(albumIndex : Int, isExpanded: Bool){
        isAlbumExpanded[albumIndex] = isExpanded
    }
    
    /// Returns if a given album is expanded
    /// :params:  album index
    func getIsAlbumExpanded(albumIndex : Int)-> Bool{
        if(isAlbumExpanded.count > 0){
            return isAlbumExpanded[albumIndex]
        }else{
            return false
        }
    }
    
    /// Returns index from current album expanded
    /// :return:  album index
    func getIndexFromCurrentAlbumExpanded()-> Int{
        for (index, value) in enumerate(isAlbumExpanded) {
            if (value){
                return index
            }
        }
        return NSNotFound
    }
   
    /// Retrieve an image from the device photo gallery
    ///
    /// :param: album index
    /// :param: image index
    /// :param: UIImageView tag id
    /// :param: isThumbnail true or false
    /// :param: completionHandler The callback handler,  returns UIImage and Info
    func requestImageAtIndex(album: Int, index: Int, containerId:Int, isThumbnail: Bool ,completionHandler: ((UIImage!, [NSObject : AnyObject]!, Int, Int) -> Void)!){
        
        let assetsGroup:ALAssetsGroup = albums[album]
        
        /// If album has images in it
        if(getNumOfAssetsByAlbum(album) > index){
            
            /// Enumerate asset for a given index
            assetsGroup.enumerateAssetsAtIndexes(NSIndexSet(index: index), options: nil, usingBlock: {
                (asset: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                if (asset != nil) {
                    
                    var image: UIImage
                    
                    if(isThumbnail){
                         // If is a thumbnail then retrieve a small size photo
                        image = self.getThumnailFromAsset(asset)
                    }else{
                         // Retrieve a medium size photo
                        image = self.getImageFromAsset(asset)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        return completionHandler(image,nil,index,containerId)
                    })
                }
            })
        }else{
            dispatch_async(dispatch_get_main_queue(),{
                return completionHandler(nil,nil,index,containerId)
            })
        }
    }
    
    /// Retrieve a medium size photo
    ///
    /// :param: ALAsset
    /// :return: UIImage to be displayed
    func getImageFromAsset(asset: ALAsset!)->UIImage{
        var cgImage: CGImageRef
        if (asset.defaultRepresentation() != nil){
            var assetRep :ALAssetRepresentation = asset.defaultRepresentation()
            cgImage = assetRep.fullScreenImage().takeUnretainedValue()
            return UIImage(CGImage:cgImage)!
        }
        return getThumnailFromAsset(asset)
    }
    
    
    /// Retrieve a small size photo
    ///
    /// :param: ALAsset
    /// :return: UIImage to be displayed
    func getThumnailFromAsset(asset: ALAsset!)->UIImage{
        var cgImage: CGImageRef
        if (asset.thumbnail() != nil){
            cgImage = asset.aspectRatioThumbnail().takeUnretainedValue()
            return UIImage(CGImage:cgImage)!
        }
        return UIImage(named: "placeholder-image")!
    }
    
}
