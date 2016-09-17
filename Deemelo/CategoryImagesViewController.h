//
//  CategoryImagesViewController.h
//  Deemelo
//
//  Created by Cesar Ortiz on 29-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureCollectionViewController.h"
#import "Categories.h"
#import "APIProvider.h"

@interface CategoryImagesViewController : PictureCollectionViewController <PictureCollectionViewControllerDatasource>

@property (weak, nonatomic) Categories *selectedCategory;

- (void)backFromCategoryImages:(id)sender;

@end
