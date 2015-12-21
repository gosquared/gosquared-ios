# GoSquared iOS Change Log

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


[v0.0.10]: https://github.com/gosquared/gosquared-ios/compare/v0.0.9...v0.0.10
[v0.0.9]: https://github.com/gosquared/gosquared-ios/compare/v0.0.8...v0.0.9
[v0.0.8]: https://github.com/gosquared/gosquared-ios/compare/v0.0.7...v0.0.8
[v0.0.7]: https://github.com/gosquared/gosquared-ios/compare/v0.0.6...v0.0.7
[v0.0.6]: https://github.com/gosquared/gosquared-ios/compare/v0.0.5...v0.0.6
[v0.0.5]: https://github.com/gosquared/gosquared-ios/compare/v0.0.4...v0.0.5
[v0.0.4]: https://github.com/gosquared/gosquared-ios/compare/v0.0.3...v0.0.4
[v0.0.3]: https://github.com/gosquared/gosquared-ios/compare/v0.0.2...v0.0.3
[v0.0.2]: https://github.com/gosquared/gosquared-ios/compare/v0.0.1...v0.0.2
