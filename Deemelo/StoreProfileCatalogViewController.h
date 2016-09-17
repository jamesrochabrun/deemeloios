//
//  StoreProfileCatalogViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 6/19/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureCollectionViewController.h"
#import "Store.h"
#import "APIProvider.h"

@interface StoreProfileCatalogViewController : PictureCollectionViewController <PictureCollectionViewControllerDatasource>

@property (weak, nonatomic) Store *selectedStore;

@end
