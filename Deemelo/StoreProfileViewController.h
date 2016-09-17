//
//  StoreProfileViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 6/18/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CustomBarButtonItems.h"
#import "AppDelegate.h"
#import "Store.h"
//#import "StoreMapPoint.h"
//#import <QuartzCore/QuartzCore.h>
//#import <SSPullToRefresh/SSPullToRefresh.h>
#import "StoreProfileCommunityViewController.h"
#import "StoreProfileCatalogViewController.h"
#import "StoreProfileLocationViewController.h"
#import "MHTabBarController.h"
#import "UIViewController+KNSemiModal.h"
@class StoresProfileSearchByProductViewController;

@interface StoreProfileViewController : UIViewController
{
    StoresProfileSearchByProductViewController *storesProfileSearchVC;
}


@property (strong, nonatomic) Store *selectedStore;

@property (weak, nonatomic) IBOutlet UILabel *selectedStoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedStoreImageView;

@property (weak, nonatomic) IBOutlet UIView *storeDetailsContainerView;

@property (strong, nonatomic) MHTabBarController *tab;

// abrir buscador de prendas
- (void)searchStoreProfileButtonTapped:(id)sender;

// ejecutar tipo de búsqueda por tipo y string
- (void)showSearchResultForSearchString:(NSString *)searchString;

@end
