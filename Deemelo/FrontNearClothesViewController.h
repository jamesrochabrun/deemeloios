//
//  FrontNearClothesViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 9/13/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureCollectionViewController.h"
#import "APIProvider.h"

@interface FrontNearClothesViewController : PictureCollectionViewController <PictureCollectionViewControllerDatasource, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) NSDate *lastLocationUpdate;
@property (nonatomic, strong) CLLocation *lastLocation;

@end
