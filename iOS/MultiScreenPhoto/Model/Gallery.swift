    //
    //  Gallery.swift
    //  multiscreen-demo
    //
    //  Created by Raul Mantilla on 14/01/15.
    //  Copyright (c) 2015 Koombea. All rights reserved.
    //
    
    import UIKit
    import AssetsLibrary
    
    class Gallery: NSObject {
        
        
        var assetsLibrary: ALAssetsLibrary!
        var albums:[ALAssetsGroup] = []
        var numOfAssetsByalbum:[Int] = []
        var isAlbumExpanded:[Bool] = []
        
        internal var currentAlbum = 0
        
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
        
        func retrieveAlbums(completionHandler: ((Bool!) -> Void)!){
            
            assetsLibrary = ALAssetsLibrary()
            
            self.albums = []
            self.numOfAssetsByalbum = []
            self.isAlbumExpanded = []
            
            let enumGroupBlock: ALAssetsLibraryGroupsEnumerationResultsBlock = {(assetsGroup: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                if (assetsGroup != nil) {
                    
                    self.albums.append(assetsGroup)
                    self.numOfAssetsByalbum.append(assetsGroup.numberOfAssets())
                    self.isAlbumExpanded.append(true)
                    
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
        
        func getNumOfAlbums() -> Int{
            return albums.count
        }
        
        func getAlbumName(albumIndex : Int) -> String{
            return albums[albumIndex].valueForProperty(ALAssetsGroupPropertyName) as String
        }
        
        
        func setNumOfAssetsByAlbum(albumIndex : Int){
            numOfAssetsByalbum[albumIndex] = albums[albumIndex].numberOfAssets()
        }
        
        func setNumOfAssetsByAlbum(albumIndex : Int, count: Int){
            numOfAssetsByalbum[albumIndex] = count
        }
        
        func getNumOfAssetsByAlbum(albumIndex : Int)->Int{
            return numOfAssetsByalbum[albumIndex]
        }
        
        func setIsAlbumExpanded(albumIndex : Int, isExpanded: Bool){
            isAlbumExpanded[albumIndex] = isExpanded
        }
        
        func getIsAlbumExpanded(albumIndex : Int)-> Bool{
            return isAlbumExpanded[albumIndex]
        }
        
        func setNumOfAssetsByalbumToZero(albumIndex : Int){
            numOfAssetsByalbum[albumIndex] = 0
        }
        
        func requestImageAtIndex(album: Int, index: Int, isThumbnail: Bool ,completionHandler: ((UIImage!, [NSObject : AnyObject]!) -> Void)!){
            
            //println("[requestImageAtIndex] albums: \(album), image index : \(index)")
            let assetsGroup:ALAssetsGroup = albums[album]
            
            if(getNumOfAssetsByAlbum(album) > index){
                assetsGroup.enumerateAssetsAtIndexes(NSIndexSet(index: index), options: nil, usingBlock: {
                    (asset: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                    if (asset != nil) {
                        
                        var image: UIImage
                        
                        if(isThumbnail){
                            image = self.getThumnailFromAsset(asset)
                        }else{
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
        
        func getImageFromAsset(asset: ALAsset!)->UIImage{
            var cgImage: CGImageRef
            if (asset.defaultRepresentation() != nil){
                var assetRep :ALAssetRepresentation = asset.defaultRepresentation()
                cgImage = assetRep.fullScreenImage().takeUnretainedValue()
                return UIImage(CGImage:cgImage)!
            }
            return getThumnailFromAsset(asset)
        }
        
        func getThumnailFromAsset(asset: ALAsset!)->UIImage{
            var cgImage: CGImageRef
            if (asset.thumbnail() != nil){
                cgImage = asset.thumbnail().takeUnretainedValue()
                return UIImage(CGImage:cgImage)!
            }
            return UIImage(named: "placeholder-image")!
        }
        
    }
