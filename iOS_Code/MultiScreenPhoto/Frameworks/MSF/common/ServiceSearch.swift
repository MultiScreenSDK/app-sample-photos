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

public let MSDidFindService = "ms.didFindService"
public let MSDidRemoveService = "ms.didRemoveService"
public let MSDidStopSeach = "ms.stopSearch"
public let MSDidStartSeach = "ms.startSearch"

///  ServiceSearchProvider implementations should use this delegate to
///  consolidate the search results in a ServiceSearch instance
protocol ServiceSearchProviderDelegate: class {
    ///  ServiceSearchProvider will call this delegate method when a service is found
    ///  the delegate object must append the service to the services list if is not
    ///
    ///  :param: service The founded service
    func onServiceFound(service: Service)

    ///  ServiceSearchProvider will call this delegate method when a service is lost
    ///  the delegate object must remove the service if there are not more search 
    ///  providers for the service
    ///
    ///  :param: serviceId The service id
    func onServiceLost(serviceId: String)

    ///  The ServiceSearch will call this delegate method after stopping the search
    func onStop()

    ///   The ServiceSearch will call this delegate method after the search has started
    func onStart()
}

///  Implement this protocol in order to extend the service search functionality
///  with a new discovery mechanism
protocol ServiceSearchProvider: class {

    // The status of the search
    var isSearching: Bool {get}

    // The intializer
    init(delegate: ServiceSearchProviderDelegate)

    // The intializer
    init(delegate: ServiceSearchProviderDelegate, id: String)

    /// Start the search
    func search()

    /// Stops the search
    func stop()
}

///  This protocol defines the methods for ServiceSearch discovery
@objc public protocol ServiceSearchDelegate {
    ///  The ServiceSearch will call this delegate method when a service is found
    ///
    ///  :param: service The found service
    optional func onServiceFound(service: Service)

    ///  The ServiceSearch will call this delegate method when a service is lost
    ///
    ///  :param: service The lost service
    optional func onServiceLost(service: Service)

    ///  The ServiceSearch will call this delegate method after stopping the search
    optional func onStop()

    ///   The ServiceSearch will call this delegate method after the search has started
    optional func onStart()
}

///  This class searches the local network for compatible multiscreen services
@objc public class ServiceSearch: ServiceSearchProviderDelegate {

    private var discoveryProviders: [ServiceSearchProvider] = []

    /// Set a delegate to receive search events.
    public var delegate: ServiceSearchDelegate? = nil

    // The list of available services
    public var services: [Service] = []

    /// The search status
    public var isSearching: Bool  {
        get {
            var searching = false
            for index in 0 ..< discoveryProviders.count {
                if (discoveryProviders[index].isSearching) {
                    searching = true
                    break
                }
            }
            return searching
        }
    }

    internal init () {
        discoveryProviders.append(MDNSDiscoveryProvider(delegate: self))
    }

    internal init(id: String) {
        discoveryProviders.append(MDNSDiscoveryProvider(delegate: self, id: id))
    }

    ///  A convenience method to suscribe for notifications using blocks
    ///
    ///  :param: notificationName: The name of the notification
    ///  :param: performClosure:   The notification block, this block will be executed in the main thread
    ///
    ///  :returns: An observer handler for removing/unsubscribing the block from notifications
    public func on(notificationName: String, performClosure:(NSNotification!) -> Void) -> AnyObject {
        return NSNotificationCenter.defaultCenter().addObserverForName(notificationName, object: self, queue: NSOperationQueue.mainQueue(), usingBlock: performClosure)
    }

    ///  A convenience method to unsuscribe from notifications
    ///
    ///  :param: observer: The observer object to unregister observations
    public func off(observer: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }

    /// Start the search
    public func start() {
        for index in 0 ..< discoveryProviders.count {
            if (!discoveryProviders[index].isSearching) {
                discoveryProviders[index].search()
            }
        }
    }

    /// Stops the search
    public func stop() {
        for index in 0 ..< discoveryProviders.count {
            if (discoveryProviders[index].isSearching) {
                discoveryProviders[index].stop()
            }
        }
    }

    func removeObject<T:Equatable>(inout arr:Array<T>, object:T) -> T? {
        if let found = find(arr,object) {
            return arr.removeAtIndex(found)
        }
        return nil
    }

    // MARK: - DiscoveryProviderDelegate -

    func onServiceFound(service: Service) {
        if let found = find(services, service) { // ignore the service
            return
        }
        services.append(service)
        delegate?.onServiceFound?(service)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: MSDidFindService, object: self, userInfo: ["finder":self,"service":service]))
    }

    func onServiceLost(serviceId: String) {
        let found = services.filter{$0.id == serviceId}
        if found.count > 0 {
            let service = found[0]
            removeObject(&services, object: service)
            delegate?.onServiceLost?(service)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: MSDidRemoveService, object: self, userInfo: ["finder":self,"service":service]))
        }
    }

    func onStop() {
        services.removeAll(keepCapacity: false)
        delegate?.onStop?()
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: MSDidStopSeach, object: self))
    }

    func onStart() {
        services.removeAll(keepCapacity: false)
        delegate?.onStart?()
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: MSDidStartSeach, object: self))
    }

}