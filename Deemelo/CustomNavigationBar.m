//
//  CustomNavigationBar.m
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customize];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customize];
    }
    return self;
}

-(void) customize {
    [self setBackgroundImage:[UIImage imageNamed:@"header.png"] forBarMetrics:UIBarMetricsDefault];
}

@end
