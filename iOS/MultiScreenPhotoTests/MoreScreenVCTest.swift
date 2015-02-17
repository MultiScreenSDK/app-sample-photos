//
//  MoreScreenVCTest.swift
//  MultiScreenPhoto
//
//  Created by Macbook on 17/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import XCTest

class MoreScreenVCTest: XCTestCase {
    
    var moreScreenVC: MoreScreenVC!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        moreScreenVC = MoreScreenVC()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCompatibleButtonShouldExistWhenInitObject(){
        XCTAssertNotNil(moreScreenVC.compatibleButton, "testCompatibleButtonShouldExistWhenInitObject() is not null when init object")
    }
    
    func testExistenceOfCompatibleListView(){
        let compatibleButton = UIButton()
        moreScreenVC.compatibleDevices(compatibleButton)
        XCTAssertNotNil(moreScreenVC.compatibleListView, "testExistenceOfCompatibleListView() compatibleListView should be displayed and not nil")
    }

}
