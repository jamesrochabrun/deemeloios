//
//  CustomTabBar.m
//  Deemelo
//
//  Created by Cesar Ortiz on 17-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "CustomTabBar.h"

@implementation CustomTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customize];
    }
    return self;
}

-(void) customize {
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor:[UIColor colorWithRed:226./255 green:80./255 blue:98./255 alpha:1]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor:[UIColor whiteColor]} forState:UIControlStateSelected];
}

@end
