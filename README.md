GoSquared iOS Native Tracker
=========

*Written by Giles Williams of Urban Massage Ltd*

Note this library is very much a proof of concept at this stage

Initialisation
----
Make sure you initialise the library with your site token before calling any tracking / people methods otherwise the library will throw an exception. It is recommended to add 
the below line to your UIApplication's *didFinishLaunchingWithOptions* implementation.


    [[GSTracker sharedInstance] setSiteToken:@"GSN-XXXXXX-I"];
    
Tracking
----
####Track an event
    GSEvent *e = [GSEvent eventWithName:@"test-event"];
    [[GSTracker sharedInstance] trackEvent:e];
    
####Track an event with properties
    GSEvent *e = [GSEvent eventWithName:@"test-event"];
    e.properties = @{ @"properties": @"are cool" };
    [[GSTracker sharedInstance] trackEvent:e];
    
####Track a screen view
    [[GSTracker sharedInstance] trackScreenView:@"test screen"];
    
People
----

####Identify your user
*Note the library caches your identified user ID and uses it again on the next launch. If you do not want this behavior, call unidentify after setSiteToken on each launch.*


    [[GSTracker sharedInstance] identify:@"test-user-id" properties:@{ @"name": @"Test User" }];
    
####Unidentify (e.g. on logout)
    
    [[GSTracker sharedInstance] unidentify];

Ecommerce
----
####Track a transaction
    GSTransactionItem *i = [[GSTransactionItem alloc] init];
    i.price = [NSNumber numberWithFloat:20.0f];
    i.quantity = [NSNumber numberWithInt:2];
    i.revenue = [NSNumber numberWithFloat:40.0f]; // auto calculated as price * quantity if not set
    i.name = @"here's an item!";

    GSTransaction *t = [GSTransaction transactionWithID:@"my-transaction"];
    [t addItem:i];

    [[GSTracker sharedInstance] trackTransaction:t];