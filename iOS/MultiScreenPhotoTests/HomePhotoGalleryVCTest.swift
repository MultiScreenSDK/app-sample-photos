//
//  HomePhotoGalleryVCTest.swift
//  MultiScreenPhoto
//
//  Created by Macbook on 17/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import XCTest
import AssetsLibrary

class HomePhotoGalleryVCTest: XCTestCase {
   
    var homePhotoGalleryVC: HomePhotoGalleryVC!
    var gallery: Gallery!
    var album: ALAssetsGroup!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        homePhotoGalleryVC = HomePhotoGalleryVC()
        gallery = Gallery.sharedInstance
        album = ALAssetsGroup()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExistenceOfMultiScreenManagerAttribute(){
        XCTAssertTrue(homePhotoGalleryVC.multiScreenManager.isKindOfClass(MultiScreenManager), "testExistenceOfMultiScreenManagerAttribute() multiScreenManager should be of type MultiScreenManager")
    }
    
    func testTableViewShouldExistWhenInitObject(){
        XCTAssertNotNil(homePhotoGalleryVC.tableView, "testTableViewShouldExistWhenInitObject() is not null when init object")
    }
    
    func testNumberOfRowsInSectionWhenAlbumIsExpanded(){
        gallery.albums = [album]
        gallery.isAlbumExpandedAtIndex[0]  =  true
        gallery.numberOfAssetsAtAlbumIndex[0] = 15
        XCTAssertEqual(homePhotoGalleryVC.numberOfRowsInSection(0), 3, "testNumberOfRowsInSectionWhenAlbumIsExpanded() will return 3")
    }
    
    func testNumberOfRowsInSectionWhenAlbumIsCollapseEqualZero(){
        gallery.albums = [album]
        gallery.isAlbumExpandedAtIndex[0] = false
        gallery.numberOfAssetsAtAlbumIndex[0]  = 15
        XCTAssertEqual(homePhotoGalleryVC.numberOfRowsInSection(0), 0, "testNumberOfRowsInSectionWhenAlbumIsCollapseEqualZero() will return 0")
    }
    
    
}
