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
import SystemConfiguration

/// A MultiScreenManager represents an instance of MultiScreenFramework

/// Use this class to search for near services, connect to a service and send photo to a service
class MultiScreenManager: NSObject, ServiceSearchDelegate, ChannelDelegate {
    
    /// Application url
    var appURL: String =  "http://multiscreen.samsung.com/app-sample-photos/tv/index.html"
    /// Application Channel
    var channelId: String = "com.samsung.multiscreen.photos"
    /// Application instance
    var app: Application!
    /// Search service instance
    let search = Service.search()
    
    /// Name of the observer identifier for services found
    let servicesChangedObserverIdentifier: String = "servicesChanged"
    
    /// Name of the observer identifier for service connected
    let serviceConnectedObserverIdentifier: String = "serviceConnected"
    
    /// Array of services/TVs
    var services = [Service]()
    

    /// returns the status if the channel/app is connected
    var isConnected: Bool {
        get {
           return app != nil && app!.isConnected;
        }
    }
    
    /// returns the currently connected service
    var currentService: Service {
        get {
            return app.service
        }
    }
    
    /// MultiScreenManager shared instance used as singleton
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
        super.init()
        search.delegate = self
    }
    
    /// Post a notification to the NSNotificationCenter
    /// this notification is used to update the cast icon
    func postNotification(){
        NSNotificationCenter.defaultCenter().postNotificationName(servicesChangedObserverIdentifier, object: self)
    }
    
    /// Start the search for services/TVs
    func startSearching(){
        search.start()
    }
    
    /// Stop the search for services/TVs
    func stopSearching(){
        search.stop()
        services.removeAll(keepCapacity: false)
        /// post a notification to the NSNotificationCenter
        postNotification()
    }
    
    /// onServiceLost delegate method
    func onServiceLost(service: Service) {
        removeObject(&services, object: service)
        /// post a notification to the NSNotificationCenter
        postNotification()
    }
    
    /// onServiceFound delegate method
    func onServiceFound(service: Service) {
        services.append(service)
        /// post a notification to the NSNotificationCenter
        postNotification()
    }
    
    func removeObject<T: Equatable>(inout arr: Array<T>, object: T) -> T? {
        if let found = find(arr, object) {
            return arr.removeAtIndex(found)
        }
        return nil
    }
    
    //MARK: - ChannelDelegate -
    
    func onError(error: NSError) {
        println(error.localizedDescription)
    }
    
    func onConnect(client: ChannelClient, error: NSError?) {
        if (error == nil) {
            stopSearching()
            NSNotificationCenter.defaultCenter().postNotificationName(serviceConnectedObserverIdentifier, object: self)
            /// post a notification to the NSNotificationCenter
            postNotification()
        }
    }
    
    func onDisconnect(client: ChannelClient, error: NSError?) {
        startSearching()
        /// post a notification to the NSNotificationCenter
        postNotification()
    }
    
    /// Return all services availables but not currently connected
    ///
    /// :return: Array of Services
    func servicesNotConnected() -> [Service]{
        
        var servicesArray = [Service]()
        for (value) in services {
            /// Check if the application is connected
            if (isConnected == true){
                /// if the application is connected ignore the current service
                if (currentService.id != value.id){
                    servicesArray.append(value)
                }
            } else{
                servicesArray.append(value)
            }
        }
        return servicesArray
    }
    
   
    /// Connect to an Application
    ///
    /// :param: selected service
    /// :param: completionHandler The callback handler,  return true or false
    func createApplication(service: Service, completionHandler: ((Bool!) -> Void)!){
        app = service.createApplication(NSURL(string: appURL)!, channelURI: channelId, args: ["cmd line params": "cmd line values"])
        app.delegate = self
        app.connectionTimeout = 30
        app.connect(["name": UIDevice.currentDevice().name], completionHandler: { (client, error) -> Void in
            if (error == nil){
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        })
    }
    
    /// Close the current connected application
    ///
    /// :param: completionHandler The callback handler,  return true or false
    func closeApplication(completionHandler: ((Bool!) -> Void)!){
        app.disconnect({ (channel, error) -> Void in
            if (error == nil){
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        })
    }
    
    /// Send Photo the the connected Service
    ///
    /// :param: UIImage to be sent
    func sendPhotoToTv(image: UIImage){
        if (isConnected){
            app.publish(event: "showPhoto", message: nil, data: UIImageJPEGRepresentation(image, 0.6), target: MessageTarget.Host.rawValue)
        }
    }
    
}
