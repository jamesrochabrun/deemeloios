//
//  StoresProfileSearchByProductResultsViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 7/30/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "StoresProfileSearchByProductResultsViewController.h"

@implementation StoresProfileSearchByProductResultsViewController

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
	
    // agregar el botón "volver" al navbar
    UIImage *backImage = [UIImage imageNamed:@"back.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBounds:CGRectMake( 0, 0, [backImage size].width, [backImage size].height)];
    [backButton setImage:backImage
                forState:UIControlStateNormal];
    
    [backButton addTarget:self
                   action:@selector(goBack:)
         forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [[self navigationItem] setLeftBarButtonItem:backButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack:(id)sender
{
    //NSLog(@"GO BACK");
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - PictureCollectionViewControllerDatasource

- (void)loadCollection
{
    if (![self collection]) {
        // mostrar el indicador de cargando
        [SVProgressHUD show];
        
        // cargar las fotos de la búsqueda
        [APIProvider getStoreProfileSearchByProductPicturesFromSearchString:[self searchString]
                                                                 andStoreID:[self storeID]
                                                                     offset:0
                                                                withSuccess:^(NSMutableArray *collection) {
                                                                    [self setCollection:collection];
                                                                    
                                                                    [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                                    
                                                                    //NSLog(@"Cargó las fotos de la búsqueda");
                                                                    
                                                                    [SVProgressHUD dismiss];
                                                                }
                                                                    failure:^{
                                                                        [self setCollection:nil];
                                                                        
                                                                        [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                                        
                                                                        //NSLog(@"Error al cargar las fotos de la búsqueda");
                                                                        
                                                                        [SVProgressHUD dismiss];
                                                                    }];
    }
}

- (void)refreshCollection
{
    [self setCollection:nil];
    
    // mostrar el indicador de cargando
    [[self pullToRefreshView] startLoading];
    
    // cargar las fotos de la búsqueda
    [APIProvider getStoreProfileSearchByProductPicturesFromSearchString:[self searchString]
                                                             andStoreID:[self storeID]
                                                                 offset:0
                                                            withSuccess:^(NSMutableArray *collection) {
                                                                [self setCollection:collection];
                                                                
                                                                [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                                
                                                                //NSLog(@"Cargó las fotos de la búsqueda");
                                                                
                                                                [[self pullToRefreshView] finishLoading];
                                                                [[[self collectionView] infiniteScrollingView] stopAnimating];
                                                            }
                                                                failure:^{
                                                                    //NSLog(@"Error al cargar las fotos de la búsqueda");
                                                                    
                                                                    [[self pullToRefreshView] finishLoading];
                                                                    [[[self collectionView] infiniteScrollingView] stopAnimating];
                                                                }];
}

- (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset
{
    if ([self collection]) {
        // cargar más fotos de la búsqueda
        [APIProvider getStoreProfileSearchByProductPicturesFromSearchString:[self searchString]
                                                                 andStoreID:[self storeID]
                                                                     offset:[offset intValue]
                                                                withSuccess:^(NSMutableArray *collection) {
                                                                    [[self collection] addObjectsFromArray:collection];
                                                                    
                                                                    [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                                    
                                                                    //NSLog(@"Cargó las fotos de la búsqueda");
                                                                    
                                                                    [[self pullToRefreshView] finishLoading];
                                                                    [[[self collectionView] infiniteScrollingView] stopAnimating];
                                                                }
                                                                    failure:^{
                                                                        //NSLog(@"Error al cargar las fotos de la búsqueda");
                                                                        
                                                                        [[self pullToRefreshView] finishLoading];
                                                                        [[[self collectionView] infiniteScrollingView] stopAnimating];
                                                                    }];
    }
}

@end
