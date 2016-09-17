//
//  StoresProfileSearchByProductViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 7/12/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "StoresProfileSearchByProductViewController.h"

@implementation StoresProfileSearchByProductViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self view] setFrame:CGRectMake([[self view] frame].origin.x,
                                     [[self view] frame].origin.y,
                                     [[self view] frame].size.width,
                                     44)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //[searchBar resignFirstResponder];
    
    // volver al parent para que ejecute la búsqueda
    [[self parentVC] dismissSemiModalViewWithCompletion:^{
        [[self parentVC] showSearchResultForSearchString:[searchBar text]];
    }];
}

@end
