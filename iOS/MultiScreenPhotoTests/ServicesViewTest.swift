//
//  ServicesViewTest.swift
//  MultiScreenPhoto
//
//  Created by Macbook on 17/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import XCTest

class ServicesViewTest: XCTestCase {
    
    var servicesView: ServicesView!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        servicesView = ServicesView()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExistenceOfMultiScreenManagerAttribute(){
        XCTAssertTrue(servicesView.multiScreenManager.isKindOfClass(MultiScreenManager), "testExistenceOfMultiScreenManagerAttribute() multiScreenManager should be of type MultiScreenManager")
    }
    
    func testTableViewShouldExistWhenInitObject(){
        XCTAssertNotNil(servicesView.tableView, "testTableViewShouldExistWhenInitObject() is not null when init object")
    }
    
    func testTitleShouldExistWhenInitObject(){
        XCTAssertNotNil(servicesView.title, "testTitleShouldExistWhenInitObject() is not null when init object")
    }
    
    func testIconShouldExistWhenInitObject(){
        XCTAssertNotNil(servicesView.icon, "testIconShouldExistWhenInitObject() is not null when init object")
    }
   
    func testServiceConnectedNameShouldExistWhenInitObject(){
        XCTAssertNotNil(servicesView.serviceConnectedName, "testServiceConnectedNameShouldExistWhenInitObject() is not null when init object")
    }
   
    func testDisconnectButtonShouldExistWhenInitObject(){
        XCTAssertNotNil(servicesView.disconnectButton, "testDisconnectButtonShouldExistWhenInitObject() is not null when init object")
    }
   
}
    