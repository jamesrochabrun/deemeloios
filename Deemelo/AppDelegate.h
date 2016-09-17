//
//  AppDelegate.h
//  Deemelo
//
//  Created by Cesar Ortiz on 02-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "SignUpViewController.h"
#import "LoginViewController.h"
#import "ImageDetail.h"
#import "Categories.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Product.h"
#import "PhotoViewController.h"
#import "User.h"
#import "Store.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) UITabBarController *tabController;

@property (strong, nonatomic) FBSession *session;

@property (strong, nonatomic) NSMutableArray *prendas, *categories, *categoryImages;

@property (nonatomic) ImageDetail *objectDetail;
@property (nonatomic) Categories *categorySelected;
@property (nonatomic) Store *storeSelected;

// properties para crear nuevo producto
@property (strong, nonatomic) UINavigationController *aNewProductNavController;
@property (strong, nonatomic) UIViewController *photoController;
@property BOOL isAddingNewProduct;
@property (strong, nonatomic) Product *aNewProduct;
@property (strong, nonatomic) UIViewController *aNewProductCategoryController;

// referencia al current user
@property (strong, nonatomic) User *currentUser;

extern NSString *const FBSessionStateChangedNotification;

+ (AppDelegate*)sharedAppdelegate;
- (void)setNewRootControllerWithSB:(NSString*)storyboardName andIdentifier:(NSString*)identifier;
- (void)setNewRootControllerWithModifiedViewController:(UIViewController*)viewController;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
+ (BOOL)isRetina4;

- (void)getItemsFromAPI;

@end
