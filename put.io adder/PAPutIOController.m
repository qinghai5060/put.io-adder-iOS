//
//  PAPutIOController.m
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <PutioKit/PutIONetworkConstants.h>

#import "PAPutIOController.h"

@implementation PAPutIOController

+ (PAPutIOController *)sharedController;
{
    static PAPutIOController *sharedController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[PAPutIOController alloc] init];
    });
    
    return sharedController;
}

- (id)init;
{
    self = [super init];
    
    if (self) {
        _putIOClient = [V2PutIOAPIClient setup];
    }
    
    return self;
}

- (UIViewController *)authenticationViewController;
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = NSLocalizedString(@"log in to put.io", @"authentication view controller title");
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:viewController.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [viewController.view addSubview:webView];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [webView setShouldStartLoadBlock:^BOOL(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType) {
        NSURL *URL = request.URL;
        
        if ([URL.host isEqualToString:@"localhost"]) {
            self.putIOClient.apiToken = [URL.fragment substringFromIndex:13];
            [[NSUserDefaults standardUserDefaults] setObject:self.putIOClient.apiToken forKey:PKAppAuthTokenDefault];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [navigationController dismissViewControllerAnimated:YES completion:nil];
            return NO;
        }

        return YES;
    }];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.put.io/v2/oauth2/authenticate?client_id=741&response_type=token&redirect_uri=http://localhost/"]]];
    
    return navigationController;
}

@end