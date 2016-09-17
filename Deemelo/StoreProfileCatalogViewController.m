//
//  StoreProfileCatalogViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 6/19/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "StoreProfileCatalogViewController.h"

@implementation StoreProfileCatalogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:nil image:nil tag:200]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"lookbookActive.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PictureCollectionViewControllerDatasource

- (void)loadCollection
{
    if (![self collection] || ([[self collection] count] < 3)) {
        // mostrar el indicador de cargando
        [SVProgressHUD show];
        
        // cargar las fotos del catálogo de la tienda
        [APIProvider getStoreProfileCatalogPicturesFromStoreID:[[self selectedStore] storeID]
                                                        offset:0
                                                   withSuccess:^(NSMutableArray *collection) {
                                                       [self setCollection:collection];
                                                       
                                                       [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                       
                                                       //NSLog(@"Cargó las fotos del catálogo de la tienda");
                                                       
                                                       [SVProgressHUD dismiss];
                                                   }
                                                       failure:^{
                                                           [self setCollection:nil];
                                                           
                                                           [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                           
                                                           //NSLog(@"Error al cargar las fotos del catálogo de la tienda");
                                                           
                                                           [SVProgressHUD dismiss];
                                                       }];
    }
}

- (void)refreshCollection
{
    [self setCollection:nil];
    
    // mostrar el indicador de cargando
    [[self pullToRefreshView] startLoading];
    
    // cargar las fotos del catálogo de la tienda
    [APIProvider getStoreProfileCatalogPicturesFromStoreID:[[self selectedStore] storeID]
                                                    offset:0
                                               withSuccess:^(NSMutableArray *collection) {
                                                   [self setCollection:collection];
                                                   
                                                   [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                   
                                                   //NSLog(@"Cargó las fotos del catálogo de la tienda");
                                                   
                                                   [[self pullToRefreshView] finishLoading];
                                                   [[[self collectionView] infiniteScrollingView] stopAnimating];
                                               }
                                                   failure:^{
                                                       //NSLog(@"Error al cargar las fotos del catálogo de la tienda");
                                                       
                                                       [[self pullToRefreshView] finishLoading];
                                                       [[[self collectionView] infiniteScrollingView] stopAnimating];
                                                   }];
}

- (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset
{
    if ([self collection]) {
        // cargar más fotos del catálogo de la tienda
        [APIProvider getStoreProfileCatalogPicturesFromStoreID:[[self selectedStore] storeID]
                                                        offset:[offset intValue]
                                                   withSuccess:^(NSMutableArray *collection) {
                                                       [[self collection] addObjectsFromArray:collection];
                                                       
                                                       [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                       
                                                       //NSLog(@"Cargó las fotos del catálogo de la tienda");
                                                       
                                                       [[self pullToRefreshView] finishLoading];
                                                       [[[self collectionView] infiniteScrollingView] stopAnimating];
                                                   }
                                                       failure:^{
                                                           //NSLog(@"Error al cargar las fotos del catálogo de la tienda");
                                                           
                                                           [[self pullToRefreshView] finishLoading];
                                                           [[[self collectionView] infiniteScrollingView] stopAnimating];
                                                       }];
    }
}

@end
