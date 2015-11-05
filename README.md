# GoSquared iOS

**This is an early beta, please open an issue if you find anything not working, or to leave feedback for improvement. You can also get in touch directly: <ed@goquared.com>**

## Installation

### Installing with CocoaPods (Recommended)

1. Install CocoaPods using `gem install cocoapods`.
2. Create a new Podfile using `pod init`.
3. There are two options for adding GoSquared to your Podfile:
 - If you want automatic tracking of your views, add `pod 'GoSquared/Autoload'`
 - If you dont not want this, add `pod 'GoSquared'` to your Podfile.
4. Run `pod install` to install. This will generate a new Xcode workspace for you to open and use.

### Installing with Carthage

> **Note**: By using carthage you will be unable to use the `UIViewController` category to automatically implement GoSquared pageview tracking. If you want this, please use CocoaPods, or install manually.

**[Read the instructions provided by Carthage](https://github.com/Carthage/Carthage)**

## Configuration

Make sure you initialise the library with your site token before calling any tracking / people methods otherwise the library will throw an exception. It is recommended to add the below line to your UIApplication's `didFinishLaunchingWithOptions` method.

**Objective-C:**

```objc
#import <GoSquared/GoSquared.h>

// ...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[GoSquared sharedTracker] setSiteToken:@"your-site-token"];
	[[GoSquared sharedTracker] setApiKey:@"your-api-key"];
	
    return YES;
}
```

**Swift:**

```swift
import GoSquared

// ...

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    GoSquared.sharedTracker().siteToken = "your-site-token"
    GoSquared.sharedTracker().apiKey    = "your-api-key"

    return true
}
```

## Page View Tracking

### Automatic Page View Tracking (Recommended)

> **Note**: This is only available if you installed with CocoaPods.

Make sure you're using the `GoSquared/Autoload` subspec in your Podfile. Configure your Site Token and API Key as described above, and you're good to go!

### Manual Page View Tracking

You can use one of the below methods to manually track a UIViewController:

**Objective-C:**

```objc
#import <GoSquared/GoSquared.h>

// ...

- (void)viewDidAppear
{
    [[GoSquared sharedTracker] trackViewController:self];
    [[GoSquared sharedTracker] trackViewController:self withTitle:@"Manually set title"];
    [[GoSquared sharedTracker] trackViewController:self withTitle:@"Manually set title" urlPath:@"/custom-url-path"];
}
```

**Swift:**

```swift
import GoSquared

// ...

override func viewDidAppear(animated: Bool) {
	super.viewDidAppear(animated)
	
	GoSquared.sharedTracker().trackViewController(self)
	GoSquared.sharedTracker().trackViewController(self, withTitle: "Manually set title")
	GoSquared.sharedTracker().trackViewController(self, withTitle: "Manually set title", urlPath:"/custom-url-path")
}

```

## Event Tracking

### Track an event

**Objective-C:**

```objc
GSTrackerEvent *event = [GSTrackerEvent eventWithName:@"test-event"];
[[GoSquared sharedTracker] trackEvent:event];
```

**Swift:**

```swift
let event = GSTrackerEvent(name: "test-event")
GoSquared.sharedTracker().trackEvent(event)
```
    
### Track an event with properties

**Objective-C:**

```objc
GSTrackerEvent *event = [GSTrackerEvent eventWithName:@"test-event"];
event.properties = @{ @"properties": @"are cool" };
[[GoSquared sharedTracker] trackEvent:event];
```

**Swift:**

```swift
let event = GSTrackerEvent(name: "test-event")
event.properties = ["properties": "are cool"]
GoSquared.sharedTracker().trackEvent(event)
```

## People

### Identify your user
*Note the library caches your identified user ID and uses it again on the next launch. If you do not want this behavior, call unidentify after `setSiteToken` on each launch.*

**Objective-C:**

```objc
[[GoSquared sharedTracker] identify:@"test-user-id" properties:@{ @"name": @"Test User" }];
```

**Swift:**

```swift
GoSquared.sharedTracker().identify("test-user-id", properties: ["name" : "Test User"])
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
GSTransactionItem *item = [[GSTransactionItem alloc] init];
item.price = [NSNumber numberWithFloat:20.0f];
item.quantity = [NSNumber numberWithInt:2];
item.revenue = [NSNumber numberWithFloat:40.0f]; // auto calculated as price * quantity if not set
item.name = @"here's an item!";

GSTransaction *tx = [GSTransaction transactionWithID:@"my-transaction"];
[tx addItem:item];

[[GoSquared sharedTracker] trackTransaction:tx];
```

**Swift:**

```swift
let item = GSTransactionItem()
item.price = 20.0
item.quantity = 2
item.revenue = 40.0 // auto calculated as price * quantity if not set
item.name = "here's an item!"

let tx = GSTransaction(ID: "my-transaction")
tx.addItem(item)

GoSquared.sharedTracker().trackTransaction(tx)
```

## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms.

Please see [CODE\_OF\_CONDUCT.md](https://github.com/gosquared/gosquared-ios/blob/master/CODE_OF_CONDUCT.md) for full terms.

## License

The MIT License (MIT)
