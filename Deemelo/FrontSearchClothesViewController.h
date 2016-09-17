//
//  FrontSearchClothesViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 7/12/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureCollectionViewController.h"
#import "APIProvider.h"

@interface FrontSearchClothesViewController : PictureCollectionViewController <PictureCollectionViewControllerDatasource>

@property (copy, nonatomic) NSString *searchString;
@property (copy, nonatomic) NSString *searchType;
@property (copy, nonatomic) CLLocation *searchLocation;

@end
