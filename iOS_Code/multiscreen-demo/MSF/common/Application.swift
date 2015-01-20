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

    var _id: AnyObject!

    /// The id of the channel
    public var id: AnyObject! {
        return _id
    }

    /// Auto starts the application when connect is called
    public var startOnConnect = true

    /// Stops the application when disconnect is called and your client is the last client connected
    public var stopOnDisconnect = true

    /// Disconnects your client when the host connection ends (when the host application is exited)
    public var disconnectWithHost = true

    public init?(appId: AnyObject, channelURI: String, service: Service) {
        if channelURI.isEmpty {
            super.init()
            return nil;
        }
        switch appId {
        case let url as NSURL:
            _id = url.absoluteString!
            type = .WebApplication
        case let id as String:
            _id = id
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
            params["id"] = _id
        case .WebApplication:
            params["url"] = _id
        }
        sendRPC(method, params: params) { (message) -> Void in
            completionHandler(info: message.result, error: message.error)
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
            params["id"] = _id
        case .WebApplication:
            params["url"] = _id
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
            params["id"] = _id
        case .WebApplication:
            params["url"] = _id
        }
        sendRPC(method, params: params) { (message) -> Void in
            completionHandler(success: message.error == nil, error: message.error)
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
            params["id"] = _id
        case .WebApplication:
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let applicationError = NSError(domain: "Application Error", code: -1, userInfo: [NSLocalizedDescriptionKey:"Install a web application is not supported"])
                completionHandler(success: false, error: applicationError)
            })
        }
        sendRPC(method, params: params) { (message) -> Void in
            completionHandler(success: message.error == nil, error: message.error)
        }
    }

    public override func disconnect() {
        if stopOnDisconnect && clients.count < 3 {
            stop { [unowned self](success, error) -> Void in
                self.appDisconnect()
            }
        } else {
            super.disconnect()
        }
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
        super.didConnect(error)
        if error == nil && startOnConnect {
            start  { (success, error) -> Void in
                if error != nil {
                    self.delegate?.onError?(error!)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ChannelEvent.Error.rawValue, object: self, userInfo: ["error":error!]))
                }

            }
        }
    }

    
    // MARK: - Printable -
    public var description: String {
        return uri
    }
}


