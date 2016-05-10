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
#import "GSChatHeaderLoadingView.h"
#import "GSChatHeaderEndView.h"
#import "GSChatComposeView.h"
#import "GSChatBubbleCell.h"
#import "GSChatManager.h"
#import "GSChatMessage.h"
#import "GSChatConnectionStatusView.h"
#import "GSChatIceBreakerView.h"
#import "GSChatViewLayout.h"
#import "UIColor+GoSquared.h"


NSString * const kGSChatUIConversationStart = @"This is the begining of your conversation.";
NSString * const kGSChatUIIceBreaker        = @"How can we help? Send us a message and we’ll get back to you as soon as possible.";

NSString * const kGSChatBubbleCellIdentifier    = @"ChatBubbleCell";
NSString * const kGSChatHeaderEndIdentifier     = @"ChatHeaderEnd";
NSString * const kGSChatHeaderLoadingIdentifier = @"ChatHeaderLoading";

NSString * const GSUnreadMessageNotification      = @"GSUnreadMessageNotification";
NSString * const GSUnreadMessageNotificationCount = @"GSUnreadMessageNotificationCount";


@interface GSChatViewController () <GSChatComposeViewDelegate, GSChatManagerDelegate, UICollectionViewDelegateFlowLayout, GSChatViewLayoutDelegate>

@property (nonatomic) GSChatManager *chatManager;


// UI / Subviews
@property (nonatomic, readwrite) UIView *inputAccessoryView;
@property (nonatomic) GSChatConnectionStatusView *connectionIndicator;
@property UIActivityIndicatorView *spinner;
@property (readonly) UIView *iceBreakerView;
@property (readonly) UIView *failedToLoadMessageHistoryView;

@property UITapGestureRecognizer *tapGesture;

@property int lastId;

@property BOOL hasReachedEnd;
@property BOOL hasEverBeenOpened;
@property BOOL shouldDisplayIcebreaker;

@property (getter=isOpen) BOOL open;
@property (getter=isInitialHistoryLoad) BOOL initialHistoryLoad;
@property (getter=isScrolling) BOOL scrolling;
@property (getter=isUpdatingMessages) BOOL updatingMessages;

@property NSMutableDictionary *cellSizeCache;
@property NSMutableArray *rowsToReload;

@property (nonatomic) GSChatConnectionStatus connectionStatus;
@property (readwrite) NSNumber *unreadMessageCount;

@property GSTracker *tracker;

@end

@implementation GSChatViewController

@synthesize iceBreakerView = _iceBreakerView;
@synthesize failedToLoadMessageHistoryView = _failedToLoadMessageHistoryView;

- (instancetype)init
{
    return [self initWithChatManager:[[GSChatManager alloc] init]];
}

- (instancetype)initWithTracker:(nonnull GSTracker *)tracker
{
    if (self = [self init]) {
        self.tracker = tracker;
    }
    return self;
}

- (instancetype)initWithChatManager:(GSChatManager *)manager
{
    GSChatViewLayout *gsLayout = [[GSChatViewLayout alloc] init];
    gsLayout.chatLayoutDelegate = self;

    if (self = [super initWithCollectionViewLayout:gsLayout]) {
        // start at "not 0" because comparison to 0 is messing things up :thumbsup:
        self.lastId = 200;

        self.chatManager = manager;
        self.chatManager.delegate = self;

        self.rowsToReload = [[NSMutableArray alloc] init];
        self.initialHistoryLoad = YES;
        self.open = NO;
        self.scrolling = NO;
        self.hasEverBeenOpened = NO;
        self.connectionIndicator = [[GSChatConnectionStatusView alloc] initWithFrame:CGRectZero];
        self.connectionStatus = GSChatConnectionStatusLoading;
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];

        self.cellSizeCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // if set in interface builder the custom title will have not been set
    if (self.title) {
        [self setTitle:self.title];
    }

    [self.view addGestureRecognizer:self.tapGesture];

    [self.collectionView registerClass:[GSChatBubbleCell class] forCellWithReuseIdentifier:kGSChatBubbleCellIdentifier];
    [self.collectionView registerClass:[GSChatHeaderLoadingView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kGSChatHeaderLoadingIdentifier];
    [self.collectionView registerClass:[GSChatHeaderEndView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kGSChatHeaderEndIdentifier];

    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.spinner.color = [UIColor grayColor];

    UIActivityIndicatorView *initialSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    initialSpinner.color = [UIColor grayColor];
    [initialSpinner startAnimating];

    self.collectionView.backgroundView = initialSpinner;
    self.collectionView.backgroundColor = [UIColor gs_lightGrayColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(4 + 38, 0, 4, 0);
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.alwaysBounceVertical = YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIView *)inputAccessoryView
{
    if (!_inputAccessoryView) {
        GSChatComposeView *composeView = [[GSChatComposeView alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        [composeView setComposeViewDelegate:self];

        _inputAccessoryView = composeView;
    }
    return _inputAccessoryView;
}

- (UIView *)iceBreakerView
{
    if (!_iceBreakerView) {
        _iceBreakerView = [GSChatIceBreakerView iceBreakerViewWithMessage:kGSChatUIIceBreaker];
    }
    return _iceBreakerView;
}

// lol terrible name
- (UIView *)failedToLoadMessageHistoryView
{
    if (!_failedToLoadMessageHistoryView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        UILabel *nomsg = [[UILabel alloc] initWithFrame:CGRectZero];
        nomsg.translatesAutoresizingMaskIntoConstraints = NO;
        nomsg.text = self.title;
        nomsg.textAlignment = NSTextAlignmentCenter;
        nomsg.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        nomsg.textColor = [UIColor colorWithWhite:0 alpha:.7];

        [nomsg sizeToFit];

        [view addSubview:nomsg];

        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-180-[title]->=60-|"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:@{ @"title": nomsg }]];

        _failedToLoadMessageHistoryView = view;
    }
    return _failedToLoadMessageHistoryView;
}

- (BOOL)messageIsOwnAtIndexPath:(NSIndexPath *)indexPath
{
    GSChatMessage *message = self.chatManager.messages[indexPath.item];
    return [self messageIsOwn:message];
}

- (BOOL)messageIsOwn:(GSChatMessage *)message
{
    return message.sender == GSChatSenderClient;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.connectionIndicator.frame = CGRectMake(0, self.collectionView.contentInset.top - 38 - 4, self.view.frame.size.width, 38);
}

- (void)updateTableViewWithBlock:(void (^)())block
{
    if (self.hasEverBeenOpened) {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSAssert(self.navigationController != nil, @"%@ must be presented inside a UINavigationController", self);

    if ([[self.navigationController.viewControllers firstObject] isEqual:self]) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                                   style:UIBarButtonItemStyleDone
                                                                                  target:self
                                                                                  action:@selector(dismissChatViewController:)]];
    }

    self.inputAccessoryView.hidden = NO;

    self.hasEverBeenOpened = YES;
    [self openConnection];

    [self scrollToBottomAnimated:NO];

    self.connectionIndicator.frame = CGRectMake(0, self.collectionView.contentInset.top - 38 - 4, self.view.frame.size.width, 38);
    self.connectionIndicator.hidden = NO;

    [self.view addSubview:self.connectionIndicator];
    [self.view bringSubviewToFront:self.connectionIndicator];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.open = YES;

    [self becomeFirstResponder];

    [self.connectionIndicator didChageConnectionStatus:self.connectionStatus];
    [self.chatManager markReadWithTimestamp:@([(GSChatMessage *)self.chatManager.messages.lastObject timestamp])];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.connectionIndicator removeFromSuperview];

    self.open = NO;

    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.inputAccessoryView.frame;
        frame.origin.y += frame.size.height;
        self.inputAccessoryView.frame = frame;
    } completion:^(BOOL finished) {
        [self.inputAccessoryView setHidden:YES];
    }];
}

- (void)dismissKeyboard:(id)sender
{
    [(GSChatComposeView *)self.inputAccessoryView endEditing];
    [self.view resignFirstResponder];
}

- (void)dismissChatViewController:(id)sender
{
    [self dismissKeyboard:nil];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didBeginEditing
{
    self.collectionView.backgroundView = nil;
    [self scrollToBottomAnimated:YES];
}

- (void)didEditText
{
    [self.chatManager sendTypingNotification];
}

- (void)openConnection
{
    [self.chatManager setConfigWithTracker:self.tracker];

    [self.chatManager openWebSocket];

    if (self.chatManager.messages.count == 0) {
        [self.chatManager loadMessageHistory];
    }
}

- (void)closeConnection
{
    [self.chatManager closeWebSocket];
}

- (void)setConnectionStatus:(GSChatConnectionStatus)connectionStatus
{
    _connectionStatus = connectionStatus;
    [self.connectionIndicator didChageConnectionStatus:connectionStatus];
}

- (void)showError:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    if (self.chatManager.messages.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatManager.messages.count-1 inSection:0];

        [self updateTableViewWithBlock:^{
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:animated];
        }];
    }
}

- (void)didSendMessage:(NSString *)message
{
    GSChatMessage *msg = [GSChatMessage messageWithContent:message sender:GSChatSenderClient];

    [self.chatManager sendMessage:msg];
}


# pragma mark - Application Notifications

- (void)applicationEnteredForeground:(NSNotification *)notification
{
    [self.chatManager openWebSocket];
}

- (void)applicationEnteredBackground:(NSNotification *)notification
{
    [self.chatManager closeWebSocket];
}


# pragma mark - GSChatManagerDelegate

- (void)managerDidConnect
{
    if (self.isOpen) {
        [self.chatManager markReadWithTimestamp:@([(GSChatMessage *)self.chatManager.messages.lastObject timestamp])];
    }

    self.connectionStatus = GSChatConnectionStatusConnected;
    [self.connectionIndicator didChageConnectionStatus:GSChatConnectionStatusConnected];
}

- (void)managerDidFailToConnect
{
    self.connectionStatus = GSChatConnectionStatusDisconnected;
    [self.connectionIndicator didChageConnectionStatus:GSChatConnectionStatusDisconnected];
}

- (void)managerDidDisconnect
{
    self.connectionStatus = GSChatConnectionStatusDisconnected;
    [self.connectionIndicator didChageConnectionStatus:GSChatConnectionStatusDisconnected];
}

- (void)didAddMessage:(GSChatMessage *)message
{
    self.collectionView.backgroundView = nil;

    if (![self messageIsOwn:message] && self.isOpen) {
        [self.chatManager markReadWithTimestamp:@(message.timestamp)];
    }

    [self updateTableViewWithBlock:^{
        // add to the end of the collectionView
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.chatManager.messages.count-1 inSection:0];

        [self.collectionView insertItemsAtIndexPaths:@[ indexPath ]];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }];
}

- (void)didUpdateMessageAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    self.cellSizeCache[((GSChatMessage *)self.chatManager.messages[index]).serverId] = nil;

    BOOL viewShouldScroll = self.collectionView.contentSize.height > self.view.frame.size.height;

    if (self.isScrolling && viewShouldScroll) {
        [self.rowsToReload addObject:indexPath];
    } else {
        [self updateTableViewWithBlock:^{
            [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
        }];
    }
}

- (void)didUpdateMessageList
{
    self.cellSizeCache = [[NSMutableDictionary alloc] init];

    if (self.chatManager.messages.count == 0) {
        self.collectionView.backgroundView = self.iceBreakerView;
    } else {
        self.collectionView.backgroundView = nil;
    }

    [self updateTableViewWithBlock:^{
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:NO];
    }];
}

- (void)didAddMessagesInRange:(NSRange)range reachedEnd:(BOOL)reachedEnd
{
    self.hasReachedEnd = reachedEnd;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (reachedEnd) {
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }

        if (self.chatManager.messages.count == 0) {
            self.collectionView.backgroundView = self.iceBreakerView;
        } else {
            self.collectionView.backgroundView = nil;
        }
    });

    [self updateTableViewWithBlock:^{
        if (range.location == NSNotFound || self.chatManager.messages.count == 0) {
            return;
        }

        self.updatingMessages = NO;

        CGPoint beforeOffset = self.collectionView.contentOffset;
        CGFloat beforeHeight = self.collectionView.contentSize.height;
        CGFloat height = beforeHeight;
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:range.length];

        [CATransaction setDisableActions:YES];

        for (int i = 0; i < range.length; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:range.location + i inSection:0];
            [indexPaths addObject:indexPath];
            height += [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath].height;
        }

        [self.collectionView insertItemsAtIndexPaths:indexPaths];
        self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, beforeOffset.y + height - beforeHeight);
        [CATransaction setDisableActions:NO];

        if (self.initialHistoryLoad) {
            [self scrollToBottomAnimated:NO];
        }
    }];

    self.initialHistoryLoad = NO;
}

- (void)didUpdateUnreadMessageCount:(NSUInteger)count
{
    self.unreadMessageCount = @(count);

    [[NSNotificationCenter defaultCenter] postNotificationName:GSUnreadMessageNotification
                                                        object:self
                                                      userInfo:@{ GSUnreadMessageNotificationCount: self.unreadMessageCount }];
}

- (void)didRequestContextForMessageCell:(GSChatBubbleCell *)cell
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [[UIViewController alloc] init];
    window.windowLevel = CGFLOAT_MAX;
    window.hidden = NO;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Message failed to send"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"Resend" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.chatManager sendMessage:cell.message];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.chatManager deleteMessage:cell.message];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [window.rootViewController presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.chatManager.messages.count;
}


#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GSChatMessage *message = self.chatManager.messages[indexPath.row];

    GSChatBubbleCell *cell = (GSChatBubbleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kGSChatBubbleCellIdentifier forIndexPath:indexPath];

    if (cell.delegate == nil) {
        cell.delegate = self;
    }

    cell.isOwn   = [self messageIsOwn:message];
    cell.message = message;

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind != UICollectionElementKindSectionHeader) {
        return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }

    if (self.hasReachedEnd) {
        GSChatHeaderEndView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                         withReuseIdentifier:kGSChatHeaderEndIdentifier
                                                                                forIndexPath:indexPath];
        header.text = kGSChatUIConversationStart;

        return header;
    } else {
        return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                  withReuseIdentifier:kGSChatHeaderLoadingIdentifier
                                                         forIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GSChatMessage *message = self.chatManager.messages[indexPath.item];
    NSValue *size = self.cellSizeCache[message.serverId];

    if (size == nil) {
        GSChatBubbleContent *content = [[GSChatBubbleContent alloc] initWithFrame:CGRectZero];
        content.text = message.content;

        [content sizeToFit];

        size = [NSValue valueWithCGSize:[content sizeThatFits:CGSizeMake(260, CGFLOAT_MAX)]];

        if (message.serverId) {
            self.cellSizeCache[message.serverId] = size;
        }
    }

    return [size CGSizeValue];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width, 60);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        GSChatMessage *message = self.chatManager.messages[indexPath.item];
        [[UIPasteboard generalPasteboard] setString:message.content];
    }
}


# pragma mark - UIScrollViewController

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrolling = YES;

    if ((scrollView.contentOffset.y + scrollView.contentInset.top) <= 0 && !self.initialHistoryLoad && self.open && !self.hasReachedEnd && !self.updatingMessages) {
        self.updatingMessages = YES;
        [self.chatManager loadMessageHistory];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.scrolling = NO;

    if (self.rowsToReload.count == 0) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadItemsAtIndexPaths:self.rowsToReload];
        [self.rowsToReload removeAllObjects];
    });
}

@end
