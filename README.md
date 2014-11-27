GoSquared iOS Native Tracker
=========

*Written by Giles Williams of Urban Massage Ltd*

Note this library is very much a proof of concept at this stage

#Initialisation

Make sure you initialise the library with your site token before calling any tracking / people methods otherwise the library will throw an exception. It is recommended to add 
the below line to your UIApplication's *didFinishLaunchingWithOptions* implementation.

    [[GSTracker sharedInstance] setSiteToken:@"GSN-XXXXXX-I"];



#Page View Tracking

Page view tracking can be acheived in one of two ways:
* Use the drop-in UIViewController category that will automatically track each UIViewController as they come into view without you having to do any extra work (recommended)
* Use the manual methods in each UIViewController you wish to track - this method may be more recognisable to those of you who have used Google Analytics mobile tracking, however as with GA, you may find that if you do not add the correct tracking code to every view controller, it could appear as though a view which has since been dismissed is still visible

####Using the drop in category

You really don't have to do much more setup if you're using the category, except for ensuring that each view controller has a title (so you don't see (null) showing up in your dashboard)

The drop in category gives you a couple of options per view controller - both of these must be set before viewDidAppear is run

    #import "UIViewController+GSTracking.h"
    ........
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.trackingTitle = @""; // use this to override the title property on the UIViewController class
        self.doNotTrack = YES; // set this to YES if you wish to disable tracking for a particular UIViewController
    }

####Using the manual page view tracking

You can use one of the below methods to manually track a UIViewController

    #import "GoSquared.h"
    ........
    - (void)viewDidAppear {
        [[GSTracker sharedInstance] trackViewController:self];
        [[GSTracker sharedInstance] trackViewController:self withTitle:@"Manually set title"];
        [[GSTracker sharedInstance] trackViewController:self withTitle:@"Manually set title" urlPath:@"/custom-url-path"];
    }


    
#Event Tracking

####Track an event
    GSEvent *e = [GSEvent eventWithName:@"test-event"];
    [[GSTracker sharedInstance] trackEvent:e];
    
####Track an event with properties
    GSEvent *e = [GSEvent eventWithName:@"test-event"];
    e.properties = @{ @"properties": @"are cool" };
    [[GSTracker sharedInstance] trackEvent:e];


    
#People

####Identify your user
*Note the library caches your identified user ID and uses it again on the next launch. If you do not want this behavior, call unidentify after setSiteToken on each launch.*

    [[GSTracker sharedInstance] identify:@"test-user-id" properties:@{ @"name": @"Test User" }];
    
####Unidentify (e.g. on logout)
    
    [[GSTracker sharedInstance] unidentify];



#Ecommerce

####Track a transaction
    GSTransactionItem *i = [[GSTransactionItem alloc] init];
    i.price = [NSNumber numberWithFloat:20.0f];
    i.quantity = [NSNumber numberWithInt:2];
    i.revenue = [NSNumber numberWithFloat:40.0f]; // auto calculated as price * quantity if not set
    i.name = @"here's an item!";

    GSTransaction *t = [GSTransaction transactionWithID:@"my-transaction"];
    [t addItem:i];

    [[GSTracker sharedInstance] trackTransaction:t];