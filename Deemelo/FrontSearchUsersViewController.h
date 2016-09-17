//
//  FrontSearchUsersViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 7/17/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ProfileViewController.h"
#import <SSPullToRefresh/SSPullToRefresh.h>
#import "SVPullToRefresh.h"

@interface FrontSearchUsersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SSPullToRefreshViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSString *searchString;
@property (strong, nonatomic) NSMutableArray *collection;
@property (weak, nonatomic) UIStoryboard *myStoryboard;

@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;

@end
