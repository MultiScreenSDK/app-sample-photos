//
//  TVIntegration.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 15/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit

class TVIntegration: NSObject , ServiceSearchDelegate, ChannelDelegate {
    
    var appURL: String =  "http://multiscreen.samsung.com/app-sample-photos/tv/index.html"
    var channelId: String = "com.samsung.multiscreen.photos"
    var app : Application!
    let search = Service.search()
    var isConnected = false
    var connectionName = String()
    
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
    
    func isApplicationConnected()->Bool {
        return isConnected;
    }
    
    func getServices() -> [Service]{
        return search.services
    }
    
    func getServiceWithIndex(index : Int)->Service{
        return search.services[index]
    }
    
    func onServiceLost(service: Service) {
        println("SERVICE OUT NAME : \(service.name)")
        // Post a notification
        NSNotificationCenter.defaultCenter().postNotificationName("updateCastButton", object: self)
    }
    
    func onServiceFound(service: Service) {
        println("SERVICE IN NAME : \(service.name)")
        // Post a notification
        NSNotificationCenter.defaultCenter().postNotificationName("updateCastButton", object: self)
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
    
    func createApplication(service: Service,completionHandler: ((Bool!) -> Void)!){
        
        app = service.createApplication(NSURL(string: appURL)!, channelURI: channelId)!
        app.connect(["name":UIDevice.currentDevice().name])
        app.start { (success, error) -> Void in
           self.isConnected = success
           completionHandler(success)
        }
    }
    
    
    func closeApplication(completionHandler: ((Bool!) -> Void)!){
        app.stop({ (success, error) -> Void in })
        app.disconnect({ (channel, error) -> Void in
            if(error == nil){
                self.isConnected = false
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        })
        tvIntegration.connectionName = ""
    }
    
    func sendPhotoToTv(image :UIImage){
        if (isConnected){
            app.publish(event: "showPhoto", message: nil, data: UIImageJPEGRepresentation(image,0.6))
        }
    }
}
