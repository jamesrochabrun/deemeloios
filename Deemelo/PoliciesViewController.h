//
//  PoliciesViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 8/28/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoliciesViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) void (^acceptedPoliciesDismissBlock)(void);

@end
