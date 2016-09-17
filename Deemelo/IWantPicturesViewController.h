//
//  IWantPicturesViewController.h
//  Deemelo
//
//  Created by Marcelo Espina on 24-06-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIProvider.h"
#import "PictureCollectionViewController.h"

@interface IWantPicturesViewController : PictureCollectionViewController <PictureCollectionViewControllerDatasource>

@property (nonatomic) NSString *email;

@property (nonatomic) NSString *iWantCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil email:(NSString *)email storyboard:(UIStoryboard *)storyboard iWantCount:(NSString *)iWantCount;

@end
