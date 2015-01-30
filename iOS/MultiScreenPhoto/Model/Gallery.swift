    //
    //  Gallery.swift
    //  multiscreen-demo
    //
    //  Created by Raul Mantilla on 14/01/15.
    //  Copyright (c) 2015 Koombea. All rights reserved.
    //
    // Gallery class is used to retreive the Images from the photo gallery
    
    
    import UIKit
    import AssetsLibrary
    
    class Gallery: NSObject {
        
        var assetsLibrary: ALAssetsLibrary!
        var albums:[ALAssetsGroup] = []  // Array of albums
        var numOfAssetsByalbum:[Int] = [] // Array of numbers of assets by album
        var isAlbumExpanded:[Bool] = [] // Array of albums expanded (true, false)
        
        internal var currentAlbum = 0 // Current album displayed in the detail view
        
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
        
        //Retrieve albums from the photo gallery and save the data into the albums, numOfAssetsByalbum and isAlbumExpanded arrays variables.
        func retrieveAlbums(completionHandler: ((Bool!) -> Void)!){
            
            assetsLibrary = ALAssetsLibrary()
            
            self.albums = []
            self.numOfAssetsByalbum = []
            self.isAlbumExpanded = []
            
            let enumGroupBlock: ALAssetsLibraryGroupsEnumerationResultsBlock = {(assetsGroup: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                if (assetsGroup != nil) {
                    
                    self.albums.append(assetsGroup) // saving the album
                    self.numOfAssetsByalbum.append(assetsGroup.numberOfAssets()) // numOfAssetsByalbum by album
                    self.isAlbumExpanded.append(true) // Set true to all the album
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(),{
                        completionHandler(true)
                    })
                }
            }
            let enumFail: ALAssetsLibraryAccessFailureBlock = {(error: NSError!) -> () in
                dispatch_async(dispatch_get_main_queue(),{
                    completionHandler(false)
                })
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.assetsLibrary.enumerateGroupsWithTypes(0xFFFFFFFF, usingBlock: enumGroupBlock, failureBlock: enumFail)
            })
        }
        
        // Returns the number of albums
        func getNumOfAlbums() -> Int{
            return albums.count
        }
        
        // Returns a given album name
        func getAlbumName(albumIndex : Int) -> String{
            return albums[albumIndex].valueForProperty(ALAssetsGroupPropertyName) as String
        }
        
        //Updates the number of assets for a given album
        func setNumOfAssetsByAlbum(albumIndex : Int){
            numOfAssetsByalbum[albumIndex] = albums[albumIndex].numberOfAssets()
        }
        
        //Set the the number of assets for a given album and count
        func setNumOfAssetsByAlbum(albumIndex : Int, count: Int){
            numOfAssetsByalbum[albumIndex] = count
        }
        
        //Set the the number of assets for a given album to zero
        func setNumOfAssetsByalbumToZero(albumIndex : Int){
            numOfAssetsByalbum[albumIndex] = 0
        }
        
        //Returns the number of assets for a given album
        func getNumOfAssetsByAlbum(albumIndex : Int)->Int{
            return numOfAssetsByalbum[albumIndex]
        }
        
        //Set isAlbumExpanded to true or false for a given album
        func setIsAlbumExpanded(albumIndex : Int, isExpanded: Bool){
            isAlbumExpanded[albumIndex] = isExpanded
        }
        
        //Returns if a given album is expanded
        func getIsAlbumExpanded(albumIndex : Int)-> Bool{
            return isAlbumExpanded[albumIndex]
        }
       
        //Returns an Image from a given album and Photo index
        func requestImageAtIndex(album: Int, index: Int, isThumbnail: Bool ,completionHandler: ((UIImage!, [NSObject : AnyObject]!) -> Void)!){
            
            let assetsGroup:ALAssetsGroup = albums[album]
            
            if(getNumOfAssetsByAlbum(album) > index){
                assetsGroup.enumerateAssetsAtIndexes(NSIndexSet(index: index), options: nil, usingBlock: {
                    (asset: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                    if (asset != nil) {
                        
                        var image: UIImage
                        
                       
                        if(isThumbnail){
                             //If is a thumbnail then retrieve a small size photo
                            image = self.getThumnailFromAsset(asset)
                        }else{
                             //Retrieve a medium size photo
                            image = self.getImageFromAsset(asset)
                        }
                        
                        dispatch_async(dispatch_get_main_queue(),{
                            return completionHandler(image,nil)
                        })
                    }
                })
            }else{
                dispatch_async(dispatch_get_main_queue(),{
                    return completionHandler(nil,nil)
                })
            }
        }
        
        //Retrieve a medium size photo
        func getImageFromAsset(asset: ALAsset!)->UIImage{
            var cgImage: CGImageRef
            if (asset.defaultRepresentation() != nil){
                var assetRep :ALAssetRepresentation = asset.defaultRepresentation()
                cgImage = assetRep.fullScreenImage().takeUnretainedValue()
                return UIImage(CGImage:cgImage)!
            }
            return getThumnailFromAsset(asset)
        }
        
        //Retrieve a small size photo
        func getThumnailFromAsset(asset: ALAsset!)->UIImage{
            var cgImage: CGImageRef
            if (asset.thumbnail() != nil){
                cgImage = asset.thumbnail().takeUnretainedValue()
                return UIImage(CGImage:cgImage)!
            }
            return UIImage(named: "placeholder-image")!
        }
        
    }
