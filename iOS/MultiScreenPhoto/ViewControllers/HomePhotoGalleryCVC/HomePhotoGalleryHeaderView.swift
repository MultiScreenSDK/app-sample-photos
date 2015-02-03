//
//  HomePhotoGalleryHeaderView.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 2/02/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
protocol HomePhotoGalleryHeaderViewDelegate {
    func expandSection(section : Int)
    func collapseSection(section : Int)
}

class HomePhotoGalleryHeaderView: UIView {

    @IBOutlet weak var headerTitle: UIButton!
    @IBOutlet weak var imageViewArrow: UIImageView!
    @IBOutlet weak var imageViewSeparator : UIImageView!
    
    var delegate: HomePhotoGalleryHeaderViewDelegate!
    var section = 0
    var state = false
    
    
    override func drawRect(rect: CGRect)
    {
        
        /*var image: UIImage
        
        if(state == false){
            image = UIImage(named: "icon-arrow-down")!
        }else{
            image = UIImage(named: "icon-arrow-up")!
        }
        imageViewArrow.image = image
        
        if(section == 0){
            imageViewSeparator.hidden = true
        }
*/
        
    }
    
    @IBAction func selectedButton(sender: UIButton) {
        
        if(state == false){
            state = true
            delegate.expandSection(self.section)
        }else{
            state = false
            delegate.collapseSection(self.section)
        }
    }
    

}
