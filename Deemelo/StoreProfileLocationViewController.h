//
//  StoreProfileLocationViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 6/19/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Store.h"
#import "StoreMapPoint.h"
#import "APIProvider.h"

@interface StoreProfileLocationViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) Store *selectedStore;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
