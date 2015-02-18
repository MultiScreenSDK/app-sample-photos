//
//  WelcomeViewTest.swift
//  MultiScreenPhoto
//
//  Created by Macbook on 17/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import XCTest

class WelcomeViewTest: XCTestCase {
   
    var welcomeView: WelcomeView!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        welcomeView = WelcomeView()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetStartButtonShouldExistWhenInitObject(){
        XCTAssertNotNil(welcomeView.getStartButton, "testGetStartButtonShouldExistWhenInitObject() is not null when init object")
    }
}
