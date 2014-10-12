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
*Note you currently have to call identify: with every run of your application*


    [[GSTracker sharedInstance] identify:@"test-user-id" properties:@{ @"name": @"Test User" }];
    
####Unidentify (e.g. on logout)
    
    [[GSTracker sharedInstance] unidentify];
