# GoSquared iOS

**This is an early beta, please open an issue if you find anything not working, or to leave feedback for improvement. You can also get in touch directly: <ben@gosquared.com>.**

This guide is for adding GoSquared Analytics, People CRM and Live Chat to your native iOS app. You'll need to generate an API key with 'Write Tracking' permission. You can do this from your [Account Settings here](https://www.gosquared.com/settings/api).


## Installation

### Installing with CocoaPods (Recommended)

You should be familiar with installing through [CocoaPods](https://cocoapods.org/). Your Podfile should include the following two lines for the target you're wishing to install Chat with:

There are two options for adding GoSquared to your Podfile:
 - If you want automatic tracking of your views, add `pod 'GoSquared/Autoload'`
 - If you don't want this, add `pod 'GoSquared'` to your Podfile.

To use GoSquared Live Chat add `pod GoSquared/Chat` to your Podfile

```ruby
pod 'GoSquared'
pod 'GoSquared/Chat'

# optional if you want to automatically track view controllers
# if not added, you must manually call `trackScreen:` yourself
pod 'GoSquared/Autoload'
```

Then simply run `pod install`

### Installing with Carthage

Installation with [Carthage](https://github.com/Carthage/Carthage) is supported, however automatic view tracking will not be available. As such, you'll need to call `trackScreen:` on each of your ViewControllers.

For instructions using Carthage, [please read their documentation](https://github.com/Carthage/Carthage).

## Configuration

Make sure you initialise the library with your Project Token (the unique identifier for your GoSquared Project – you can find it in your [Project Settings](https://www.gosquared.com/setup/general)) before calling any tracking / people methods otherwise the library will throw an exception. It is recommended to add the below line to your UIApplication's `didFinishLaunchingWithOptions` method.

**Note:** As of iOS 10 (Xcode 8), Apple requires that the `NSPhotoLibraryUsageDescription` key is included in your `info.plist` when accessing the photo library. If you would like the ability for users to send images over chat then you must add this key with a short description to be displayed when Chat accesses the Photo Library. If this is omitted previous to iOS 10 then the upload button will simply be hidden.

**Objective-C:**

```objc
#import <GoSquared/GoSquared.h>
#import <GoSquared/GoSquared+Chat.h> //Remove if you are not using chat

// ...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GoSquared sharedTracker].token = @"your-project-token";
    [GoSquared sharedTracker].key   = @"your-api-key";

    // this enables Secure Mode and is required for Live Chat. 
    // generate a Secure Mode Secret from your Project Settings here:
    // https://www.gosquared.com/setup/general
    [GoSquared sharedTracker].secret = @"your-secure-secret";


    // ===========================================================
    // this is where we will configure the Live Chat view controller...
    // ===========================================================

    // this opens the connection for Live chat, showing the user as online, and
    // loading messages they missed while the app was closed
    [[GoSquared sharedChatViewController] openConnection];

    // [OPTIONAL] override the title at the top of the view controller (by default
    // it will use the name set at https://www.gosquared.com/setup/chat)
    // [GoSquared sharedChatViewController].title = @"Chatting with Support";


    // ===========================================================
    // Other options...
    // ===========================================================

    // [OPTIONAL] set logging level: Debug, Quiet (Default), Silent
    // [GoSquared sharedTracker].logLevel = GSLogLevelDebug;

    // if your app primarily runs in the background and you want visitors to show in
    // your Now dashboard, you should set the following to `YES` (default: NO)
    // [GoSquared sharedTracker].shouldTrackInBackground = YES;

    return YES;
}
```

**Swift:**

```swift
import GoSquared

// ...

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    GoSquared.sharedTracker().token = "your-project-token"
    GoSquared.sharedTracker().key   = "your-api-key"

    // this enables Secure Mode and is required for Live Chat. 
    // generate a Secure Mode Secret from your Project Settings here:
    // https://www.gosquared.com/setup/general
    GoSquared.sharedTracker().secret = "your-secure-secret"

    // ===========================================================
    // this is where we will configure the Chat view controller...
    // ===========================================================

    // this opens the connection for chat, showing the user as online, and
    // loading messages they missed while the app was closed
    GoSquared.sharedChatViewController().openConnection();

    // [OPTIONAL] override the title at the top of the view controller (by default
    // it will use the name set at https://www.gosquared.com/setup/chat)
    // GoSquared.sharedChatViewController().title = "Chatting with Support";


    // [OPTIONAL] set logging level: Debug, Quiet (Default), Silent
    // GoSquared.sharedTracker().logLevel = .Debug

    // [OPTIONAL] if your app primarily runs in the background and you want
    // visitors to show in your Now dashboard, you should set the following to
    // `true` (default: false)
    // GoSquared.sharedTracker().shouldTrackInBackground = true

    return true
}
```

## Page View Tracking

### Automatic Page View Tracking (Recommended)

> **Note**: This is only available if you installed with CocoaPods.

Make sure you're using the `GoSquared/Autoload` subspec in your Podfile. Configure your Project Token and API Key as described above, and you're good to go!

If needed, you can disable tracking on individual ViewControllers, or set a custom title:

**Objective-C:**

```objc
#import <GoSquared/GoSquared.h>

// ...

- (void)viewDidLoad {
    [super viewDidLoad];

    // use this to override the title property on a ViewController class
    self.trackingTitle = @"My Custom Title";
    // set this to YES to disable tracking for a particular ViewController
    self.doNotTrack = YES;
}

```

**Swift:**

```swift
import GoSquared

// ...

override func viewDidLoad() {
    super.viewDidLoad()

    // use this to override the title property on a ViewController class
    self.trackingTitle = "My Custom Title";
    // set this to true to disable tracking for a particular ViewController
    self.doNotTrack = true;
}
```

### Manual Page View Tracking

You can use one of the below methods to manually track a UIViewController:

**Objective-C:**

```objc
#import <GoSquared/GoSquared.h>

// ...

- (void)viewDidAppear
{
    [[GoSquared sharedTracker] trackScreenWithTitle:self.title];
    [[GoSquared sharedTracker] trackScreenWithTitle:self.title path:@"/custom-url-path"];
}
```

**Swift:**

```swift
import GoSquared

// ...

override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    GoSquared.sharedTracker().trackScreen(title: self.title)
    GoSquared.sharedTracker().trackScreen(title: self.title, path:"/custom-url-path")
}

```

## Event Tracking

### Track an event

**Objective-C:**

```objc
[[GoSquared sharedTracker] trackEventWithName:"event name"];
```

**Swift:**

```swift
GoSquared.sharedTracker().trackEvent(name: "event name")
```

### Track an event with properties

**Objective-C:**

```objc
[[GoSquared sharedTracker] trackEventWithName:@"event name" properties:@{ @"properties": @"are cool" }];
```

**Swift:**

```swift
GoSquared.sharedTracker().trackEvent(name: "event name", properties: ["properties": "are cool"])
```

## People

### Identify your user
To identify a user you will need to provide an `id` or `email` property. This will create a new profile in [GoSquared People](https://www.gosquared.com/customer/en/portal/articles/2170492-an-introduction-to-gosquared-people) where all of the user's session data, events and custom properties will be tracked.

If you do not have an `id` to use for the person, one will be created from the email address.

> **Note:** the library caches your identified `id` and uses it again on the next launch. If you do not want this behavior, call `unidentify` after setting the `token` on each launch.

**Objective-C:**

```objc
NSDictionary *properties = @{
                             @"id": @"user-id", // Required if no email address
                             @"email": @"someone@example.com", // Required if no id

                             // Reserved property names
                             @"name": @"Test User",
                             @"username": @"testuser",
                             @"phone": @"+447901229693",
                             @"created_at": @"2016-06-07T15:44:20Z", // ISO 8601 formatted NSString
                             @"company_name": @"GoSquared",
                             @"company_industry": @"Customer Analytics",
                             @"company_size": @150000,

                             // Custom properties
                             @"custom": @{
                                      // @"custom_property_name": @"custom property value"
                                         }
                             };

[[GoSquared sharedTracker] identifyWithProperties:properties];
```

**Swift:**

```swift
let properties = [
    "id": "user-id", // Required if no email address
    "email": "someone@example.com", // Required if no id

    // Reserved property names
    "name": "Test User",
    "username": "testuser",
    "phone": "+447901229693",
    "created_at": "2016-06-07T15:44:20Z", // ISO 8601 formatted String
    "company_name": "GoSquared",
    "company_industry": "Customer Analytics",
    "company_size": 150000,

    // Custom properties
    "custom": [
    // "custom_property_name": "custom property value"
    ]
]

GoSquared.sharedTracker().identify(properties: properties)
```

### Unidentify (e.g. on logout)

**Objective-C:**

```objc
[[GoSquared sharedTracker] unidentify];
```

**Swift:**

```swift
GoSquared.sharedTracker().unidentify();
```

## Ecommerce

### Track a transaction

**Objective-C:**

```objc
GSTransactionItem *coke = [GSTransactionItem transactionItemWithName:@"Coca Cola"
                                                               price:@0.99
                                                            quantity:@6];

[[GoSquared sharedTracker] trackTransactionWithId:@"unique-id" items: @[ coke ]];
```

**Swift:**

```swift
let coke = GSTransactionItem(name: "Coca Cola", price: 0.99, quantity: 6)

GoSquared.sharedTracker().trackTransaction(id: "unique-id", items: [coke])
```

## Displaying Live Chat

#### Objective-C

```objc
#import <GoSquared/GoSquared.h>
#import <GoSquared/GoSquared+Chat.h>
#import <GoSquared/UIViewController+Chat.h>

// from within a UIViewController

// open from storyboard action
- (IBAction)buttonWasTapped:(id)sender
{
    [self gs_presentChatViewController];
}

```

#### Swift

```swift
import GoSquared

// from within a UIViewController

// open from storyboard action
@IBAction func buttonWasTapped(sender: AnyObject) {
    self.gs_presentChatViewController();
}
```

## Displaying Number of Unread Messages

Often you'll want to display the number of unread messages from a live chat somewhere (on the button which opens chat, is usually a sensible option).

#### Objective-C

```objc
#import <GoSquared/GoSquared.h>
#import <GoSquared/GoSquared+Chat.h>

// add a notification observer for `GSUnreadMessageNotification`
- (void)someSetupMethod
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unreadNotificationHandler:)
                                                 name:GSUnreadMessageNotification
                                               object:nil];
}

// method for handling notification
- (void)unreadNotificationHandler:(NSNotification *)notification
{
    NSUInteger count = ((NSNumber *)notification.userInfo[GSUnreadMessageNotificationCount]).unsignedIntegerValue;
    // update ui with count
}
```

#### Swift

```swift
import GoSquared

// add a notification obsever for `GSUnreadMessageNotification`
func someSetupFunction() {
    let notifCenter = NSNotificationCenter.defaultCenter()
    let notifHandler = #selector(CustomUIButton.unreadNotificationHandler(_:))

    notifCenter.addObserver(self, selector: notifHandler, name: GSUnreadMessageNotification, object:nil)
}

// function for handling notification
func unreadNotificationHandler(notification: NSNotification) {
    let count = notification.userInfo![GSUnreadMessageNotificationCount]
    // update ui with count
}

```

## Displaying In-App Notification For New Messages

We currently don't provide any UI for displaying an in-app notification for new messages, however we do allow you to build and display your own.

#### Objective-C

```objc
#import <GoSquared/GoSquared.h>
#import <GoSquared/GoSquared+Chat.h>

// add a notification observer for `GSMessageNotification`
- (void)someSetupMethod
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessageHandler:)
                                                 name:GSMessageNotification
                                               object:nil];
}

// method for handling notification
- (void)newMessageHandler:(NSNotification *)notification
{
    NSDictionary *messageInfo = notification.userInfo;

    NSString *senderName = messageInfo[GSMessageNotificationAuthor];
    NSString *senderAvatar = messageInfo[GSMessageNotificationAvatar];
    NSString *messageBody = messageInfo[GSMessageNotificationBody];

    // build and display ui for message notification
}
```

#### Swift

```swift
import GoSquared

// add a notification obsever for `GSMessageNotification`
func someSetupFunction() {
    let notifCenter = NSNotificationCenter.defaultCenter()
    let notifHandler = #selector(CustomUIButton.newMessageHandler(_:))

    notifCenter.addObserver(self, selector: notifHandler, name: GSMessageNotification, object:nil)
}

// function for handling notification
func newMessageHandler(notification: NSNotification) {
    let messageInfo = notification.userInfo!

    let senderName = messageInfo[GSMessageNotificationAuthor]
    let senderAvatar = messageInfo[GSMessageNotificationAvatar]
    let messageBody = messageInfo[GSMessageNotificationBody]

    // build and display ui for message notification
}

```

## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms.

Please see [CODE\_OF\_CONDUCT.md](https://github.com/gosquared/gosquared-ios/blob/master/CODE_OF_CONDUCT.md) for full terms.

## License

The MIT License (MIT)

## Credits

Thanks to Giles Williams of [Urban Massage](http://urbanmassage.com) for building the initial version of this library and allowing us to take it over.
