//
//  StoreMapPoint.h
//  Deemelo
//
//  Created by Pablo Branchi on 6/12/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface StoreMapPoint : NSObject <MKAnnotation>
{
    
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString *)title;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
