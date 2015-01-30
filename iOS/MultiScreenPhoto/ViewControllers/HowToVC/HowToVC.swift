//
//  HowToVC.swift
//  MultiScreenPhoto
//
//  Created by Raul Mantilla on 29/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

class HowToVC: UIViewController {
    
    @IBOutlet weak var compatibleButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        compatibleButton.layer.cornerRadius = 2
        compatibleButton.layer.borderWidth = 0.2
        compatibleButton.layer.borderColor = UIColor.whiteColor().CGColor

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func compatibleDevices(sender: AnyObject) {
    }

    @IBAction func contactEmail(sender: AnyObject) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
