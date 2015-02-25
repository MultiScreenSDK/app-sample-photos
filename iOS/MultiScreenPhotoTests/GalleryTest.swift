//
//  GalleryTest.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 5/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import XCTest
import AssetsLibrary

class GalleryTest: XCTestCase {
    
    var gallery: Gallery!
    var album: ALAssetsGroup!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        gallery = Gallery.sharedInstance
        album = ALAssetsGroup()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
}
