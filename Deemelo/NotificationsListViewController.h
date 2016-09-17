//
//  NotificationsListViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 9/5/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSPullToRefresh/SSPullToRefresh.h>
#import "SVPullToRefresh.h"

@interface NotificationsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SSPullToRefreshViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSString *currentUserEmail;
@property (strong, nonatomic) NSMutableArray *collection;
@property (weak, nonatomic) UIStoryboard *myStoryboard;

@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;

- (void)loadCollection;
- (void)refreshCollection;
- (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset;

@end