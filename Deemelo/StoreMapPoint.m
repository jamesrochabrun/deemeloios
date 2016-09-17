//
//  StoreMapPoint.m
//  Deemelo
//
//  Created by Pablo Branchi on 6/12/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "StoreMapPoint.h"

@implementation StoreMapPoint

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString *)title
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        [self setTitle:title];
    }
    return self;
}

- (id)init
{
    return [self initWithCoordinate:CLLocationCoordinate2DMake(-33.4200354080209, -70.60117493809815)
                              title:@"Test"];
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

@end
