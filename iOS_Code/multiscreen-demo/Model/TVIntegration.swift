//
//  TVIntegration.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 15/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

class TVIntegration: NSObject , ServiceSearchDelegate, ChannelDelegate {
    
    var appURL: String = "http://prod-multiscreen-examples.s3-website-us-west-1.amazonaws.com/examples/helloworld/tv/"
    var channelId: String = "com.samsung.multiscreen.helloworld"
    
    let search = Service.search()
    var app: Application!
    var isConnecting = false
    
    class var sharedInstance: TVIntegration {
        struct Static {
            static var instance: TVIntegration?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = TVIntegration()
        }
        
        return Static.instance!
    }
   
    override init() {
    }
    
    func start(){
        // Start the TV discovery process
        search.delegate = self
        search.start()
        
        // Adding an observer
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceChanged", name: "serviceChanged", object: nil)

    }
    
    func getServices() -> [Service]{
        return search.services
    }
    
    func onServiceLost(service: Service) {
        println("SERVICE OUT NAME : \(service.name)")
        // Post a notification
       // NSNotificationCenter.defaultCenter().postNotificationName("serviceChanged", object: nil)
    }
    
    func onServiceFound(service: Service) {
        println("SERVICE IN NAME : \(service.name)")
        // Post a notification
        //NSNotificationCenter.defaultCenter().postNotificationName("serviceChanged", object: nil)
    }
    
    private func updateCastStatus() {
        /*
        var castStatus = CastStatus.notReady
        if app != nil && app!.isConnected {
            castStatus = CastStatus.connected
        } else if isConnecting {
            castStatus = CastStatus.connecting
        } else if search.services.count > 0 {
            castStatus = CastStatus.readyToConnect
        }
        castButton.castStatus = castStatus
*/
    }
    
}
