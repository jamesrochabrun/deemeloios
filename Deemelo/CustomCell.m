//
//  CustomCell.m
//  Deemelo
//
//  Created by Cesar Ortiz on 22-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

@synthesize view;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.view = [[UIView alloc] initWithFrame:self.bounds];
        [self.view setBackgroundColor:[UIColor orangeColor]];
        
        [self.contentView addSubview:self.view];
    }
    return self;
}

@end
