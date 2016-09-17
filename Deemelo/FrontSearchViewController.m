//
//  FrontSearchViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 7/11/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "FrontSearchViewController.h"
#import "FrontViewController.h"

@implementation FrontSearchViewController

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
    
    [[self SearchTypeControl] setSelectedSegmentIndex:0];
    [self changeSearchType:[self SearchTypeControl]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self view] setFrame:CGRectMake([[self view] frame].origin.x,
                                     [[self view] frame].origin.y,
                                     [[self view] frame].size.width,
                                     88)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeSearchType:(id)sender
{
    [self setSearchType:[sender selectedSegmentIndex]];
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [[self searchBar] setPlaceholder:@"Busca una prenda"];
            break;
            
        case 1:
            [[self searchBar] setPlaceholder:@"Busca una tienda"];
            break;
            
        case 2:
            [[self searchBar] setPlaceholder:@"Busca una persona"];
            break;
            
        default:
            break;
    }
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //[searchBar resignFirstResponder];
    
    // volver al parent para que ejecute la búsqueda
    [[self parentVC] dismissSemiModalViewWithCompletion:^{
        [[self parentVC] showSearchResultForType:[self searchType]
                                    searchString:[searchBar text]];
    }];
}

@end
