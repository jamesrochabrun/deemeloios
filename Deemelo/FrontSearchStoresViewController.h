//
//  FrontSearchStoresViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 7/12/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Store.h"
#import "StoreTableViewCell.h"
#import "StoreProfileViewController.h"
#import <SSPullToRefresh/SSPullToRefresh.h>
#import "SVPullToRefresh.h"

@interface FrontSearchStoresViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SSPullToRefreshViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSString *searchString;
@property (strong, nonatomic) NSMutableArray *collection;
@property (weak, nonatomic) UIStoryboard *myStoryboard;

@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;

@end
