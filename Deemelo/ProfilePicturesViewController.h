//
//  ProfilePicturesViewController.h
//  Deemelo
//
//  Created by Marcelo Espina on 19-06-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIProvider.h"
#import "PictureCollectionViewController.h"

@interface ProfilePicturesViewController : PictureCollectionViewController <PictureCollectionViewControllerDatasource>

@property (nonatomic) NSString *email;

@property (nonatomic) NSString *picturesCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil email:(NSString *)email storyboard:(UIStoryboard *)storyboard picturesCount:(NSString *)picturesCount;

@end
