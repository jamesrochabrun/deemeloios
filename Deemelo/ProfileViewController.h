//
//  ProfileViewController.h
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBarButtonItems.h"
#import "AppDelegate.h"
#import "APIProvider.h"

#import "MHTabBarController.h"

@class ProfilePicturesViewController;
@class IWantPicturesViewController;
@class FollowersViewController;
@class FollowingViewController;

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *profileUrl;
@property (weak, nonatomic) IBOutlet UIImageView *profileAvatar;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *profileImagesContainer;
@property (weak, nonatomic) IBOutlet UIView *iWantImagesContainer;
@property (weak, nonatomic) IBOutlet UITableView *followingProfilesContainer;
@property (weak, nonatomic) IBOutlet UITableView *followersProfilesContainer;

@property (weak, nonatomic) IBOutlet UIView *tabBarContainer;

@property (strong, nonatomic) MHTabBarController *tab;

@property (weak, nonatomic) ProfilePicturesViewController *profilePicturesVC;
@property (weak, nonatomic) IWantPicturesViewController *profileIWantVC;
@property (weak, nonatomic) FollowingViewController *profileFollowingVC;
@property (weak, nonatomic) FollowersViewController *profileFollowersVC;

@property (strong, nonatomic) NSString *currentEmail;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (weak, nonatomic) IBOutlet UIButton *configureButton;

- (IBAction)followButtonPressed:(id)sender;
- (IBAction)configureButtonPressed:(id)sender;

@end
