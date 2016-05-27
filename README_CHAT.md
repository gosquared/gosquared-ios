# GoSquared Chat iOS

**This is an early beta, please open an issue if you find anything not working, or to leave feedback for improvement. You can also get in touch directly: <ed@gosquared.com>.**

## Installation

You should be familiar with installing through [CocoaPods](https://cocoapods.org/). Your Podfile should include the following two lines for the target you're wishing to install Chat with:

```ruby
pod 'GoSquared'
pod 'GoSquared/Chat'

# optional if you want to auotmatically track view controllers
# if not added, you must manually call `trackScreen:` yourself
pod 'GoSquared/Autoload'
```

## Configuration

#### Objective-C

```objc
#import <GoSquared/Gosquared.h>
#import <GoSquared/GoSquared+Chat.h>

// ...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GoSquared sharedTracker].token  = @"your-site-token";
    [GoSquared sharedTracker].key    = @"your-api-key";

    // this is required for Chat and can be generated from:
    // https://www.gosquared.com/setup/general
    [GoSquared sharedTracker].secret = @"your-secure-secret";

    // ===========================================================
    // this is where we will configure the Chat view controller...
    // ===========================================================

    // this sets the title that is displayed at the top of the view controller
    [GoSquared sharedChatViewController].title = @"Chatting with Support";

    // this opens the connection for chat, showing the user as online, and
    // loading messages they missed while the app was closed
    [[GoSquared sharedChatViewController] openConnection];

    return YES;
}
```

#### Swift

```swift
import GoSquared

// ...

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    GoSquared.sharedTracker().token  = "your-site-token"
    GoSquared.sharedTracker().key    = "your-api-key"

    // this is required for Chat and can be generated from:
    // https://www.gosquared.com/setup/general
    GoSquared.sharedTracker().secret = "your-secure-secret"

    // ===========================================================
    // this is where we will configure the Chat view controller...
    // ===========================================================

    // this sets the title that is displayed at the top of the view controller
    GoSquared.sharedChatViewController().title = "Chatting with Support"

    // this opens the connection for chat, showing the user as online, and
    // loading messages they missed while the app was closed
    GoSquared.sharedChatViewController().openConnection()

    return true
}
```

## Displaying Chat

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

Often you'll want to display the number of unread messages from a chat somewhere (on the button which opens chat, is usually a sensible option).

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
