# GoSquared Chat iOS

**This is an early beta, please open an issue if you find anything not working, or to leave feedback for improvement. You can also get in touch directly: <ed@gosquared.com>.**

## Installation

You should be familiar with installing through [CocoaPods](https://cocoapods.org/). Your Podfile should include the following two lines for the target you're wishing to install Chat with:

```ruby
pod 'GoSquared', :git => 'git@github.com:gosquared/gosquared-ios-chat.git'
pod 'GoSquared/Chat', :git => 'git@github.com:gosquared/gosquared-ios-chat.git'

# optional if you want to auotmatically track view controllers
# if not added, you must manually call `trackScreen:` yourself
pod 'GoSquared/Autoload', :git => 'git@github.com:gosquared/gosquared-ios-chat.git'
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
    //
    // NOTE: this should only be run after a user has been identified with the
    //       `identify:properties:` method on `sharedTracker`
    //       you can check that the user is identified using the `identify`
    //       method on `sharedTracker`
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
    //
    // NOTE: this should only be run after a user has been identified with the
    //       `identify:properties:` method on `sharedTracker`
    //       you can check that the user is identified using the `identify`
    //       method on `sharedTracker`
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
