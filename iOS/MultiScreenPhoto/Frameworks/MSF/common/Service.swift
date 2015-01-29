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

import Foundation

public typealias GetServiceCompletionHandler = (service: Service?, error: NSError? ) -> Void

///  A Service instance represents the multiscreen service root on the remote device
///  Use the class to control top level services of the device
///
@objc public class Service : Printable, Equatable {

    internal var transportType: ChannelTransportType

    internal var requireRechabilty = false

    internal var usePublicURI = false

    private var discoveryRecord: [String:String]

    /// The id of the service
    public var id: String {
        return discoveryRecord["id"]!
    }

    /// The uri of the service (http://<ip>:<port>/api/v2/)
    public var uri: String {
        if usePublicURI && discoveryRecord["pse"] != nil && discoveryRecord["pse"]! != "undefined" {
            return discoveryRecord["pse"]!
        }
        return discoveryRecord["se"]!
    }

    /// The name of the service (Living Room TV)
    public var name: String {
        return discoveryRecord["fn"]!
    }

    /// The version of the service (x.x.x)
    public var version: String {
        return discoveryRecord["ve"]!
    }

    /// The type of the service (Samsung SmartTV)
    public var type: String {
        return discoveryRecord["md"]!
    }

    /// The service description
    public var description: String {
        get {
            return "id: \(id) name: \(name) version: \(version)"
        }
    }

    /// Initializer
    ///
    internal init(txtRecordDictionary: Dictionary<String,String>) {
        discoveryRecord = txtRecordDictionary
        //    device = nil
        transportType = ChannelTransportType.WebSocket
    }

    ///  This asynchronously method retrieves a dictionary of additional information about the device the service is running on
    ///
    ///  :param: completionHandler: A block to handle the response dictionary
    ///
    ///     - deviceInfo: The device info dictionary
    ///     - error: An error info if getDeviceInfo failed
    public func getDeviceInfo(completionHandler: (deviceInfo: [String:String]?, error: NSError?) -> Void ) {
        let doGetCompletionHandler : RequestCompletionHandler = { (responseHeaders: Dictionary<String,String>?, data: NSData?, error: NSError?)  in

            if error != nil {
                completionHandler(deviceInfo: nil, error: error)
            } else {
                var err: NSError?
                let jsonResult : [String:String]? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &err) as? [String:String]

                completionHandler(deviceInfo: jsonResult, error: err)
            }
        }
        Requester.doGet(uri, headers: [:] , timeout: 10, completionHandler: doGetCompletionHandler)
    }

    ///  Creates an application instance belonging to that service
    ///
    ///  :param: id The id of the application
    ///
    ///   - For an installed application this is the string id as provided by Samsung, If your TV app is still in development, you can use the folder name of your app as the id. Once the TV app has been released into Samsung Apps, you must use the supplied app id.`
    ///   - For a cloud application this is the application's URL
    ///
    ///  :param: channelURI The uri of the Channel ("com.samsung.multiscreen.helloworld")
    ///
    ///  :returns: An Application instance or nil if application id or channel id is empty
    public func createApplication(id: AnyObject, channelURI: String) -> Application? {
        return Application(appId: id, channelURI: channelURI, service: self)
    }

    ///  Creates a channel instance belonging to that service ("mychannel")
    ///
    ///  :param: ` The uri of the Channel ("com.samsung.multiscreen.helloworld")
    ///
    ///  :returns: A Channel instance
    public func createChannel(channelURI: String) -> Channel {
        return Channel(uri: channelURI , service: self)
    }

    //MARK: - class methods -

    ///  Creates a service search object
    ///
    ///  :returns: An instance of ServiceSearch
    public class func search() -> ServiceSearch {
        return ServiceSearch()
    }

    ///  This asynchronous method retrieves a service instance given a service URI
    ///
    ///  :param: uri: The uri of the service
    ///  :param: completionHandler: The completion handler with the service instance or an error
    ///
    ///   - service: The service instance
    ///   - timeout: The timeout for the request
    ///   - error: An error info if getByURI fails
    public class func getByURI(uri: String, timeout: NSTimeInterval, completionHandler: (service: Service?, error: NSError? ) -> Void)  {
        let doGetCompletionHandler : RequestCompletionHandler = {(responseHeaders: Dictionary<String,String>?, data: NSData?, error: NSError?)  in
            if error != nil {
                completionHandler(service: nil, error: error)
            } else {
                var err: NSError?
                let jsonResult : NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                //let device = Device(info: jsonResult["device"] as Dictionary)
                var txtRecordDictionary = [String:String]()
                txtRecordDictionary["fn"] = jsonResult["name"] as? String
                txtRecordDictionary["se"] = jsonResult["uri"] as? String
                txtRecordDictionary["ve"] = jsonResult["version"] as? String
                txtRecordDictionary["ip"] = jsonResult["device"]?["ip"] as? String
                txtRecordDictionary["md"] = jsonResult["device"]?["model"] as? String
                txtRecordDictionary["id"] = jsonResult["id"] as? String
                let service = Service(txtRecordDictionary: txtRecordDictionary)
                completionHandler(service: service, error: nil)
            }
        }

        Requester.doGet(uri, headers: Dictionary<String,String>() , timeout: 2, completionHandler: doGetCompletionHandler)
    }

    ///  This asynchronous method retrieves a service instance given a service id
    ///
    ///  :param: id: The id of the service
    ///  :param: completionHandler: The completion handler with the service instance or an error
    ///
    ///   - service: The service instance
    ///   - error: An error info if getById fails
    public class func getById(id: String, completionHandler: (service: Service?, error: NSError? ) -> Void) {
        var findObserver: AnyObject?
        var stopObserver: AnyObject?
        var search = ServiceSearch(id: id)
        stopObserver = search.on(MSDidStopSeach) { (notification) -> Void in
            search.off(findObserver!)
            search.off(stopObserver!)
            let searchError = NSError(domain: "Service Search Error", code: -1, userInfo: [NSLocalizedDescriptionKey:"Operation timeout"])
            completionHandler(service: nil, error: searchError)
        }
        findObserver = search.on(MSDidFindService) { (notification) -> Void in
            search.off(findObserver!)
            search.off(stopObserver!)
            let error: NSError? = notification!.userInfo?["error"] as? NSError
            let service: Service? = notification!.userInfo?["service"] as? Service
            completionHandler(service: service, error: error)
        }
        search.start()
    }

}

public func == (lhs: Service, rhs: Service) -> Bool {
    return lhs.id == rhs.id
}
