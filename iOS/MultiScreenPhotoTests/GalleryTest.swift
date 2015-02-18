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
    var album : ALAssetsGroup!
    
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
    
    func testGetNumOfAlbums(){
        gallery.albums = [album,album,album]
        XCTAssertEqual(gallery.getNumOfAlbums(),3, "GetNumOfAlbums() will return the numbers of albums in gallery album")
    }
    
    func testGetNumOfAlbumsWhenGalleryAlbumsArrayIsEmpty(){
        gallery.albums = []
        XCTAssertEqual(gallery.getNumOfAlbums(),0, "testGetNumOfAlbumsWhenGalleryAlbumsArrayIsEmpty() will return 0")
    }
    
    func testSetNumOfAssetsByAlbum(){
        let albumIndex = 0
        gallery.numOfAssetsByalbum = []
        gallery.setNumOfAssetsByAlbum(albumIndex, count: 50)
        XCTAssertEqual(gallery.getNumOfAssetsByAlbum(0),50, "testSetNumOfAssetsByAlbum() will save the count of assets to 50 and return 50")
    }
    
    
    func testGetNumOfAssetsByAlbum(){
        let albumIndex = 0
        gallery.numOfAssetsByalbum = []
        gallery.setNumOfAssetsByAlbum(albumIndex, count: 50)
        XCTAssertEqual(gallery.getNumOfAssetsByAlbum(0),50, "getNumOfAssetsByAlbum() will return 50")
    }
    
    func testGetNumOfAssetsByAlbumsWhenNumOfAssetByAlbumsArrayIsEmpty(){
        let albumIndex = 0
        gallery.numOfAssetsByalbum = []
        gallery.setNumOfAssetsByAlbum(albumIndex, count:0)
        XCTAssertEqual(gallery.getNumOfAssetsByAlbum(0),0, "testGetNumOfAssetsByAlbumsWhenNumOfAssetByAlbumsArrayIsEmpty() will return 0")
    }
    
    func testSetIsAlbumExpanded(){
        let albumIndex = 0
        gallery.isAlbumExpanded = []
        gallery.setIsAlbumExpanded(albumIndex, isExpanded: true)
        XCTAssertTrue(gallery.getIsAlbumExpanded(albumIndex), "setIsAlbumExpanded() will return true")
    }
    
    func testGetIsAlbumExpanded(){
        let albumIndex = 0
        gallery.isAlbumExpanded = []
        gallery.setIsAlbumExpanded(albumIndex, isExpanded: false)
        XCTAssertTrue(gallery.getIsAlbumExpanded(albumIndex), "getIsAlbumExpanded() will return false")
    }
   
    
}
