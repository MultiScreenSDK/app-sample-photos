/*

Copyright (c) 2014 Samsung Electronics

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/
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
