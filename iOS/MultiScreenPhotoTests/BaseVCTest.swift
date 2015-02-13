//
//  BaseVCTest.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 5/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import XCTest

class BaseVCTest: XCTestCase {
    
    var baseVC: BaseVC!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        baseVC = BaseVC()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExistenceOfMultiScreenManagerAttribute(){
        XCTAssertTrue(baseVC.multiScreenManager.isKindOfClass(MultiScreenManager), "testExistenceOfMultiScreenManagerAttribute() multiScreenManager should be of tipe MultiScreenManager")
    }
    
    
    func testExistenceOfCastMenuView(){
        baseVC.servicesView =  ServicesView()
        XCTAssertTrue(baseVC.servicesView.isKindOfClass(ServicesView), "testExistenceOfMultiScreenManagerAttribute() servicesView should be of tipe ServicesFoundView")
    }
    
    
    func testShowCastMenuView(){
        baseVC.showCastMenuView()
        XCTAssertNotNil(baseVC.servicesView, "testShowCastMenuView() castMenuView should be displayed and not nil")
    }
    
    
    func testDisplayAlertView(){
        baseVC.displayAlertWithTitle("Alert title", message: "Alert message")
        XCTAssertNotNil(baseVC.alertView, "testDisplayAlertView() alertView should be displayed and not nil")
    }
    
}
