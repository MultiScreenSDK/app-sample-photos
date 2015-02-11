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


enum ServiceSearchProviderType: String {
    case MDNS = "com.samsung.multiscreen.searchprovider.mdns"
    case BLE = "com.samsung.multiscreen.searchprovider.ble"
    case CLOUD = "com.samsung.multiscreen.searchprovider.cloud"
    case MSF = "com.samsung.multiscreen.searchprovider.msf"
}

///  ServiceSearchProvider implementations should use this delegate to
///  consolidate the search results in a ServiceSearch instance
internal protocol ServiceSearchProviderDelegate: class {
    ///  ServiceSearchProvider will call this delegate method when a service is found
    ///  the delegate object must append the service to the services list if is not
    ///
    ///  :param: service The found service
    ///
    ///  :param: provider: Service Search Provider
    func onServiceFound(service: Service, provider:ServiceSearchProvider)

    ///  ServiceSearchProvider will call this delegate method when a service is lost
    ///  the delegate object must remove the service if there are not more search
    ///  providers for the service
    ///
    ///  :param: serviceId The service id
    ///
    ///  :param: provider Service Search Provider
    func onServiceLost(serviceId: String, provider:ServiceSearchProvider)

    ///  The ServiceSearch will call this delegate method after stopping the search
    func onStop(provider:ServiceSearchProvider)

    ///   The ServiceSearch will call this delegate method after the search has started
    func onStart(provider:ServiceSearchProvider)

    func clearCacheForProvider(provider:ServiceSearchProvider)
}

///  Implement this protocol in order to extend the service search functionality
///  with a new discovery mechanism
internal protocol ServiceSearchProvider: class {

    var type: ServiceSearchProviderType! {get}

    // The status of the search
    var isSearching: Bool {get}

    // The intializer
    init(delegate: ServiceSearchProviderDelegate, id: String?)

    /// Start the search
    func search()

    /// Stops the search
    func stop()
}

internal class ServiceSearchProviderBase: NSObject, ServiceSearchProvider {
    // An optional id to parametrize the search
    var id: String?

    var type: ServiceSearchProviderType!

    // The status of the search
    var isSearching: Bool = false

    weak var delegate: ServiceSearchProviderDelegate? = nil

    // The intializer
    required init(delegate: ServiceSearchProviderDelegate, id: String?) {
        self.delegate = delegate
        self.id = id
    }

    /// Start the search
    func search() {}

    /// Stops the search
    func stop() {}

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

    internal var discoveryProviders: [ServiceSearchProvider] = []

    private let accessQueue = dispatch_queue_create("SynchronizedAccess", DISPATCH_QUEUE_SERIAL)

    private var discoveryProvidersTypes: [ServiceSearchProviderBase.Type ] = [ MDNSDiscoveryProvider.self, MSFDiscoveryProvider.self]

    private var started = false

    /// Set a delegate to receive search events.
    public var delegate: ServiceSearchDelegate? = nil

    // The cache list of service
    private var servicesCache: [Service] = []

    /// The search status
    public var isSearching: Bool  {
        get {
            var searching = false
            for index in 0 ..< self.discoveryProviders.count {
                if (self.discoveryProviders[index].isSearching) {
                    searching = true
                    break
                }
            }
            return searching
        }
    }

    public func getServices() -> [Service] {
        return NSArray(array: self.servicesCache) as [Service]
    }

    internal init () {
        setup(nil)
    }

    internal init(id: String) {
        setup(id)
    }

    func setup(id: String?) {
        let objectType = String.self
        let newObject: String = objectType("")

        for provider in discoveryProvidersTypes {
            var providerInstance = provider(delegate: self, id: id)
            discoveryProviders.append(providerInstance)
        }
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
        dispatch_async(self.accessQueue) { [unowned self] in
            for index in 0 ..< self.discoveryProviders.count {
                if (!self.discoveryProviders[index].isSearching) {
                    self.discoveryProviders[index].search()
                }
            }
        }
    }

    /// Stops the search
    public func stop() {
        dispatch_async(self.accessQueue) { [unowned self] in
            NSNotificationCenter.defaultCenter().removeObserver(self)
            for index in 0 ..< self.discoveryProviders.count {
                if (self.discoveryProviders[index].isSearching) {
                    self.discoveryProviders[index].stop()
                }
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

    func onServiceFound(service: Service, provider:ServiceSearchProvider) {
        dispatch_async(self.accessQueue) { [unowned self] in
            if let found = find(self.servicesCache, service) { // ignore the service
                self.servicesCache[found].providers.addObject(provider.type.rawValue)
                return
            }
            service.providers.addObject(provider.type.rawValue)
            self.servicesCache.append(service)
            dispatch_async(dispatch_get_main_queue()) { [unowned self]  () -> Void in
                self.delegate?.onServiceFound?(service)
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: MSDidFindService, object: self, userInfo: ["finder":self,"service":service]))
            }
        }
    }

    func onServiceLost(serviceId: String, provider:ServiceSearchProvider) {
        dispatch_async(self.accessQueue) { [unowned self] in
            let found = self.servicesCache.filter{$0.id == serviceId}
            if found.count > 0 {
                let service = found[0]
                service.getDeviceInfo(5, completionHandler: { (deviceInfo, error) -> Void in
                    if error != nil || deviceInfo == nil {
                        dispatch_async(self.accessQueue) { [unowned self] in
                            self.removeObject(&self.servicesCache, object: service)
                            dispatch_async(dispatch_get_main_queue()) { [unowned self]  () -> Void in
                                self.delegate?.onServiceLost?(service)
                                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: MSDidRemoveService, object: self, userInfo: ["finder":self,"service":service]))
                            }
                        }
                    }
                })
            }
        }
    }

    func onStop(provider:ServiceSearchProvider) {
        dispatch_async(self.accessQueue) { [unowned self] in
            if !self.isSearching {
                self.started = false
                self.servicesCache.removeAll(keepCapacity: false)
                dispatch_async(dispatch_get_main_queue()) { [unowned self]  () -> Void in
                    self.delegate?.onStop?()
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: MSDidStopSeach, object: self))
                }
            }
        }
    }

    func onStart(provider:ServiceSearchProvider) {
        dispatch_async(self.accessQueue) { [unowned self] in
            if !self.started {
                self.started = true
                dispatch_async(dispatch_get_main_queue()) { [unowned self]  () -> Void in
                    self.delegate?.onStart?()
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: MSDidStartSeach, object: self))
                }
            }
        }
    }

    func clearCacheForProvider(provider: ServiceSearchProvider) {
        dispatch_async(self.accessQueue) { [unowned self] in
            for service: Service in self.servicesCache {
                self.onServiceLost(service.id, provider: provider)
            }
        }
    }
}