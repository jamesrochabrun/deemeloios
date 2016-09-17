//
//  FollowingViewController.h
//  Deemelo
//
//  Created by Marcelo Espina on 25-06-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "APIProvider.h"

#import "UserCollectionViewController.h"

#import "ProfileViewController.h"

@interface FollowingViewController : UserCollectionViewController

@property (nonatomic) NSString *followingCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil email:(NSString *) email storyboard:(UIStoryboard *)storyboard followingCount:(NSString *)followingCount;

@end
