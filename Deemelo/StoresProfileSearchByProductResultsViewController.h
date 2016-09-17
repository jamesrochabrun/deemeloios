//
//  StoresProfileSearchByProductResultsViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 7/30/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureCollectionViewController.h"
#import "APIProvider.h"

@interface StoresProfileSearchByProductResultsViewController : PictureCollectionViewController <PictureCollectionViewControllerDatasource>

@property (copy, nonatomic) NSString *searchString;
@property (nonatomic) NSUInteger storeID;

@end
