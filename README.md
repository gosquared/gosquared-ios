# GoSquared iOS

**This is an early beta, please open an issue if you find anything not working, or to leave feedback for improvement. You can also get in touch directly: <ed@gosquared.com>.**

## Installation

### Installing with CocoaPods (Recommended)

1. Install [CocoaPods](https://cocoapods.org) using `gem install cocoapods`.
2. Create a new Podfile using `pod init`.
3. There are two options for adding GoSquared to your Podfile:
 - If you want automatic tracking of your views, add `pod 'GoSquared/Autoload'`
 - If you dont not want this, add `pod 'GoSquared'` to your Podfile.
4. Run `pod install` to install. This will generate a new Xcode workspace for you to open and use.

### Installing with Carthage

Installation with [Carthage](https://github.com/Carthage/Carthage) is supported, however automatic view tracking will not be available. As such, you'll need to call `trackScreen:` on each of your ViewControllers.

For instructions using Carthage, [please read their documentation](https://github.com/Carthage/Carthage).

## Configuration

Make sure you initialise the library with your site token before calling any tracking / people methods otherwise the library will throw an exception. It is recommended to add the below line to your UIApplication's `didFinishLaunchingWithOptions` method.

**Objective-C:**

```objc
#import <GoSquared/GoSquared.h>

// ...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GoSquared sharedTracker].token = @"your-site-token";
    [GoSquared sharedTracker].key   = @"your-api-key";

    // optionally set logging level: Debug, Quiet (Default), Silent
    [GoSquared sharedTracker].logLevel = GSLogLevelDebug;
    
    // if your app primarily runs in the background and you want visitors to show in
    // your Now dashboard, you should set the following to `YES` (default: NO) 
    [GoSquared sharedTracker].shouldTrackInBackground = YES;

    return YES;
}
```

**Swift:**

```swift
import GoSquared

// ...

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    GoSquared.sharedTracker().token = "your-site-token"
    GoSquared.sharedTracker().key   = "your-api-key"

    // optionally set logging level: Debug, Quiet (Default), Silent
    GoSquared.sharedTracker().logLevel = .Debug
    
    // if your app primarily runs in the background and you want visitors to show in
    // your Now dashboard, you should set the following to `true` (default: false) 
    GoSquared.sharedTracker().shouldTrackInBackground = true

    return true
}
```

## Page View Tracking

### Automatic Page View Tracking (Recommended)

> **Note**: This is only available if you installed with CocoaPods.

Make sure you're using the `GoSquared/Autoload` subspec in your Podfile. Configure your Site Token and API Key as described above, and you're good to go!

If needed, you can disable tracking on indiviual ViewControllers, or set a custom title:

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
    [[GoSquared sharedTracker] trackScreen:self.title];
    [[GoSquared sharedTracker] trackScreen:self.title withPath:@"/custom-url-path"];
}
```

**Swift:**

```swift
import GoSquared

// ...

override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    GoSquared.sharedTracker().trackScreen(self.title)
    GoSquared.sharedTracker().trackScreen(self.title, withPath:"/custom-url-path")
}

```

## Event Tracking

### Track an event

**Objective-C:**

```objc
[[GoSquared sharedTracker] trackEvent:"event name"];
```

**Swift:**

```swift
GoSquared.sharedTracker().trackEvent("event name")
```

### Track an event with properties

**Objective-C:**

```objc
[[GoSquared sharedTracker] trackEvent:@"event name" properties:@{ @"properties": @"are cool" }];
```

**Swift:**

```swift
GoSquared.sharedTracker().trackEvent("event name", properties: ["properties": "are cool"])
```

## People

### Identify your user
To identify a user you will need to provide a `person_id`. This will create a new profile in [GoSquared People](https://www.gosquared.com/customer/en/portal/articles/2170492-an-introduction-to-gosquared-people) where all of the user's session data, events and custom properties will be tracked.

The `person_id` can be set to an email address by using the prefix `email:` (see example below).

*Note the library caches your identified person_id and uses it again on the next launch. If you do not want this behavior, call `unidentify` after setting the `token` on each launch.*

**Objective-C:**

```objc
// identify with id
[[GoSquared sharedTracker] identify:@"test-person_id" properties:@{ @"name": @"Test User" }];

// identify with email
[[GoSquared sharedTracker] identify:@"email:user@example.com" properties:@{ @"name": @"Test User" }];
```

**Swift:**

```swift
// idenitfy with id
GoSquared.sharedTracker().identify("test-person_id", properties: ["name" : "Test User"])

// identify with email
GoSquared.sharedTracker().identify("email:user@example.com", properties: ["name": "Test User"]);
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

[[GoSquared sharedTracker] trackTransaction:@"unique-id" items: @[ coke ]];
```

**Swift:**

```swift
let coke = GSTransactionItem(name: "Coca Cola", price: 0.99, quantity: 6)

GoSquared.sharedTracker().trackTransaction("unique-id", items: [coke])
```

## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms.

Please see [CODE\_OF\_CONDUCT.md](https://github.com/gosquared/gosquared-ios/blob/master/CODE_OF_CONDUCT.md) for full terms.

## License

The MIT License (MIT)

## Credits

Thanks to Giles Williams of [Urban Massage](http://urbanmassage.com) for building the initial version of this library and allowing us to take it over.
