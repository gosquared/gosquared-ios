# GoSquared iOS Change Log

## 2018-03-28, [v1.0.2]

### Fixed

- Fixed issue where composer view would be unresponsive to touch input on iOS 11

## 2017-08-30, [v1.0.1]

### Fixed
- Fixed occasional crashes when using Chat on iOS 11

## 2016-10-11, [v1.0.0]

### Added
- Added Chat as part of the GoSquared SDK by default
- Added improved chat via WKWebView implementation for the message feed and connection logic

## 2016-08-15, [v0.7.4]

### Fixed
- Fixed potential retain cycle in GSTracker

## 2016-07-28, [v0.7.3]

### Fixed

- Fixed crash when tracking event before tracking a screen
- Fixed incorrect use of performMethodWithSelector in GoSquared+Chat.m

## 2016-07-05, [v0.7.2]

### Changed

- Network request errors will always be logged

## 2016-07-01, [v0.7.1]

### Fixed

- Fixed incorrect types in `GSConfig`
- Fixed old method name in Autoload

## 2016-07-01, [v0.7.0]

### Added

- Added `NS_SWIFT_NAME` overrides to tracking methods for better Swift use
- Added nullability annotations to `GSTransactionItem`

### Changed

- Tracking methods now have updated names
- Property dictionary paramters are now a `NSString: id` mapping

### Fixed

- Fixed persisted properties being leaked across multiple GSTracker instances
- Fixed some retain cycles

## 2016-06-30, [v0.6.2]

### Fixed

- Fixed crash when tracking a transaction without also using pageview tracking
- Fixed bug where items would not be sent when tracking a transaction

## 2016-06-21, [v0.6.1]

### Fixed

- Fixed crash when an incoming message didn't have an avatar available

## 2016-06-20, [v0.6.0]

### Changed

- The `identifyWithProperties:` method replaces the previous identify methods
- The `identifyWithProperties:` method will create a person_id from an email if a regular `id` is not present

### Removed

- `identify:` and `identify:properties:` methods have been removed in favour of `identifyWithProperties:`

## 2016-06-01, [v0.5.1]

### Changed

- Fixed broken equality check (there was a `=` instead of `==`)

## 2016-06-01, [v0.5.0]

### Added

- Added fix for crash when API error isn't in expected format

### Changed

- Defined public headers in Podfile
- When using Autoload (automatic tracking), view controllers without a title or trackingTitle will not be tracked

### Removed

- Removed sending/scheduling requests from public headers

## 2016-05-26, [v0.4.0]

### Added

- Added [GoSquared Chat](https://www.gosquared.com/software/chat/)

## 2016-05-17, [v0.3.0]

### Added

- Added `GSPageview` class to contain and generate pageview related data and request bodies
- `GSTrackerEvent` is now used as an internal model for generating request bodies
- Send engagement time — this will only use the time that the app is the foreground app on your device, unless you have background tracking enabled

### Changed

- Pageview tracking logic now all sits in `GSTracker`
- Most methods now generate request bodies from their related model classes instead of within `GSTracker`. People methods still generate bodies within the main tracker
- Fixed issue where pinging would always continue in the background
- Specifiy item types for `NSArray`s in method parameters

### Removed

- Removed `GSPageviewTracker` in favour of tracking logic being in the main tracker, and request bodies being generated in `GSPageview` classes


## 2016-05-09, [v0.2.0]

### Added

- Added option to continue pinging when app enters background (only needed for apps that continually run in the background)
- Added ability to track events without properties parameter (was incorrectly documented as being possible, sorry!)

### Changed

- Networking now uses `NSURLSession` instead of the deprecated `NSURLConnection`
- Improved singleton implementation for `sharedTracker` and `currentDevice`
- Retry pageview if pinging times out (more reliable online visitor count and pinging)
- Rename `GSRequestLogLevel` to `GSLogLevel`
- General refactoring and bringing code up to modern Obj-C practices
- `anonID` renamed to `visitorId`
- `currentPersonId` renamed to `personId`
- `identified` method is now available as `isIdentified` property

### Removed

- Removed tracking events with `GSTrackerEvent`
- Removed tracking by `UIViewController`


## 2016-04-07, [v0.1.2]

### Changed

- Tracker no longer logs information when identifying a user.

## 2016-03-16, [v0.1.1]

### Removed

- Removed `secret` property on tracker, which was accidently left in, but never used.

## 2016-03-16, [v0.1.0]

### Added

- Added nullablity annotations so usage in swift is a little nicer

### Changed

- Categories folder was renamed to Autoload to match the naming elsewhere
- `siteToken` renamed to just `token`
- `apiKey` renamed to just `key`

## 2015-12-21, [v0.0.10]

### Fixed

- Fix `identified` always returning false

## 2015-12-18, [v0.0.9]

### Changed

- Improved swizzling/automatic tracking (thanks to @DanielTomlinson for the heads up)

## 2015-12-16, [v0.0.8]

### Added

- Added support for tvOS from @steve228uk

### Changed

- Paths will now only be set if explicitly provided in the `trackScreen:withPath:` method.

### Fixed

- Fixed issue with URLs being sent in a way that we parse the path as `null`

## 2015-12-15, [v0.0.7]

### Fixed

- Fixed issue where `GSRequest.h` was not public (adds support for manual and Carthage installation)

## 2015-12-15, [v0.0.6]

### Added

- Added ability to set the amount of request information logged. Set `logLevel` on `GoSquared.sharedTracker()` to one of `Debug`, `Quiet` or `Silent`. `Quiet` by default.

## 2015-12-09, [v0.0.5]

### Changed

- Rename files, classes, variables, methods to use "pageview" as one word

### Fixed

- Fix issue where unique visitors for a time period were not being tracked correctly

## 2015-12-03, [v0.0.4]

### Added

- Added helper methods for tracking transactions: `trackTransaction:items:` and `trackTransaction:items:properties:`
- Added helper initialiser for `GSTransactionItem`s: `transactionItemWithName:price:quantity:`

### Changed

- Deprecated `GSTrackerEvent`. Use `trackEvent:withProperties:` method instead
- Deprecated `trackViewController:` methods. Use `trackScreen:` methods instead (note: this has same functionality, but the API is clearer)

## 2015-11-16, [v0.0.3]

### Fixed

- Fix bug where iPad devices were not being tracked correctly

## 2015-11-11, [v0.0.2]

### Added

- Support detecting user locations from IP address

## 2015-11-05, v0.0.1

### Added

- Add support for multiple tracking codes
- Add support for Cocoapods
- Add code of conduct and license

### Changed

- Rename `sharedInstance` to `sharedTracker`
- Rename `GSEvent` to `GSTrackerEvent` (`GSEvent` is already an existing thing <http://iphonedevwiki.net/index.php/GSEvent>)


[v1.0.0]: https://github.com/gosquared/gosquared-ios/compare/v0.7.4...v1.0.0
[v0.7.4]: https://github.com/gosquared/gosquared-ios/compare/v0.7.3...v0.7.4
[v0.7.3]: https://github.com/gosquared/gosquared-ios/compare/v0.7.2...v0.7.3
[v0.7.2]: https://github.com/gosquared/gosquared-ios/compare/v0.7.1...v0.7.2
[v0.7.1]: https://github.com/gosquared/gosquared-ios/compare/v0.7.0...v0.7.1
[v0.7.0]: https://github.com/gosquared/gosquared-ios/compare/v0.6.2...v0.7.0
[v0.6.2]: https://github.com/gosquared/gosquared-ios/compare/v0.6.1...v0.6.2
[v0.6.1]: https://github.com/gosquared/gosquared-ios/compare/v0.6.0...v0.6.1
[v0.6.0]: https://github.com/gosquared/gosquared-ios/compare/v0.5.1...v0.6.0
[v0.5.1]: https://github.com/gosquared/gosquared-ios/compare/v0.5.0...v0.5.1
[v0.5.0]: https://github.com/gosquared/gosquared-ios/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/gosquared/gosquared-ios/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/gosquared/gosquared-ios/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/gosquared/gosquared-ios/compare/v0.1.2...v0.2.0
[v0.1.2]: https://github.com/gosquared/gosquared-ios/compare/v0.1.1...v0.1.2
[v0.1.1]: https://github.com/gosquared/gosquared-ios/compare/v0.1.0...v0.1.1
[v0.1.0]: https://github.com/gosquared/gosquared-ios/compare/v0.0.10...v0.1.0
[v0.0.10]: https://github.com/gosquared/gosquared-ios/compare/v0.0.9...v0.0.10
[v0.0.9]: https://github.com/gosquared/gosquared-ios/compare/v0.0.8...v0.0.9
[v0.0.8]: https://github.com/gosquared/gosquared-ios/compare/v0.0.7...v0.0.8
[v0.0.7]: https://github.com/gosquared/gosquared-ios/compare/v0.0.6...v0.0.7
[v0.0.6]: https://github.com/gosquared/gosquared-ios/compare/v0.0.5...v0.0.6
[v0.0.5]: https://github.com/gosquared/gosquared-ios/compare/v0.0.4...v0.0.5
[v0.0.4]: https://github.com/gosquared/gosquared-ios/compare/v0.0.3...v0.0.4
[v0.0.3]: https://github.com/gosquared/gosquared-ios/compare/v0.0.2...v0.0.3
[v0.0.2]: https://github.com/gosquared/gosquared-ios/compare/v0.0.1...v0.0.2
