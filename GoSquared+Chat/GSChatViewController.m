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
#import "GSChatConnectionStatus.h"
#import "GSChatConnectionStatusView.h"
#import "GSChatIceBreakerView.h"
#import "GSChatViewLayout.h"
#import "UIColor+GoSquared.h"


// will be moved when we support different languages
NSString * const kGSChatUIConversationStart = @"This is the begining of your conversation.";
NSString * const kGSChatUIIceBreaker        = @"How can we help? Send us a message and we’ll get back to you as soon as possible.";

// uicollectionview cell identifiers
NSString * const kGSChatBubbleCellIdentifier    = @"ChatBubbleCell";
NSString * const kGSChatHeaderEndIdentifier     = @"ChatHeaderEnd";
NSString * const kGSChatHeaderLoadingIdentifier = @"ChatHeaderLoading";

// message notification constants
NSString * const GSUnreadMessageNotification      = @"GSUnreadMessageNotification";
NSString * const GSUnreadMessageNotificationCount = @"GSUnreadMessageNotificationCount";
NSString * const GSMessageNotification            = @"GSMessageNotification";
NSString * const GSMessageNotificationBody        = @"GSMessageNotificationBody";
NSString * const GSMessageNotificationAuthor      = @"GSMessageNotificationAuthor";
NSString * const GSMessageNotificationAvatar      = @"GSMessageNotificationAvatar";


@interface GSChatViewController () <GSChatComposeViewDelegate, GSChatManagerDelegate, UICollectionViewDelegateFlowLayout, GSChatViewLayoutDelegate>

@property GSTracker *tracker;
@property GSChatManager *chatManager;

// ui / subviews
@property (nonatomic, readwrite) GSChatComposeView *inputAccessoryView;
@property GSChatConnectionStatusView *connectionIndicator;
@property UITapGestureRecognizer *tapGesture;

// state
@property NSUInteger lastId; // TODO: move this to ChatManager
@property NSUInteger numberOfMessages;
@property (nonatomic, readwrite) NSUInteger numberOfUnreadMessages;
@property BOOL hasReachedEnd;
@property (getter=isOpen) BOOL open;
@property (getter=isUpdatingMessages) BOOL updatingMessages;
@property (getter=isScrolling) BOOL scrolling;
@property (getter=isEditing) BOOL editing;

@property NSMutableArray *itemsToReload;

@end

@implementation GSChatViewController

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

        self.itemsToReload = [[NSMutableArray alloc] init];

        // workaround for UICollectionView bug: http://www.openradar.me/15262692
        [self.collectionView numberOfItemsInSection:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:self.tapGesture];

    [self.collectionView registerClass:[GSChatBubbleCell class] forCellWithReuseIdentifier:kGSChatBubbleCellIdentifier];
    [self.collectionView registerClass:[GSChatHeaderLoadingView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kGSChatHeaderLoadingIdentifier];
    [self.collectionView registerClass:[GSChatHeaderEndView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kGSChatHeaderEndIdentifier];

    self.connectionIndicator = [[GSChatConnectionStatusView alloc] initWithFrame:CGRectZero];
    self.connectionIndicator.connectionStatus = GSChatConnectionStatusLoading;
    [self.view addSubview:self.connectionIndicator];
    [self.view bringSubviewToFront:self.connectionIndicator];

    self.collectionView.backgroundColor = [UIColor gs_lightGrayColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(4 + 38, 0, 4, 0);
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.alwaysBounceVertical = YES;

    [self updateBackgroundView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.connectionIndicator.frame = CGRectMake(0, self.collectionView.contentInset.top - 38 - 4, self.view.frame.size.width, 38);
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

    [self openConnection];
    [self scrollToBottomAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.open = YES;

    [self becomeFirstResponder];
    [self.chatManager markRead];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.open = NO;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
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

- (GSChatComposeView *)inputAccessoryView
{
    if (!_inputAccessoryView) {
        GSChatComposeView *composeView = [[GSChatComposeView alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        [composeView setComposeViewDelegate:self];

        _inputAccessoryView = composeView;
    }
    return _inputAccessoryView;
}

- (void)updateBackgroundView
{
    if (self.isEditing) {
        self.collectionView.backgroundView = nil;
        return;
    }

    if (self.numberOfMessages == 0 && self.hasReachedEnd) {
        self.collectionView.backgroundView = [GSChatIceBreakerView iceBreakerViewWithMessage:kGSChatUIIceBreaker];
        return;
    }

    if (self.numberOfMessages > 0) {
        self.collectionView.backgroundView = nil;
        return;
    }

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    spinner.color = [UIColor grayColor];
    [spinner startAnimating];

    self.collectionView.backgroundView = spinner;
}

- (BOOL)messageIsOwnAtIndexPath:(NSIndexPath *)indexPath
{
    GSChatMessage *message = [self.chatManager messageAtIndex:indexPath.item];
    return [self messageIsOwn:message];
}

- (BOOL)messageIsOwn:(GSChatMessage *)message
{
    return message.sender == GSChatSenderClient;
}

- (void)dismissKeyboard:(id)sender
{
    [self.inputAccessoryView endEditing];
}

- (void)dismissChatViewController:(id)sender
{
    [self dismissKeyboard:nil];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openConnection
{
    [self.chatManager setConfigWithTracker:self.tracker];
    [self.chatManager openWebSocket];
}

- (void)closeConnection
{
    [self.chatManager closeWebSocket];
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
    if (self.numberOfMessages > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.numberOfMessages-1 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
        });
    }
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


# pragma mark - GSChatComposeViewDelegate

- (void)didBeginEditing
{
    self.editing = YES;
    self.collectionView.backgroundView = nil;

    [self scrollToBottomAnimated:YES];
}

- (void)didEditText
{
    [self.chatManager sendTypingNotification];
}

- (void)didEndEditing
{
    self.editing = NO;

    [self updateBackgroundView];
}

- (void)didSendMessage:(NSString *)message
{
    GSChatMessage *msg = [GSChatMessage messageWithContent:message sender:GSChatSenderClient];

    [self.chatManager sendMessage:msg];
}


# pragma mark - GSChatManagerDelegate

- (void)managerDidConnect
{
    if (self.isOpen) {
        [self.chatManager markRead];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionIndicator.connectionStatus = GSChatConnectionStatusConnected;
    });
}

- (void)managerDidFailToConnect
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionIndicator.connectionStatus = GSChatConnectionStatusDisconnected;
    });
}

- (void)managerDidDisconnect
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionIndicator.connectionStatus = GSChatConnectionStatusDisconnected;
    });
}

- (void)didAddMessageAtIndex:(NSUInteger)index
{
    [self.collectionView numberOfItemsInSection:0];
    
    self.numberOfMessages += 1;

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];

    if (self.isOpen) {
        [self.chatManager markRead];
    }

    dispatch_sync(dispatch_get_main_queue(), ^{
        self.collectionView.backgroundView = nil;

        [self.collectionView insertItemsAtIndexPaths:@[ indexPath ]];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];

        GSChatMessage *message = [self.chatManager messageAtIndex:index];

        // don't send message notification if its by the client
        if ([self messageIsOwn:message]) {
            return;
        }

        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                          GSMessageNotificationAuthor: [NSString stringWithFormat:@"%@ %@", message.agentFirstName, message.agentLastName],
                                                                                          GSMessageNotificationBody: message.content
                                                                                          }];
        if (message.avatar != nil) {
            userInfo[GSMessageNotificationAvatar] = message.avatar;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:GSMessageNotification object:self userInfo:userInfo];
    });
}

- (void)didUpdateMessageAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    BOOL viewShouldScroll = self.collectionView.contentSize.height > self.view.frame.size.height;

    dispatch_sync(dispatch_get_main_queue(), ^{
        if (self.isScrolling && viewShouldScroll) {
            [self.itemsToReload addObject:indexPath];
        } else {
            [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
        }
    });
}

- (void)didRemoveMessageAtIndex:(NSUInteger)index
{
    self.numberOfMessages -= 1;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];

    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
    });
}

- (void)didAddMessagesInRange:(NSRange)range
{
    self.numberOfMessages += range.length;

    dispatch_sync(dispatch_get_main_queue(), ^{
        [self updateBackgroundView];

        CGPoint beforeOffset = self.collectionView.contentOffset;
        CGFloat beforeHeight = self.collectionView.contentSize.height;
        CGFloat height = 0;

        for (int i = 0; i < self.numberOfMessages; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            height += [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath].height;
            height += ((GSChatViewLayout *)self.collectionViewLayout).minimumLineSpacing;
        }

        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.collectionView reloadData];
        self.collectionView.contentOffset = CGPointMake(0, beforeOffset.y + (height - beforeHeight));
        [CATransaction setDisableActions:NO];
        [CATransaction commit];
    });

    if (self.isOpen) {
        [self.chatManager markRead];
    }
}

- (void)didReachEndOfConversation
{
    self.hasReachedEnd = YES;

    dispatch_sync(dispatch_get_main_queue(), ^{
        [self updateBackgroundView];
    });
}

- (void)didUpdateUnreadMessageCount:(NSUInteger)count
{
    self.numberOfUnreadMessages = count;
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
    return self.numberOfMessages;
}


#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GSChatMessage *message = [self.chatManager messageAtIndex:indexPath.item];
    GSChatBubbleCell *cell = (GSChatBubbleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kGSChatBubbleCellIdentifier forIndexPath:indexPath];

    if (cell.delegate == nil) {
        cell.delegate = self;
    }

    cell.message = message;

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (![kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }

    if (self.hasReachedEnd) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kGSChatHeaderEndIdentifier forIndexPath:indexPath];
    } else {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kGSChatHeaderLoadingIdentifier forIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GSChatMessage *message = [self.chatManager messageAtIndex:indexPath.item];
    GSChatBubbleContent *content = [[GSChatBubbleContent alloc] initWithFrame:CGRectZero];
    content.text = message.content;
    [content sizeToFit];

    return [content sizeThatFits:CGSizeMake(260, CGFLOAT_MAX)];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.numberOfMessages > 0) {
        return CGSizeMake(collectionView.frame.size.width, 60);
    } else {
        return CGSizeZero;
    }
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
        GSChatMessage *message = [self.chatManager messageAtIndex:indexPath.item];
        [[UIPasteboard generalPasteboard] setString:message.content];
    }
}


# pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrolling = YES;

    BOOL isScrolledAboveTop = (scrollView.contentOffset.y + scrollView.contentInset.top) <= 0;

    if (isScrolledAboveTop && self.isOpen && !self.hasReachedEnd) {
        [self.chatManager loadMessageHistory];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.scrolling = NO;

    [self.collectionView reloadItemsAtIndexPaths:self.itemsToReload];
    [self.itemsToReload removeAllObjects];
}

@end
