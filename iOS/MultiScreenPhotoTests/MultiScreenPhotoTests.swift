//
//  MultiScreenPhotoTests.swift
//  MultiScreenPhotoTests
//
//  Created by Raul Mantilla on 22/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import XCTest
import AssetsLibrary

class MultiScreenPhotoTests: XCTestCase {
    
    var gallery: Gallery!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        gallery = Gallery.sharedInstance
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testGetNumOfAlbums(){
        var group = ALAssetsGroup()
        gallery.albums = [group,group,group]
        XCTAssert(gallery.getNumOfAlbums() == 3, "GetNumOfAlbums() will return the numbers of items in gallery album")
    }
    
}
