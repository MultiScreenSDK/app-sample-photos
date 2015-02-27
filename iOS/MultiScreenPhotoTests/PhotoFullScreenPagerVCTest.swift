//
//  PhotoFullScreenPagerVCTest.swift
//  MultiScreenPhoto
//
//  Created by Macbook on 17/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import XCTest
import AssetsLibrary

class PhotoFullScreenPagerVCTest: XCTestCase {
 
    var photoFullScreenPagerVC: PhotoFullScreenPagerVC!
    var gallery: Gallery!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        photoFullScreenPagerVC = PhotoFullScreenPagerVC()
        gallery = Gallery.sharedInstance
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestImageAtIndex(){
        let albumIndex = 0
        let currentIndex = 0
        gallery.requestImageAtIndex(albumIndex, index: currentIndex, containerId: 0, isThumbnail: false, completionHandler: {(image: UIImage!, info: [NSObject: AnyObject]!, assetIndex: Int, containerId: Int ) -> Void in
            XCTAssertTrue(image.isKindOfClass(UIImage), "testRequestImageAtIndex() image should be of type UIImage")
        })
        
    }
    
    
}
