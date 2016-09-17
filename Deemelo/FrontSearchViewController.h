//
//  FrontSearchViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 7/11/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrontViewController.h"

@interface FrontSearchViewController : UIViewController <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) FrontViewController *parentVC;

@property (weak, nonatomic) IBOutlet UISegmentedControl *SearchTypeControl;

@property (nonatomic) FrontSearchType searchType;

- (IBAction)changeSearchType:(id)sender;

@end
