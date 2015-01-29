// Generated by Swift version 1.1 (swift-600.0.56.1)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if defined(__has_include) && __has_include(<uchar.h>)
# include <uchar.h>
#elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
#endif

typedef struct _NSZone NSZone;

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted) 
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
@import CoreGraphics;
@import ObjectiveC;
@import Foundation;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class UIWindow;
@class UIApplication;
@class NSObject;

SWIFT_CLASS("_TtC16MultiScreenPhoto11AppDelegate")
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic) UIWindow * window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class Service;
@class ChannelClient;
@class NSError;
@class NSData;
@class NSNotification;
@class Message;
@protocol ChannelDelegate;


/// A Channel is a discreet connection where multiple clients can communicate
///
/// <dl><dt>since</dt><dd><p>2.0</p></dd></dl>
SWIFT_CLASS("_TtC16MultiScreenPhoto7Channel")
@interface Channel

/// The uri of the channel ('chat')
@property (nonatomic, readonly, copy) NSString * uri;

/// the service that is suplaying the channel connection
@property (nonatomic, readonly) Service * service;

/// The collection of clients currently connected to the channel
@property (nonatomic, readonly, copy) NSArray * clients;

/// The client that owns this channel instance
@property (nonatomic) ChannelClient * me;

/// The delegate for handling channel events, alternative
@property (nonatomic, weak) id <ChannelDelegate> delegate;

/// The connection status of the channel
@property (nonatomic, readonly) BOOL isConnected;

/// A default initializer that returns a nil instance
///
/// \returns nil
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;

/// Internal initializer
///
/// \param url The endpoint for the channel
///
/// \param service The serivice providing the connectivity
///
/// \returns A channel instance
- (instancetype)initWithUri:(NSString *)uri service:(Service *)service OBJC_DESIGNATED_INITIALIZER;

/// Connects to the channel. This method will asynchronously call the delegate's onConnect method and post a
/// ChannelEvent.Connect notification upon completion.
/// When a TV application connects to this channel, the onReady method/notification is also fired
- (void)connect;

/// Connects to the channel. This method will asynchronously call the delegate's onConnect method and post a
/// ChannelEvent.Connect notification upon completion.
/// When a TV application connects to this channel, the onReady method/notification is also fired
///
/// \param attributes Any attributes you want to associate with the client (ie. ["name":"FooBar"])
- (void)connect:(NSDictionary *)attributes;

/// Connects to the channel. This method will asynchronously call the delegate's onConnect method and post a 
/// ChannelEvent.Connect notification upon completion.
/// When a TV application connects to this channel, the onReady method/notification is also fired
///
/// \param attributes Any attributes you want to associate with the client (ie. ["name":"FooBar"])
///
/// \param completionHandler The callback handler
- (void)connect:(NSDictionary *)attributes completionHandler:(void (^)(Channel *, NSError *))completionHandler;

/// Disconnects from the channel. This method will asynchronously call the delegate's onDisconnect and post a 
/// ChannelEvent.Disconnect notification upon completion.
///
/// \param completionHandler: <p>The callback handler</p><ul><li><p>channel: The channel instance</p></li><li><p>error: An error info if disconnect fails</p></li></ul>
- (void)disconnect:(void (^)(Channel *, NSError *))completionHandler;
- (void)disconnect;

/// Publish an event containing a text message payload
///
/// \param event: The event name
///
/// \param message: A JSON serializable message object
- (void)publishWithEvent:(NSString *)event message:(id)message;

/// Publish an event containing a text message and binary payload
///
/// \param event: The event name
///
/// \param message: A JSON serializable message object
///
/// \param data: Any binary data to send with the message
- (void)publishWithEvent:(NSString *)event message:(id)message data:(NSData *)data;

/// Publish an event with text message payload to one or more targets
///
/// \param event: The event name
///
/// \param message: A JSON serializable message object
///
/// \param target: The target recipient(s) of the message.Can be a string client id, a collection of ids or a string MessageTarget (like MessageTarget.All.rawValue)
- (void)publishWithEvent:(NSString *)event message:(id)message target:(id)target;

/// Publish an event containing a text message and binary payload to one or more targets
///
/// \param event: The event name
///
/// \param message: A JSON serializable message object
///
/// \param data: Any binary data to send with the message
///
/// \param target: The target recipient(s) of the message.Can be a string client id, a collection of ids or a string MessageTarget (like MessageTarget.All.rawValue)
- (void)publishWithEvent:(NSString *)event message:(id)message data:(NSData *)data target:(id)target;
- (void)emitWithEvent:(NSString *)event message:(id)message target:(id)target data:(NSData *)data;

/// A convenience method to subscribe for notifications using blocks
///
/// \param notificationName: The name of the notification
///
/// \param performClosure: The notification block, this block will be executed in the main thread
///
/// \returns An observer handler for removing/unsubscribing the block from notifications
- (id)on:(NSString *)notificationName performClosure:(void (^)(NSNotification *))performClosure;

/// A convenience method to unsubscribe from notifications
///
/// \param observer: The observer object to unregister observations
- (void)off:(id)observer;
- (void)processMessage:(Message *)message;
- (void)processTextMessage:(NSString *)message;
- (void)processDataMessage:(NSData *)data;
- (void)didConnect:(NSError *)error;
- (void)didDisconnect:(NSError *)error;
- (void)onError:(NSError *)error;
@end



/// An Application represents an application on the TV device.
/// Use this class to control various aspects of the application such as launching the app or getting information
SWIFT_CLASS("_TtC16MultiScreenPhoto11Application")
@interface Application : Channel
@property (nonatomic) id _id;

/// The id of the channel
@property (nonatomic, readonly) id id;

/// Auto starts the application when connect is called
@property (nonatomic) BOOL startOnConnect;

/// Stops the application when disconnect is called and your client is the last client connected
@property (nonatomic) BOOL stopOnDisconnect;

/// Disconnects your client when the host connection ends (when the host application is exited)
@property (nonatomic) BOOL disconnectWithHost;
- (instancetype)initWithAppId:(id)appId channelURI:(NSString *)channelURI service:(Service *)service OBJC_DESIGNATED_INITIALIZER;

/// Retrieves information about the Application on the TV
///
/// \param completionHandler The callback handler with the status dictionary and an error if any
- (void)getInfo:(void (^)(NSDictionary *, NSError *))completionHandler;

/// Launches the application on the remote device, if the application is already running it returns success = true.
/// If the startOnConnect is set to false this method needs to be called in order to start the application
///
/// \param completionHandler The callback handler
- (void)start:(void (^)(BOOL, NSError *))completionHandler;

/// Stops the application on the TV
///
/// \param completionHandler The callback handler
- (void)stop:(void (^)(BOOL, NSError *))completionHandler;

/// Starts the application install on the TV, this method will fail for cloud applications
///
/// \param completionHandler The callback handler
- (void)install:(void (^)(BOOL, NSError *))completionHandler;
- (void)disconnect;
- (void)clientDisconnect:(NSNotification *)notification;
- (void)didConnect:(NSError *)error;
@property (nonatomic, readonly, copy) NSString * description;
@end




/// A client currently connected to the channel
SWIFT_CLASS("_TtC16MultiScreenPhoto13ChannelClient")
@interface ChannelClient
@property (nonatomic, copy) NSDictionary * clientInfo;

/// The id of the client
@property (nonatomic, readonly, copy) NSString * id;

/// The time which the client connected in epoch milliseconds
@property (nonatomic, readonly) NSInteger connectTime;

/// A dictionary of attributes passed by the client when connecting
@property (nonatomic, readonly) id attributes;

/// Flag for determining if the client is the host
@property (nonatomic, readonly) BOOL isHost;

/// The description of the client
@property (nonatomic, readonly, copy) NSString * description;

/// The initializer
///
/// \param clientInfo: A dictionary with the client information
///
/// \returns A ChannelClient instance
- (instancetype)initWithClientInfo:(NSDictionary *)clientInfo OBJC_DESIGNATED_INITIALIZER;
@end



/// The channel delegate protocol defines the event methods available for a channel
SWIFT_PROTOCOL("_TtP16MultiScreenPhoto15ChannelDelegate_")
@protocol ChannelDelegate
@optional

/// Called when the Channel is connected
///
/// \param error: An error info if any
- (void)onConnect:(NSError *)error;

/// Called when the host app is ready to send or receive messages
- (void)onReady;

/// Called when the Channel is disconnected
///
/// \param error: An error info if any
- (void)onDisconnect:(NSError *)error;

/// Called when the Channel receives a text message
///
/// \param message: Text message received
- (void)onMessage:(Message *)message;

/// Called when the Channel receives a binary data message
///
/// \param message: Text message received
///
/// \param payload: Binary payload data
- (void)onData:(Message *)message payload:(NSData *)payload;

/// Called when a client connects to the Channel
///
/// \param client: The Client that just connected to the Channel
- (void)onClientConnect:(ChannelClient *)client;

/// Called when a client disconnects from the Channel
///
/// \param client: The Client that just disconnected from the Channel
- (void)onClientDisconnect:(ChannelClient *)client;

/// Called when a Channel Error is fired
///
/// \param error: The error
- (void)onError:(NSError *)error;
@end

@class TVIntegration;
@class NSString;
@class NSBundle;
@class NSCoder;

SWIFT_CLASS("_TtC16MultiScreenPhoto8CommonVC")
@interface CommonVC : UIViewController
@property (nonatomic) TVIntegration * tvIntegration;
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message;
- (void)updateNavbarButton;
- (void)showServicesFound;
- (void)showSettings;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class UIButton;
@class UIImageView;

SWIFT_CLASS("_TtC16MultiScreenPhoto16CustomHeaderCell")
@interface CustomHeaderCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton * title;
@property (nonatomic, weak) IBOutlet UIImageView * imageViewArrow;
@property (nonatomic) BOOL state;
- (void)awakeFromNib;
- (void)drawRect:(CGRect)rect;
- (IBAction)headerClicked:(UIButton *)sender;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC16MultiScreenPhoto19CustomTableViewCell")
@interface CustomTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton * imageView0;
@property (nonatomic, weak) IBOutlet UIButton * imageView1;
@property (nonatomic, weak) IBOutlet UIButton * imageView2;
@property (nonatomic, weak) IBOutlet UIButton * imageView3;
@property (nonatomic, weak) IBOutlet UIButton * imageView4;
- (void)awakeFromNib;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (IBAction)clickedImage:(UIButton *)sender;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC16MultiScreenPhoto6Device")
@interface Device
@property (nonatomic, readonly, copy) NSString * duid;
@property (nonatomic, readonly, copy) NSString * model;
@property (nonatomic, readonly, copy) NSString * description;
@property (nonatomic, readonly, copy) NSString * networkType;
@property (nonatomic, readonly, copy) NSString * ssid;
@property (nonatomic, readonly, copy) NSString * ip;
@property (nonatomic, readonly, copy) NSString * firmwareVersion;
@property (nonatomic, readonly, copy) NSString * name;
@property (nonatomic, readonly, copy) NSString * id;
@property (nonatomic, readonly, copy) NSString * udn;
@property (nonatomic, readonly, copy) NSString * resolution;
@property (nonatomic, readonly, copy) NSString * countryCode;
- (instancetype)initWithInfo:(NSDictionary *)info OBJC_DESIGNATED_INITIALIZER;
@end

@class ALAssetsLibrary;
@class ALAssetsGroup;
@class UIImage;
@class ALAsset;

SWIFT_CLASS("_TtC16MultiScreenPhoto7Gallery")
@interface Gallery : NSObject
@property (nonatomic) ALAssetsLibrary * assetsLibrary;
@property (nonatomic, copy) NSArray * albums;
@property (nonatomic, copy) NSArray * numOfAssetsByalbum;
@property (nonatomic, copy) NSArray * isAlbumExpanded;
@property (nonatomic) NSInteger currentAlbum;
+ (Gallery *)sharedInstance;
- (NSInteger)getNumOfAlbums;
- (NSString *)getAlbumName:(NSInteger)albumIndex;
- (void)setNumOfAssetsByAlbum:(NSInteger)albumIndex;
- (NSInteger)getNumOfAssetsByAlbum:(NSInteger)albumIndex;
- (void)setIsAlbumExpanded:(NSInteger)albumIndex isExpanded:(BOOL)isExpanded;
- (BOOL)getIsAlbumExpanded:(NSInteger)albumIndex;
- (void)setNumOfAssetsByalbumToZero:(NSInteger)albumIndex;
- (void)requestImageAtIndex:(NSInteger)album index:(NSInteger)index isThumbnail:(BOOL)isThumbnail completionHandler:(void (^)(UIImage *, NSDictionary *))completionHandler;
- (UIImage *)getImageFromAsset:(ALAsset *)asset;
- (UIImage *)getThumnailFromAsset:(ALAsset *)asset;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class UIView;
@class UITableView;
@class NSIndexPath;

SWIFT_CLASS("_TtC16MultiScreenPhoto19HomePhotoGalleryCVC")
@interface HomePhotoGalleryCVC : CommonVC <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic) UIView * welcomeView;
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, readonly) CGRect screenSize;
- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)animated;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)collapseSection:(NSInteger)section;
- (void)expandSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)photoSelected:(NSIndexPath *)indexPath;
- (NSInteger)numOfRowsInSection:(NSInteger)section;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC16MultiScreenPhoto22HomePhotoGalleryTVCell")
@interface HomePhotoGalleryTVCell : UITableViewCell
- (void)awakeFromNib;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class NSNetServiceBrowser;
@class NSNetService;

SWIFT_CLASS("_TtC16MultiScreenPhoto21MDNSDiscoveryProvider")
@interface MDNSDiscoveryProvider : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@property (nonatomic) BOOL isSearching;
- (void)search;
- (void)stop;
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser;
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
- (void)netService:(NSNetService *)aNetService didNotResolve:(NSDictionary *)errorDict;
- (void)netServiceDidResolveAddress:(NSNetService *)aNetService;
@end



/// This class encapsulates the message that
SWIFT_CLASS("_TtC16MultiScreenPhoto7Message")
@interface Message

/// The event name
@property (nonatomic, readonly, copy) NSString * event;

/// The publisher of the event
@property (nonatomic, readonly, copy) NSString * from;

/// A dictionary containig the message
@property (nonatomic, readonly) id data;

/// The initializer
///
/// \param message A dictionary containing the message
///
/// \returns A Message instance
- (instancetype)initWithMessage:(NSDictionary *)message OBJC_DESIGNATED_INITIALIZER;
@end

@class NSTimer;
@class UIPageViewController;
@class UIGestureRecognizer;
@class PhotoPageContentVC;

SWIFT_CLASS("_TtC16MultiScreenPhoto21PhotoGalleryDetailsVC")
@interface PhotoGalleryDetailsVC : CommonVC <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
@property (nonatomic) Gallery * gallery;
@property (nonatomic) NSInteger numberOfAssets;
@property (nonatomic) NSTimer * timer;
@property (nonatomic) UIPageViewController * pageViewController;
@property (nonatomic) NSInteger currentIndex;
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
- (void)didReceiveMemoryWarning;
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;
- (PhotoPageContentVC *)viewControllerAtIndex:(NSInteger)index;
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed;
- (void)startTimer;
- (void)sendToTv;
- (void)viewWillDisappear:(BOOL)animated;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class UIScrollView;
@class UITapGestureRecognizer;

SWIFT_CLASS("_TtC16MultiScreenPhoto18PhotoPageContentVC")
@interface PhotoPageContentVC : UIViewController <UIScrollViewDelegate>
@property (nonatomic) Gallery * gallery;
@property (nonatomic) UIPageViewController * pageViewController;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) UIScrollView * scrollView;
@property (nonatomic) UIImageView * imageView;
- (void)viewDidLoad;
- (void)addScrollView:(UIImage *)image;
- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer;
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
- (void)scrollViewDidZoom:(UIScrollView *)scrollView;
- (void)didReceiveMemoryWarning;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class ServiceSearch;


/// A Service instance represents the multiscreen service root on the remote device
/// Use the class to control top level services of the device
SWIFT_CLASS("_TtC16MultiScreenPhoto7Service")
@interface Service
@property (nonatomic) BOOL requireRechabilty;
@property (nonatomic) BOOL usePublicURI;

/// The id of the service
@property (nonatomic, readonly, copy) NSString * id;

/// The uri of the service (http://<ip>:<port>/api/v2/)
@property (nonatomic, readonly, copy) NSString * uri;

/// The name of the service (Living Room TV)
@property (nonatomic, readonly, copy) NSString * name;

/// The version of the service (x.x.x)
@property (nonatomic, readonly, copy) NSString * version;

/// The type of the service (Samsung SmartTV)
@property (nonatomic, readonly, copy) NSString * type;

/// The service description
@property (nonatomic, readonly, copy) NSString * description;

/// Initializer
- (instancetype)initWithTxtRecordDictionary:(NSDictionary *)txtRecordDictionary OBJC_DESIGNATED_INITIALIZER;

/// This asynchronously method retrieves a dictionary of additional information about the device the service is running on
///
/// \param completionHandler: <p>A block to handle the response dictionary</p><ul><li><p>deviceInfo: The device info dictionary</p></li><li><p>error: An error info if getDeviceInfo failed</p></li></ul>
- (void)getDeviceInfo:(void (^)(NSDictionary *, NSError *))completionHandler;

/// Creates an application instance belonging to that service
///
/// \param id <p>The id of the application</p><ul><li><p>For an installed application this is the string id as provided by Samsung, If your TV app is still in development, you can use the folder name of your app as the id. Once the TV app has been released into Samsung Apps, you must use the supplied app id.`</p></li><li><p>For a cloud application this is the application's URL</p></li></ul>
///
/// \param channelURI The uri of the Channel ("com.samsung.multiscreen.helloworld")
///
/// \returns An Application instance or nil if application id or channel id is empty
- (Application *)createApplication:(id)id channelURI:(NSString *)channelURI;

/// Creates a channel instance belonging to that service ("mychannel")
///
/// \param ` The uri of the Channel ("com.samsung.multiscreen.helloworld")
///
/// \returns A Channel instance
- (Channel *)createChannel:(NSString *)channelURI;

/// Creates a service search object
///
/// \returns An instance of ServiceSearch
+ (ServiceSearch *)search;

/// This asynchronous method retrieves a service instance given a service URI
///
/// \param uri: The uri of the service
///
/// \param completionHandler: <p>The completion handler with the service instance or an error</p><ul><li><p>service: The service instance</p></li><li><p>timeout: The timeout for the request</p></li><li><p>error: An error info if getByURI fails</p></li></ul>
+ (void)getByURI:(NSString *)uri timeout:(NSTimeInterval)timeout completionHandler:(void (^)(Service *, NSError *))completionHandler;

/// This asynchronous method retrieves a service instance given a service id
///
/// \param id: The id of the service
///
/// \param completionHandler: <p>The completion handler with the service instance or an error</p><ul><li><p>service: The service instance</p></li><li><p>error: An error info if getById fails</p></li></ul>
+ (void)getById:(NSString *)id completionHandler:(void (^)(Service *, NSError *))completionHandler;
@end

@protocol ServiceSearchDelegate;


/// This class searches the local network for compatible multiscreen services
SWIFT_CLASS("_TtC16MultiScreenPhoto13ServiceSearch")
@interface ServiceSearch

/// Set a delegate to receive search events.
@property (nonatomic) id <ServiceSearchDelegate> delegate;
@property (nonatomic, copy) NSArray * services;

/// The search status
@property (nonatomic, readonly) BOOL isSearching;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithId:(NSString *)id OBJC_DESIGNATED_INITIALIZER;

/// A convenience method to suscribe for notifications using blocks
///
/// \param notificationName: The name of the notification
///
/// \param performClosure: The notification block, this block will be executed in the main thread
///
/// \returns An observer handler for removing/unsubscribing the block from notifications
- (id)on:(NSString *)notificationName performClosure:(void (^)(NSNotification *))performClosure;

/// A convenience method to unsuscribe from notifications
///
/// \param observer: The observer object to unregister observations
- (void)off:(id)observer;

/// Start the search
- (void)start;

/// Stops the search
- (void)stop;
- (void)onServiceFound:(Service *)service;
- (void)onServiceLost:(NSString *)serviceId;
- (void)onStop;
- (void)onStart;
@end



/// This protocol defines the methods for ServiceSearch discovery
SWIFT_PROTOCOL("_TtP16MultiScreenPhoto21ServiceSearchDelegate_")
@protocol ServiceSearchDelegate
@optional

/// The ServiceSearch will call this delegate method when a service is found
///
/// \param service The found service
- (void)onServiceFound:(Service *)service;

/// The ServiceSearch will call this delegate method when a service is lost
///
/// \param service The lost service
- (void)onServiceLost:(Service *)service;

/// The ServiceSearch will call this delegate method after stopping the search
- (void)onStop;

/// The ServiceSearch will call this delegate method after the search has started
- (void)onStart;
@end

@class UIPickerView;
@class NSAttributedString;

SWIFT_CLASS("_TtC16MultiScreenPhoto15ServicesFoundVC")
@interface ServicesFoundVC : CommonVC <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, weak) IBOutlet UIButton * connectButton;
@property (nonatomic, weak) IBOutlet UIPickerView * TVPickerView;
@property (nonatomic, copy) NSArray * pickerData;
- (void)viewDidLoad;
- (IBAction)close:(id)sender;
- (IBAction)startConnection:(id)sender;
- (void)didReceiveMemoryWarning;
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC16MultiScreenPhoto13TVIntegration")
@interface TVIntegration : NSObject <ServiceSearchDelegate, ChannelDelegate>
@property (nonatomic, copy) NSString * appURL;
@property (nonatomic, copy) NSString * channelId;
@property (nonatomic) Application * app;
@property (nonatomic, readonly) ServiceSearch * search;
@property (nonatomic) BOOL isConnected;
+ (TVIntegration *)sharedInstance;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (void)start;
- (BOOL)isApplicationConnected;
- (NSArray *)getServices;
- (Service *)getServiceWithIndex:(NSInteger)index;
- (void)onServiceLost:(Service *)service;
- (void)onServiceFound:(Service *)service;
- (void)sendPhotoToTv:(UIImage *)image;
@end


SWIFT_CLASS("_TtC16MultiScreenPhoto14ViewController")
@interface ViewController : UIViewController
- (void)viewDidLoad;
- (void)didReceiveMemoryWarning;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class NSURL;
@class NSStream;

SWIFT_CLASS("_TtC16MultiScreenPhoto9WebSocket")
@interface WebSocket : NSObject <NSStreamDelegate>
@property (nonatomic, copy) NSArray * optionalProtocols;
@property (nonatomic, readonly, copy) NSString * headerWSUpgradeName;
@property (nonatomic, readonly, copy) NSString * headerWSUpgradeValue;
@property (nonatomic, readonly, copy) NSString * headerWSHostName;
@property (nonatomic, readonly, copy) NSString * headerWSConnectionName;
@property (nonatomic, readonly, copy) NSString * headerWSConnectionValue;
@property (nonatomic, readonly, copy) NSString * headerWSProtocolName;
@property (nonatomic, readonly, copy) NSString * headerWSVersionName;
@property (nonatomic, readonly, copy) NSString * headerWSVersionValue;
@property (nonatomic, readonly, copy) NSString * headerWSKeyName;
@property (nonatomic, readonly, copy) NSString * headerOriginName;
@property (nonatomic, readonly, copy) NSString * headerWSAcceptName;
@property (nonatomic, readonly, copy) NSString * headerUserAgentName;
@property (nonatomic, readonly, copy) NSString * headerUserAgentValue;
@property (nonatomic, readonly) NSInteger BUFFER_MAX;
@property (nonatomic, readonly) uint8_t FinMask;
@property (nonatomic, readonly) uint8_t OpCodeMask;
@property (nonatomic, readonly) uint8_t RSVMask;
@property (nonatomic, readonly) uint8_t MaskMask;
@property (nonatomic, readonly) uint8_t PayloadLenMask;
@property (nonatomic, readonly) NSInteger MaxFrameSize;
@property (nonatomic, copy) NSDictionary * headers;
@property (nonatomic) BOOL voipEnabled;
@property (nonatomic) BOOL selfSignedSSL;
@property (nonatomic, readonly) BOOL isConnected;
- (instancetype)initWithUrl:(NSURL *)url OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithUrl:(NSURL *)url protocols:(NSArray *)protocols;
- (instancetype)initWithUrl:(NSURL *)url protocols:(NSArray *)protocols connect:(void (^)(void))connect disconnect:(void (^)(NSError *))disconnect text:(void (^)(NSString *))text data:(void (^)(NSData *))data;
- (instancetype)initWithUrl:(NSURL *)url connect:(void (^)(void))connect disconnect:(void (^)(NSError *))disconnect text:(void (^)(NSString *))text;
- (instancetype)initWithUrl:(NSURL *)url connect:(void (^)(void))connect disconnect:(void (^)(NSError *))disconnect data:(void (^)(NSData *))data;

/// Connect to the websocket server on a background thread
- (void)connect;

/// disconnect from the websocket server
- (void)disconnect;

/// write a string to the websocket. This sends it as a text frame.
- (void)writeString:(NSString *)str;

/// write binary data to the websocket. This sends it as a binary frame.
- (void)writeData:(NSData *)data;
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;
@end


SWIFT_CLASS("_TtC16MultiScreenPhoto11WelcomeView")
@interface WelcomeView : UIView
@property (nonatomic, weak) IBOutlet UIButton * getStartButton;
- (IBAction)getStart:(UIButton *)sender;
- (void)drawRect:(CGRect)rect;
- (instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

#pragma clang diagnostic pop