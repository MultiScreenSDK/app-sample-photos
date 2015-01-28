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

/// An Application represents an application on the TV device.
/// Use this class to control various aspects of the application such as launching the app or getting information
@objc public class Application: Channel, Printable {

    enum ApplicationType: String {
        case Application = "ms.application"
        case WebApplication = "ms.webapplication"
    }
    enum ApplicationMethod : String {
        case Get = "get"
        case Start = "start"
        case Stop = "stop"
        case Install = "install"
        func getDescription(type: ApplicationType) -> String{
            return "\(type.rawValue).\(self.rawValue)"
        }
    }

    private var clientDisconnectObserver: AnyObject?

    private var type = ApplicationType.Application

    private var restEndpoint: String! {
        return "\(service.uri)applications/\(self.uri)"
    }

    /// The id of the channel
    public private(set) var id: AnyObject!



    public init?(appId: AnyObject, channelURI: String, service: Service) {
        if channelURI.isEmpty {
            super.init()
            return nil;
        }
        switch appId {
        case let url as NSURL:
            id = url.absoluteString!
            type = .WebApplication
        case let id as String:
            self.id = id
            type = .Application
            if id.isEmpty {
                super.init()
                return nil;
            }
        default:
            super.init()
            return nil
        }
        super.init(uri: channelURI, service: service)
        clientDisconnectObserver = on(ChannelEvent.ClientDisconnect.rawValue, performClosure: clientDisconnect)
    }

    deinit {
        if clientDisconnectObserver != nil {
            off(clientDisconnectObserver!)
        }
    }

    ///  Retrieves information about the Application on the TV
    ///
    ///  :param: completionHandler The callback handler with the status dictionary and an error if any
    public func getInfo(completionHandler: (info: [String:AnyObject]?, error: NSError?) -> Void ) {
        let method = ApplicationMethod.Get.getDescription(type)
        var params = [String:AnyObject]()
        switch type {
        case .Application:
            params["id"] = id
        case .WebApplication:
            params["url"] = id
        }
        Requester.doGet(restEndpoint, headers: nil, timeout: 2) { (responseHeaders, data, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if error != nil {
                    completionHandler(info: [:], error: error)
                } else {
                    let message = JSON.parse(data!) as [String:AnyObject]
                    let rpcMessage = RPCMessage(message: message)
                    completionHandler(info: rpcMessage.result, error: rpcMessage.error)
                }
            })
        }
    }

    ///  Launches the application on the remote device, if the application is already running it returns success = true.
    ///  If the startOnConnect is set to false this method needs to be called in order to start the application
    ///
    ///  :param: completionHandler The callback handler
    public func start(completionHandler: (success: Bool, error: NSError?) -> Void ) {
        let method = ApplicationMethod.Start.getDescription(type)
        var params = [String:AnyObject]()
        switch type {
        case .Application:
            params["id"] = id
        case .WebApplication:
            params["url"] = id
        }
        sendRPC(method, params: params) { (message) -> Void in
            completionHandler(success: message.error == nil, error: message.error)
        }
    }

    ///  Stops the application on the TV
    ///
    ///  :param: completionHandler The callback handler
    public func stop(completionHandler: (success: Bool, error: NSError?) -> Void ) {
        let method = ApplicationMethod.Stop.getDescription(type)
        var params = [String:AnyObject]()
        switch type {
        case .Application:
            params["id"] = id
        case .WebApplication:
            params["url"] = id
        }
        sendRPC(method, params: params) { (message) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.disconnect({ [unowned self] (channel, error) -> Void in
                    completionHandler(success: message.error == nil, error: message.error)
                })
            })
        }
    }

    ///  Starts the application install on the TV, this method will fail for cloud applications
    ///
    ///  :param: completionHandler The callback handler
    public func install(completionHandler: (success: Bool, error: NSError?) -> Void) {
        let method = ApplicationMethod.Install.getDescription(type)
        var params = [String:AnyObject]()
        switch type {
        case .Application:
            params["id"] = id
        case .WebApplication:
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let applicationError = NSError(domain: "Application Error", code: -1, userInfo: [NSLocalizedDescriptionKey:"Install a web application is not supported"])
                completionHandler(success: false, error: applicationError)
            })
        }
        //doPut(url: String, payload: NSData!, headers: Dictionary<String,String>!, timeout: NSTimeInterval,  completionHandler: RequestCompletionHandler) -> Void
        Requester.doPut( restEndpoint , payload: nil, headers: [:], timeout: NSTimeInterval(10), completionHandler: { (responseHeaders, data, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(success: error == nil, error: error)
            })
        })

    }

    ///  Disconnects your client with the host TV app
    ///
    ///  :param: leaveHostRunning True leaves the TV app running False stops the TV app if yours is the last client
    ///  :param: completionHandler The callback handler
    public func disconnect(#leaveHostRunning: Bool, completionHandler: (channel: Channel, error: NSError?) -> Void) {
        if !leaveHostRunning && clients.count < 3 {
            stop { (success, error) -> Void in
                completionHandler(channel: self, error: error)
            }
        } else {
            self.disconnect({ (channel, error) -> Void in
                completionHandler(channel: channel,error: error)
            })
        }
    }

    ///  Disconnect from the channel and leave the host application running if leaveHostRunning is set to true and you are the last client
    ///
    ///  :param: leaveHostRunning True leaves the TV app running False stops the TV app if yours is the last client
    public func disconnect(#leaveHostRunning: Bool) {
        if !leaveHostRunning && clients.count < 3 {
            stop { (success, error) -> Void in
            }
        } else {
            self.appDisconnect()
        }
    }

    /// Disconnect from the channel and terminate the host application if you are the last client
    public override func disconnect() {
        disconnect(leaveHostRunning:false)
    }

    private func appDisconnect() {
        super.disconnect()
    }

    internal func clientDisconnect(notification: NSNotification!) {
        if let userInfo: [String:ChannelClient]? = notification.userInfo as? [String:ChannelClient] {
            if userInfo!["client"]!.isHost {
                self.disconnect()
            }
        }
    }

    override func didConnect(error: NSError?) {
        if error == nil {
            start { (success, error) -> Void in
                if error != nil {
                    // app launch error handler
                    self.delegate?.onError?(error!)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ChannelEvent.Error.rawValue, object: self, userInfo: ["error":error!]))
                }
            }
        } else {
            // websocket error handler
            super.didConnect(error)
        }
    }


    // MARK: - Printable -
    public var description: String {
        return uri
    }
}


