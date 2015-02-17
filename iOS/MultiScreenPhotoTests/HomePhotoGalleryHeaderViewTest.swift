//
//  HomePhotoGalleryHeaderViewTest.swift
//  MultiScreenPhoto
//
//  Created by Macbook on 17/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import XCTest

class HomePhotoGalleryHeaderViewTest: XCTestCase {
   
    var homePhotoGalleryHeaderView: HomePhotoGalleryHeaderView!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        homePhotoGalleryHeaderView = HomePhotoGalleryHeaderView()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHeaderTitleShouldExistWhenInitObject(){
        XCTAssertNotNil(homePhotoGalleryHeaderView.headerTitle, "testHeaderTitleShouldExistWhenInitObject() is not null when init object")
    }
    
    func testImageViewArrowShouldExistWhenInitObject(){
        XCTAssertNotNil(homePhotoGalleryHeaderView.imageViewArrow, "testImageViewArrowShouldExistWhenInitObject() is not null when init object")
    }
    
    func testImageViewSeparatorShouldExistWhenInitObject(){
        XCTAssertNotNil(homePhotoGalleryHeaderView.imageViewSeparator, "testImageViewSeparatorShouldExistWhenInitObject() is not null when init object")
    }
}
