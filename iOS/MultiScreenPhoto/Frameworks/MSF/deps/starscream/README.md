![starscream](http://limitedtoy.com/wp-content/uploads/2014/09/transformers-starscream-wallpaperstarscream-transformers-2-wallpaper---332913-pnx7lnff.jpg)

Starscream is a conforming WebSocket ([RFC 6455](http://tools.ietf.org/html/rfc6455)) client library in Swift for iOS and OSX.

It's Objective-C counter part can be found here: [Jetfire](https://github.com/acmacalister/jetfire)


## Features

- Conforms to all of the base [Autobahn test suite](http://autobahn.ws/testsuite/).
- Nonblocking. Everything happens in the background, thanks to GCD.
- Simple delegate pattern design.
- TLS/WSS support.
- Simple concise codebase at just a few hundred LOC.

## Example

First thing is to import the framework. See the Installation instructions on how to add the framework to your project.

```swift
//iOS
import Starscream
//OS X
import StarscreamOSX
```

Once imported, you can open a connection to your WebSocket server. Note that `socket` is probably best as a property, so your delegate can stick around.

```swift
var socket = WebSocket(url: NSURL(scheme: "ws", host: "localhost:8080", path: "/"))
socket.delegate = self
socket.connect()
```

After you are connected, there are some delegate methods that we need to implement.

### websocketDidConnect

websocketDidConnect is called as soon as the client connects to the server.

```swift
func websocketDidConnect() {
    println("websocket is connected")
}
```

### websocketDidDisconnect

websocketDidDisconnect is called as soon as the client is disconnected from the server.

```swift
func websocketDidDisconnect(error: NSError?) {
	println("websocket is disconnected: \(error!.localizedDescription)")
}
```

### websocketDidWriteError

websocketDidWriteError is called when the client gets an error on websocket connection.

```swift
func websocketDidWriteError(error: NSError?) {
    println("wez got an error from the websocket: \(error!.localizedDescription)")
}
```

### websocketDidReceiveMessage

websocketDidReceiveMessage is called when the client gets a text frame from the connection.

```swift
func websocketDidReceiveMessage(text: String) {
	println("got some text: \(text)")
}
```

### websocketDidReceiveData

websocketDidReceiveData is called when the client gets a binary frame from the connection.

```swift
func websocketDidReceiveData(data: NSData) {
	println("got some data: \(data.length)")
}
```

The delegate methods give you a simple way to handle data from the server, but how do you send data?

### writeData

The writeData method gives you a simple way to send `NSData` (binary) data to the server.

```swift
self.socket.writeData(data) //write some NSData over the socket!
```

### writeString

The writeString method is the same as writeData, but sends text/string.

```swift
self.socket.writeString("Hi Server!") //example on how to write text over the socket!
```

### disconnect

The disconnect method does what you would expect and closes the socket.

```swift
self.socket.disconnect()
```

### isConnected

Returns if the socket is connected or not.

```swift
if self.socket.isConnected {
  // do cool stuff.
}
```

### Custom Headers

You can also override the default websocket headers with your own custom ones like so:

```swift
socket.headers["Sec-WebSocket-Protocol"] = "someother protocols"
socket.headers["Sec-WebSocket-Version"] = "14"
socket.headers["My-Awesome-Header"] = "Everything is Awesome!"
```

### Protocols

If you need to specify a protocol, simple add it to the init:

```swift
//chat and superchat are the example protocols here
var socket = WebSocket(url: NSURL(scheme: "ws", host: "localhost:8080", path: "/"), protocols: ["chat","superchat"])
socket.delegate = self
socket.connect()
```

### Self Signed SSL and VOIP

There are a couple of other properties that modify the stream:

```swift
var socket = WebSocket(url: NSURL(scheme: "ws", host: "localhost:8080", path: "/"), protocols: ["chat","superchat"])

//set this if you are planning on using the socket in a VOIP background setting (using the background VOIP service).
socket.voipEnabled = true

//set this you want to ignore SSL cert validation, so a self signed SSL certificate can be used.
socket.selfSignedSSL = true
```

## Example Project

Check out the SimpleTest project in the examples directory to see how to setup a simple connection to a WebSocket server.

## Requirements

Starscream requires at least iOS 7/OSX 10.10 or above.

## Installation

### Cocoapods

```
Coming soon...(Hopefully!)
```

### Carthage

Check out the [Carthage](https://github.com/Carthage/Carthage) docs on how to add a install. The `Starscream` framework is already setup with shared schemes.

[Carthage Install](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

### Rogue

First see the [installation docs](https://github.com/acmacalister/Rogue) for how to install Rogue.

To install Starscream run the command below in the directory you created the rogue file.

```
rogue add https://github.com/daltoniam/starscream
```

Next open the `libs` folder and add the `Starscream.xcodeproj` to your Xcode project. Once that is complete, in your "Build Phases" add the `Starscream.framework` to your "Link Binary with Libraries" phase. Make sure to add the `libs` folder to your `.gitignore` file.

### Other

Simply grab the framework (either via git submodule or another package manager).

Add the `Starscream.xcodeproj` to your Xcode project. Once that is complete, in your "Build Phases" add the `Starscream.framework` to your "Link Binary with Libraries" phase.

## TODOs

- [ ] Complete Docs
- [ ] Add Unit Tests

## License

Starscream is licensed under the Apache v2 License.

## Contact

### Dalton Cherry
* https://github.com/daltoniam
* http://twitter.com/daltoniam
* http://daltoniam.com

### Austin Cherry ###
* https://github.com/acmacalister
* http://twitter.com/acmacalister
* http://austincherry.me
