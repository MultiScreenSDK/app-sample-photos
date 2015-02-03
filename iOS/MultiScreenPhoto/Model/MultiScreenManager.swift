//
//  MultiScreenManager.swift
//  multiscreen-demo
//
//  Created by Raul Mantilla on 15/01/15.
//  Copyright (c) 2015 Koombea. All rights reserved.
//

import UIKit
import SystemConfiguration

class MultiScreenManager: NSObject , ServiceSearchDelegate, ChannelDelegate {
    
    var appURL: String =  "http://multiscreen.samsung.com/app-sample-photos/tv/index.html"
    var channelId: String = "com.samsung.multiscreen.photos"
    var app : Application!
    let search = Service.search()
    var wifiTimer: NSTimer!
    
    class var sharedInstance: MultiScreenManager {
        struct Static {
            static var instance: MultiScreenManager?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = MultiScreenManager()
        }
        
        return Static.instance!
    }
    
    override init() {
    }
    
    // Start the TV discovery process
    func startSearching(){
        search.delegate = self
        search.start()
        // Start a timer to check if there is Wifi connection available to connect
        //wifiTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("checkWifiConnection"), userInfo: nil, repeats: true)
    }
    
    // Stop the TV discovery process
    func StopSearching(){
        search.stop()
        postNotification()
    }
    
    
    // Check is there is an app connected
    func isApplicationConnected()->Bool {
        return app != nil && app!.isConnected;
    }
    
    //Return the current service connected
    func getApplicationCurrentService()->Service{
        return app.service
    }
    
    //Return all services found
    func getServices() -> [Service]{
        return search.services
    }
    
    //Return all services not current connected
    func getServicesNotConnected() -> [Service]{
        
        var servicesArray = [Service]()
        for (value) in getServices() {
            if(isApplicationConnected() == true){
                if(getApplicationCurrentService().id != value.id){
                    servicesArray.append(value)
                }
            }else{
                servicesArray.append(value)
            }
        }
        return servicesArray
    }
    
    // Return a service by index
    func getServiceWithIndex(index : Int)->Service{
        return search.services[index]
    }
    
    //onServiceLost delegate method
    func onServiceLost(service: Service) {
        // Post a notification
        postNotification()
    }
    
    //onServiceFound delegate method
    func onServiceFound(service: Service) {
        // Post a notification
        postNotification()
    }
    
    // Send a notification to update the cast icon
    func postNotification(){
        NSNotificationCenter.defaultCenter().postNotificationName("updateCastButton", object: self)
    }
    
    // Creates an application
    func createApplication(service: Service,completionHandler: ((Bool!) -> Void)!){
        app = service.createApplication(NSURL(string: appURL)!, channelURI: channelId)!
        app.connect(["name":UIDevice.currentDevice().name])
        app.start { (success, error) -> Void in
            completionHandler(success)
        }
    }
    
    // Close the current connected application
    func closeApplication(completionHandler: ((Bool!) -> Void)!){
        app.stop({ (success, error) -> Void in })
        app.disconnect({ (channel, error) -> Void in
            if(error == nil){
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        })
    }
    
    // send Photo the the connected TV
    func sendPhotoToTv(image :UIImage){
        if (isApplicationConnected()){
            app.publish(event: "showPhoto", message: nil, data: UIImageJPEGRepresentation(image,0.6))
        }
    }
    
    //Check if there is Wifi connection available to connect
    //Start and stop searching for services in the same wifi network
    func checkWifiConnection() {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            StopSearching()
        }
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let isWWAN = (flags & UInt32(kSCNetworkReachabilityFlagsIsWWAN)) != 0
        
        // If Wifi is available then start searching for services in the network
        if(isReachable && !isWWAN){
            if (!isApplicationConnected()){
                StopSearching()
                startSearching()
            }
        }else{
            StopSearching()
        }
    }
    
}
