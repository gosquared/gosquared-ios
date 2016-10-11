//
//  GSChatManager.m
//  GoSquared
//
//  Created by Edward Wellbrook on 04/02/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatManager.h"
#import "GoSquared.h"
#import "GSTrackerDelegate.h"

@implementation GSChatManager

+ (NSString *)configForTracker:(GSTracker *)tracker
{
    NSMutableDictionary<NSString *, NSString *> *props = [[NSMutableDictionary alloc] init];

    NSString *personId = tracker.personId;
    if (personId != nil) {
        props[@"person_id"] = personId;
    }

    NSString *visitorId = tracker.visitorId;
    if (visitorId != nil) {
        props[@"client_id"] = visitorId;
    }

    NSString *signature = tracker.signature;
    if (signature != nil) {
        props[@"securemode_auth"] = signature;
    }

    NSString *token = tracker.token;
    if (token != nil) {
        props[@"site_token"] = token;
    }
    
    NSDictionary *pageview = tracker.currentPageviewData;
    if (pageview != nil) {
        props[@"page_title"] = pageview[@"title"] ?: @"";
        props[@"page_url"] = pageview[@"URLString"] ?: @"";
    }
    
    props[@"font_size"] = @([UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize);

    NSString *config = @"window.embedded_config = {\n";
    for (NSString *name in props) {
        config = [config stringByAppendingFormat:@"  %@: '%@',\n", name, [props objectForKey:name]];
    }
    
    config = [config stringByAppendingString:@"};"];

    return config;
}

- (instancetype)initWithTracker:(GSTracker *)tracker
{
    if (self = [super init]) {
        [self addScriptMessageHandler:self name:@"log"];
        [self addScriptMessageHandler:self name:@"open_url"];
        [self addScriptMessageHandler:self name:@"index_ready"];
        [self addScriptMessageHandler:self name:@"chat_ready"];
        [self addScriptMessageHandler:self name:@"set_unread"];
        [self addScriptMessageHandler:self name:@"new_message"];
        [self addScriptMessageHandler:self name:@"config"];
    }
    return self;
}

- (void)setNumberOfUnreadMessages:(NSUInteger)numberOfUnreadMessages
{
    _numberOfUnreadMessages = numberOfUnreadMessages;

    if ([self.managerDelegate respondsToSelector:@selector(didUpdateUnreadMessageCount:)]) {
        [self.managerDelegate didUpdateUnreadMessageCount:self.numberOfUnreadMessages];
    }
}


# pragma mark WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"log"]) {
        NSLog(@"%@", message.body);
    } else if ([message.name isEqualToString:@"open_url"]) {
        [self handleOpenURL:message.body];
    } else if ([message.name isEqualToString:@"index_ready"]) {
        [self.managerDelegate webviewDidLoad];
    } else if ([message.name isEqualToString:@"chat_ready"]) {
        [self.managerDelegate chatDidLoad];
    } else  if ([message.name isEqualToString:@"set_unread"]) {
        [self.managerDelegate didUpdateUnreadMessageCount:[message.body unsignedIntegerValue]];
    } else  if ([message.name isEqualToString:@"new_message"]) {
        [self receiveNewMessage:message.body];
    } else  if ([message.name isEqualToString:@"config"]) {
        [self.managerDelegate didReceiveConfig:message.body];
    }

}

-(void)receiveNewMessage:(NSDictionary *)message
{
    if (message[@"body"] == nil || [message[@"body"] isKindOfClass:[NSNull class]]) return;
    if (message[@"author"] == nil || [message[@"author"] isKindOfClass:[NSNull class]]) return;
    if (message[@"avatar"] == nil || [message[@"avatar"] isKindOfClass:[NSNull class]]) return;
    
    [self.managerDelegate didReceiveNewMessage:message];
}

- (void)updateUnreadCount
{
}

- (void)handleOpenURL:(NSString *)url
{
    if (![url isKindOfClass:NSString.class]) {
        return;
    }

    NSURL *URL = [NSURL URLWithString:url];

    if (URL != nil) {
        [self.managerDelegate didTapMessageLinkWithURL:URL];
    }
}


# pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{    
    WKNavigationType type = navigationAction.navigationType;
    
    WKNavigationActionPolicy decision = type == WKNavigationTypeLinkActivated ? WKNavigationActionPolicyCancel : WKNavigationActionPolicyAllow;
    
    decisionHandler(decision);
}


@end
