//
//  StoresProfileSearchByProductViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 7/12/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreProfileViewController.h"

@interface StoresProfileSearchByProductViewController : UIViewController  <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *productSearchBar;

@property (weak, nonatomic) StoreProfileViewController *parentVC;

@end
