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

class MDNSDiscoveryProvider: ServiceSearchProviderBase, NSNetServiceBrowserDelegate, NSNetServiceDelegate {

    // The service domain
    private let ServiceDomain = "local"

    // The multiscreen service type
    private let ServiceType = "_samsungmsf._tcp."

    // The raw network service (since the NetServices delegation methods are call in the main thread there is no need for a thread safe array)
    private var netServices = [NSNetService]()

    private var retryResolve = NSMutableSet()

    // The service browser
    private let serviceBrowser = NSNetServiceBrowser()

    required init(delegate: ServiceSearchProviderDelegate, id: String?) {
        super.init(delegate: delegate, id: id)
        type = ServiceSearchProviderType.MDNS
        serviceBrowser.delegate = self
    }

    // The deinitializer
    deinit {
        serviceBrowser.delegate = nil
    }

    // Start the search
    override func search() {
        // Cancel the previous search if any
        if isSearching {
            serviceBrowser.stop()
        }

        if id == nil {
            serviceBrowser.searchForServicesOfType(ServiceType, inDomain: ServiceDomain)
            //serviceBrowser.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        } else {
            var aNetService = NSNetService(domain: ServiceDomain, type: ServiceType, name: id!)
            netServiceBrowser(nil, didFindService: aNetService, moreComing: false)
        }

    }

    // Stops the search
    override func stop() {
        isSearching = false
        serviceBrowser.stop()
    }

    // MARK: - Service -

    func removeObject<T:Equatable>(inout arr:Array<T>, object:T) -> T? {
        if let found = find(arr,object) {
            return arr.removeAtIndex(found)
        }
        return nil
    }

    private func removeService(aNetService: NSNetService!) {
        removeObject(&netServices, object: aNetService)
    }

    // MARK: - NSNetServiceBrowserDelegate  -

    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        isSearching = true
        delegate?.onStart(self)
    }

    func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        delegate?.clearCacheForProvider(self)
        netServices.removeAll(keepCapacity: false) // clear the cache
        if isSearching {
            search()
        } else {
            delegate?.onStop(self)
        }
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser!, didNotSearch errorDict: [NSObject : AnyObject]!) {
        serviceBrowser.stop()
        netServiceBrowserDidStopSearch(aNetServiceBrowser)
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser!, didFindService aNetService: NSNetService!, moreComing: Bool) {
        if let found = find(netServices, aNetService) {
            println("ignoring \(netServices[found].name)")
        } else {
            aNetService.delegate = self
            aNetService.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            aNetService.resolveWithTimeout(NSTimeInterval(2))
            netServices.append(aNetService)
        }
    }

    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser!, didRemoveService aNetService: NSNetService!, moreComing: Bool) {
        aNetService.stop()
        aNetService.delegate = nil
        removeService(aNetService)
        delegate?.onServiceLost(aNetService.name, provider: self)
    }

    // MARK: - NSNetServiceDelegate  -

    func netService(aNetService: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        if id != nil {
            delegate?.onStop(self)
        } else if retryResolve.containsObject(aNetService.name) {
            retryResolve.removeObject(aNetService.name)
            removeService(aNetService)
        } else {
            retryResolve.addObject(aNetService.name)
            aNetService.resolveWithTimeout(NSTimeInterval(15))
        }
    }

    func netServiceDidResolveAddress(aNetService: NSNetService!) {
        //The text record have the API root URI so the implementer can contruct the REST endpoint for App management
        if aNetService.addresses!.count > 0 {
            let txtRecord : NSDictionary = NSNetService.dictionaryFromTXTRecordData(aNetService.TXTRecordData()) as NSDictionary
            var info: [String:String] = [:]

            let data = aNetService.addresses![0] as NSData
            var sockaddrPtr : UnsafeMutablePointer<sockaddr_in> = UnsafeMutablePointer<sockaddr_in>.alloc(sizeof(sockaddr_in))
            data.getBytes(sockaddrPtr, length: sizeof(sockaddr_in))
            var sockaddr : sockaddr_in = sockaddrPtr.memory
            let address = String.fromCString(inet_ntoa(sockaddr.sin_addr))
            info["ip"] = address

            let filteredKeys = txtRecord.allKeys.filter {($0 as String == "id" || $0 as String == "se" || $0 as String == "ve" || $0 as String == "fn" || $0 as String == "md");}
            if filteredKeys.count >= 5 {
                for key in txtRecord.allKeys {
                    let data : NSData = txtRecord[key as NSString] as NSData
                    let val: String = NSString(bytes: data.bytes, length: data.length, encoding: NSUTF8StringEncoding) as String
                    info[key as String] = val
                }
                let service = Service(txtRecordDictionary: info)
                service.getDeviceInfo(2) { [unowned self] (deviceInfo, error) -> Void in
                    if self.delegate != nil && (error == nil && deviceInfo != nil) {
                        self.delegate!.onServiceFound(service, provider: self)
                    }
                }

            }
        }
        //release resources
        aNetService.delegate = nil
        removeService(aNetService)
    }

}