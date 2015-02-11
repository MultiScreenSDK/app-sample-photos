//
//  CommonVCTest.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 5/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import XCTest

class CommonVCTest: XCTestCase {
    
    var commonVC: CommonVC!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        commonVC = CommonVC()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExistenceOfMultiScreenManagerAttribute(){
        XCTAssertTrue(commonVC.multiScreenManager.isKindOfClass(MultiScreenManager), "testExistenceOfMultiScreenManagerAttribute() multiScreenManager should be of tipe MultiScreenManager")
    }
    
    
    func testExistenceOfCastMenuView(){
        commonVC.castMenuView =  ServicesFoundView()
        XCTAssertTrue(commonVC.castMenuView.isKindOfClass(ServicesFoundView), "testExistenceOfMultiScreenManagerAttribute() castMenuView should be of tipe ServicesFoundView")
    }
    
    func testExistenceOfServicesFoundView(){
        commonVC.moreMenuView =  MoreMenuView()
        XCTAssertTrue(commonVC.moreMenuView.isKindOfClass(MoreMenuView), "testExistenceOfMultiScreenManagerAttribute() moreMenuView should be of tipe MoreMenuView")
    }
    
    func testShowCastMenuView(){
        commonVC.showCastMenuView()
        XCTAssertNotNil(commonVC.castMenuView, "testShowCastMenuView() castMenuView should be displayed and not nil")
    }
    
    func testShowSettings(){
        commonVC.showSettings()
        XCTAssertNotNil(commonVC.moreMenuView, "testShowSettings() moreMenuView should be displayed and not nil")
    }
    
    func testGetImageWithColor(){
        var image = commonVC.getImageWithColor(UIColor.whiteColor(),size: CGSize(width: 20, height: 20))
        XCTAssertTrue(image.isKindOfClass(UIImage),"testGetImageWithColor() view should be a UIImage")
    }
    
    func testDisplayAlertView(){
        commonVC.displayAlertWithTitle("Alert title", message: "Alert message")
        XCTAssertNotNil(commonVC.alertView, "testDisplayAlertView() alertView should be displayed and not nil")
    }
    
}
