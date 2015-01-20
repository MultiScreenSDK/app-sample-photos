//
//  Gallery.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 14/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import Photos

class Gallery8: NSObject {
    
    //Array of items
    // this Items could be photos or videos
    var assetImageResults = PHFetchResult()
    var assetVideoResults = PHFetchResult()
    var imageCount = 0
    var videoCount = 0
    
    class var sharedInstance: Gallery8 {
        struct Static {
            static var instance: Gallery8?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Gallery8()
        }
        
        return Static.instance!
    }

    
     // Requesting photo library access.
    func requestAuthorization(completionHandler: ((Bool!) -> Void)!){
        PHPhotoLibrary.requestAuthorization{
            [weak self](status: PHAuthorizationStatus) in
            dispatch_async(dispatch_get_main_queue(), {
                switch status{
                case .Authorized:
                    return completionHandler(true)
                default:
                    return completionHandler(false)
                }
            })
        }
    }
    
    
    func retrieveImages(completionHandler: ((Bool!) -> Void)!){
        /* Retrieve the items in order of modification date, ascending */
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "modificationDate",
            ascending: true)]
        /* Then get an object of type PHFetchResult that will contain
        all our image assets */
        assetImageResults = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        assetVideoResults = PHAsset.fetchAssetsWithMediaType(.Video, options: options)
        
        imageCount = assetImageResults.count
        videoCount = assetVideoResults.count
        
        println("Found \(imageCount) Images results")
        println("Found \(videoCount) Videos results")
        
        return completionHandler(true)
    }
    

    func requestImageAtIndex(index: Int, isThumbnail: Bool ,completionHandler: ((UIImage!, [NSObject : AnyObject]!) -> Void)!){
        
        let imageManager = PHCachingImageManager()
        let object: AnyObject! = assetImageResults.objectAtIndex(index)
        
        if object is PHAsset{
            let asset = object as PHAsset
            
            // request images no bigger than 1/3 the screen width
            let maxDimension = UIScreen.mainScreen().bounds.width * UIScreen.mainScreen().scale
            let imageSize = CGSize(width: maxDimension, height: maxDimension)

            /* For faster performance, and maybe degraded image */
            let options = PHImageRequestOptions()
            
            if isThumbnail{
                options.deliveryMode = .FastFormat
            }else{
                //options.synchronous = true
                options.deliveryMode = .Opportunistic
                options.resizeMode = .Fast
                //imageManager.allowsCachingHighQualityImages = false
            }
            
            
            imageManager.requestImageForAsset(asset,
                targetSize: imageSize ,
                contentMode: .AspectFill,
                options: options,
                resultHandler: {(image: UIImage!,
                    info: [NSObject : AnyObject]!) in
                    return completionHandler(image,info)
            })
        }
    }
   
}
