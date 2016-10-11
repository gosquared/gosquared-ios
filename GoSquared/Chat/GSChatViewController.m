//
//  GSChatViewController.m
//  GoSquared
//
//  Created by Edward Wellbrook on 21/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatViewController.h"
#import "GSChatComposeView.h"
#import "GSChatTitleView.h"
#import "GSChatComposeView.h"
#import "GSChatManager.h"
#import "GSChatWebView.h"
#import "GSTrackerDelegate.h"
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
#import <MobileCoreServices/MobileCoreServices.h>

// message notification constants
NSString * const GSUnreadMessageNotification      = @"GSUnreadMessageNotification";
NSString * const GSUnreadMessageNotificationCount = @"GSUnreadMessageNotificationCount";
NSString * const GSMessageNotification            = @"GSMessageNotification";
NSString * const GSMessageNotificationBody        = @"GSMessageNotificationBody";
NSString * const GSMessageNotificationAuthor      = @"GSMessageNotificationAuthor";
NSString * const GSMessageNotificationAvatar      = @"GSMessageNotificationAvatar";

@interface GSTracker ()

@property (weak) id<GSTrackerDelegate> delegate;

@end

@interface GSChatViewController () <GSChatComposeViewDelegate, GSChatManagerDelegate, GSTrackerDelegate>

@property GSTracker *tracker;
@property GSChatManager *chatManager;
@property NSDate *lastSentTypingNotifTimestamp;
@property NSString *currentTitle;
@property NSDictionary *config;
@property Boolean connectionOpened;

// ui / subviews
@property (nonatomic, readwrite) GSChatComposeView *inputAccessoryView;
@property (nonatomic) GSChatTitleView *titleView;
@property (nonatomic) UIActivityIndicatorView *activityView;
@property (nonatomic) GSChatWebView *webView;
@property NSLayoutConstraint *topConstraint;
@property NSLayoutConstraint *bottomConstraint;

@end

@implementation GSChatViewController

- (instancetype)initWithTracker:(nonnull GSTracker *)tracker
{
    if (self = [self init]) {
        self.tracker = tracker;
        self.tracker.delegate = self;

        self.chatManager = [[GSChatManager alloc] initWithTracker:tracker];
        self.chatManager.managerDelegate = self;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFontSize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];

    self.navigationItem.titleView = self.titleView;
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.scrollView.clipsToBounds = NO;
    self.webView.scrollView.layer.masksToBounds = NO;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;

    self.activityView.hidesWhenStopped = YES;
    self.activityView.translatesAutoresizingMaskIntoConstraints = NO;

    if (self.config == nil) {
        [self.activityView startAnimating];
    }

    [self.view addSubview:self.webView];
    [self.view addSubview:self.activityView];

    // Activity view constraints
    NSDictionary *views = @{ @"container": self.view, @"activity": self.activityView };


    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[container]-(<=1)-[activity]-[container]"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[container]-(<=1)-[activity]-[container]"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:views]];

    self.topConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.view
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1
                                                       constant:0];
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.webView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:0];

    [self.view addConstraints:@[ self.topConstraint, self.bottomConstraint ]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];

    [self checkWebViewLoaded];
}

- (GSChatComposeView *)inputAccessoryView
{
    if (!_inputAccessoryView) {
        GSChatComposeView *composeView = [[GSChatComposeView alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        [composeView setComposeViewDelegate:self];

        _inputAccessoryView = composeView;
    }
    return _inputAccessoryView;
}

- (GSChatTitleView *)titleView
{
    if (!_titleView) {
        _titleView = [[GSChatTitleView alloc] initWithFrame:CGRectZero];
    }
    return _titleView;
}

- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityView;
}

- (WKWebView *)webView
{
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.userContentController = self.chatManager;

        if ([WKWebsiteDataStore class] != nil) {
            config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
        }

        _webView = [[GSChatWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:config];
        _webView.navigationDelegate = self.chatManager;
    }
    return _webView;
}

- (NSString *)title
{
    return self.titleView.title;
}

- (void)setTitle:(NSString *)title
{
    self.currentTitle = title;
    self.navigationItem.title = title;
    self.titleView.title = title;
}

- (void)dismissKeyboard
{
    [self.inputAccessoryView endEditing];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canResignFirstResponder
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSAssert(self.navigationController != nil, @"%@ must be presented inside a UINavigationController", self);

    if ([[self.navigationController.viewControllers firstObject] isEqual:self]) {
        SEL action = @selector(dismissChatViewController:);
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:action];
        [self.navigationItem setLeftBarButtonItem:button];
    }

    [self openConnection];
    [self checkWebViewLoaded];
    [self checkSessionIsValid];

    [self.webView evaluateJavaScript:@"receiveFromSDK('set_visibility', true)" completionHandler:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissKeyboard];
    [self.inputAccessoryView endEditing];
    [self resignFirstResponder];
    [self.webView evaluateJavaScript:@"receiveFromSDK('set_visibility', false)" completionHandler:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    if (self.navigationController.navigationBar.frame.size.height <= 32) {
        self.navigationItem.titleView = nil;
        self.navigationItem.title = self.titleView.title;
    } else {
        self.navigationItem.titleView = self.titleView;
        [self.navigationItem.titleView setNeedsLayout];
        [self.navigationItem.titleView layoutIfNeeded];
    }
}

- (void)setNumberOfUnreadMessages:(NSUInteger)numberOfUnreadMessages
{
    _numberOfUnreadMessages = numberOfUnreadMessages;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GSUnreadMessageNotification
                                                            object:self
                                                          userInfo:@{ GSUnreadMessageNotificationCount: @(numberOfUnreadMessages) }];
    });
}

- (void)dismissChatViewController:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateChatConfig
{
    NSString *config = [GSChatManager configForTracker:self.tracker];
    NSString *loadConfigString = [NSString stringWithFormat:@"%@\n loadChat()", config];

    [self.webView evaluateJavaScript:loadConfigString completionHandler:nil];
}

- (void)checkWebViewLoaded
{
    if (self.webView.URL == nil) {
        [self loadWebView];
    }
}

- (void)forceReload
{
    [GSChatWebView clearStorage];
    [self loadWebView];
}

- (void)loadWebView
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSURL *dir = [NSURL fileURLWithPath:documentPath];
    NSURL *url = [dir URLByAppendingPathComponent:@"GSChat_index.html"];

    if ([self.webView respondsToSelector:@selector(loadFileURL:allowingReadAccessToURL:)]) {
        [self.webView loadFileURL:url allowingReadAccessToURL:dir];
    } else {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (void)openConnection
{
    if ([self connectionOpened]) return;

    self.connectionOpened = YES;

    [GSTracker prepareDocumentsDirectory];

    [GSTracker checkAvailableChatVersionWithCompletionHandler:^(NSString *version) {
        if (![[GSTracker chatVersion] isEqualToString:version] || self.forceUpdate) {
            [GSTracker updateChatClientWithVersion:version];
        }
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkWebViewLoaded];
    });
}

- (BOOL)isPresented
{
    return self.navigationController.viewControllers.firstObject == self;
}

- (void)checkSessionIsValid {
    if (self.isPresented && self.tracker.personId == nil && self.config != nil && [[self.config objectForKey:@"anon"] boolValue] == NO)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Anonymous chats are disabled"
                                                                       message:@"Contact the developer to let them know."
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self dismissChatViewController:self];
                                                              }];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


# pragma mark - Notification Handlers

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect finalRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    CGFloat keyboardHeight = [UIScreen mainScreen].bounds.size.height - finalRect.origin.y;

    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]
                     animations:^{
                         self.topConstraint.constant = navBarHeight;
                         self.bottomConstraint.constant = keyboardHeight;
                     }
                     completion:nil];
}

- (void)updateFontSize:(NSNotification *)notification
{
    [self.webView reload];
}


# pragma mark GSTrackerDelegate Methods

- (void)didIdentifyPerson
{
    [self updateChatConfig];
}

- (void)didUnidentifyPerson
{
    [GSChatWebView clearStorage];
    [self updateChatConfig];
}

- (void)didTrackPageview
{
    [self updateChatConfig];
}


# pragma mark - GSChatComposeViewDelegate

- (void)didEditText
{
    if (self.lastSentTypingNotifTimestamp == nil || self.lastSentTypingNotifTimestamp.timeIntervalSinceNow < -1) {
        NSString *js = @"receiveFromSDK('send_typing')";
        [self.webView evaluateJavaScript:js completionHandler:nil];

        self.lastSentTypingNotifTimestamp = [[NSDate alloc] init];
    }
}

- (void)didEndEditing
{
    [self.webView resignFirstResponder];
}

- (void)didSendMessage:(NSString *)message
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:@[message] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *escapedMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSString *js = [NSString stringWithFormat:@"receiveFromSDK('%@', %@)", @"send_message", [escapedMessage substringWithRange:NSMakeRange(2, escapedMessage.length-4)]];
    [self.webView evaluateJavaScript:js completionHandler:nil];
}

- (void)didRequestUpload
{
    [self dismissKeyboard];

    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO))
    return;

    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;

    [self presentViewController: mediaUI animated: YES completion:nil];
}

- (void) uploadImage:(UIImage *)image withExtension:(NSString *)extension
{
    CGFloat maxLength = 500.0f;
    CGFloat ratio = image.size.width / image.size.height;

    CGFloat maxWidth  = (ratio > 1) ? maxLength : maxLength * ratio;
    CGFloat maxHeight = (ratio < 1) ? maxLength : maxLength / ratio;

    CGSize size = CGSizeMake(maxWidth, maxHeight);

    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *data = [extension isEqual: @"jpg"] ? UIImageJPEGRepresentation(image, 1) : UIImagePNGRepresentation(image);

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"receiveFromSDK('upload_image', '%@', '%@')", [data base64EncodedStringWithOptions:0], extension] completionHandler:nil];
}


# pragma mark UIImagePickerControllerDelegate

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    [self dismissViewControllerAnimated:YES completion:nil];

    UIImage *image = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];

    NSString *compareString = [[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
    NSRange jpgRange = [compareString rangeOfString:@"JPG" options:NSBackwardsSearch];

    if (jpgRange.location != NSNotFound) {
        [self uploadImage:image withExtension:@"jpg"];
        return;
    }

    [self uploadImage:image withExtension:@"png"];
}


# pragma mark - GSChatManagerDelegate

- (void)didUpdateUnreadMessageCount:(NSUInteger)count
{
    self.numberOfUnreadMessages = count;
}

- (void)didTapMessageLinkWithURL:(NSURL *)URL
{
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:safariVC animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

- (void)webviewDidLoad
{
    [self updateChatConfig];
}

- (void)chatDidLoad
{
    if (self.isPresented) {
        [self.webView evaluateJavaScript:@"receiveFromSDK('set_visibility', true)" completionHandler:nil];
    }
}

- (void)didReceiveConfig:(NSDictionary *)config
{
    self.config = config;

    if (config[@"name"] != nil && config[@"name"] && self.currentTitle == nil) {
        self.title = [NSString stringWithFormat:@"Chatting with %@", config[@"name"]];
    }

    [self.activityView stopAnimating];
    [self checkSessionIsValid];
}

- (void)didReceiveNewMessage:(NSDictionary *)message
{
    if (self.isPresented) {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:GSMessageNotification object:nil userInfo:@{
                                                                                                          GSMessageNotificationBody: message[@"body"],
                                                                                                          GSMessageNotificationAuthor: message[@"author"],
                                                                                                          GSMessageNotificationAvatar: message[@"avatar"]
                                                                                                          }];
}

@end
