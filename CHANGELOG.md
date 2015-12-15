# GoSquared iOS Change Log

## 2015-12-15, [v0.0.6]

- Added ability to set the amount of request information logged. Set `logLevel` on `GoSquared.sharedTracker()` to one of `Debug`, `Quiet` or `Silent`. `Quiet` by default.

## 2015-12-09, [v0.0.5]

- Fix issue where unique visitors for a time period were not being tracked correctly
- Rename files, classes, variables, methods to use "pageview" as one word

## 2015-12-03, [v0.0.4]

- Deprecated `GSTrackerEvent`. Use `trackEvent:withProperties:` method instead
- Deprecated `trackViewController:` methods. Use `trackScreen:` methods instead (note: this has same functionality, but the API is clearer)
- Added helper methods for tracking transactions: `trackTransaction:items:` and `trackTransaction:items:properties:`
- Added helper initialiser for `GSTransactionItem`s: `transactionItemWithName:price:quantity:`

## 2015-11-16, [v0.0.3]

- Fix bug where iPad devices were not being tracked correctly

## 2015-11-11, [v0.0.2]

- Support detecting user locations from IP address

## 2015-11-05, v0.0.1

- Initial release
- Add support for multiple tracking codes
- Add support for Cocoapods
- Add code of conduct and license
- Rename `sharedInstance` to `sharedTracker`
- Rename `GSEvent` to `GSTrackerEvent` (`GSEvent` is already an existing thing <http://iphonedevwiki.net/index.php/GSEvent>)

[v0.0.6]: https://github.com/gosquared/gosquared-ios/compare/v0.0.5...v0.0.6
[v0.0.5]: https://github.com/gosquared/gosquared-ios/compare/v0.0.4...v0.0.5
[v0.0.4]: https://github.com/gosquared/gosquared-ios/compare/v0.0.3...v0.0.4
[v0.0.3]: https://github.com/gosquared/gosquared-ios/compare/v0.0.2...v0.0.3
[v0.0.2]: https://github.com/gosquared/gosquared-ios/compare/v0.0.1...v0.0.2
