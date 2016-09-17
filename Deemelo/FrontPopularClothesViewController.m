//
//  FrontPopularClothesViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 7/1/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "FrontPopularClothesViewController.h"

@implementation FrontPopularClothesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[self tabBarItem] setTitle:@"Populares"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"\n\n\n self.navigationController: %@", self.navigationController);
//    NSLog(@"\n\n\n self.navigationItem: %@", self.navigationItem);
//    
//    self.navigationItem.titleView = [CustomBarButtonItems titleView:self.navigationController.navigationBar view:self.view];
//    self.navigationItem.rightBarButtonItem = [CustomBarButtonItems rightBarButtonWithImageName:@"lupa.png"];
    
    //AppDelegate *appDelegate = [AppDelegate sharedAppdelegate];
    //self.array = appDelegate.prendas;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PictureCollectionViewControllerDatasource

- (void)loadCollection
{
    if (![self collection]) {
        // mostrar el indicador de cargando
        [SVProgressHUD show];
        
        // cargar las fotos de la portada
        [APIProvider getPopularClothesFromOffset:0
                                     withSuccess:^(NSMutableArray *collection) {
                                         [self setCollection:collection];
                                         
                                         [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                         
                                         //NSLog(@"Cargó las fotos de la portada");
                                         
                                         [SVProgressHUD dismiss];
                                     }
                                         failure:^{
                                             [self setCollection:nil];
                                             
                                             [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                             
                                             //NSLog(@"Error al cargar las fotos de la portada");
                                             
                                             [SVProgressHUD dismiss];
                                         }];
    }
}

- (void)refreshCollection
{
    [self setCollection:nil];
    
    // mostrar el indicador de cargando
    [[self pullToRefreshView] startLoading];
    
    // cargar las fotos de la portada
    [APIProvider getPopularClothesFromOffset:0
                                 withSuccess:^(NSMutableArray *collection) {
                                     [self setCollection:collection];
                                     
                                     [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                     
                                     //NSLog(@"Cargó las fotos de la portada");
                                     
                                     [[self pullToRefreshView] finishLoading];
                                     [[[self collectionView] infiniteScrollingView] stopAnimating];
                                 }
                                     failure:^{
                                         //NSLog(@"Error al cargar las fotos de la portada");
                                         
                                         [[self pullToRefreshView] finishLoading];
                                         [[[self collectionView] infiniteScrollingView] stopAnimating];
                                     }];
}

- (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset
{
    if ([self collection]) {
        // cargar más fotos de la portada
        [APIProvider getPopularClothesFromOffset:[offset intValue]
                                     withSuccess:^(NSMutableArray *collection) {
                                         [[self collection] addObjectsFromArray:collection];
                                         
                                         [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                         
                                         //NSLog(@"Cargó las fotos de la portada");
                                         
                                         [[self pullToRefreshView] finishLoading];
                                         [[[self collectionView] infiniteScrollingView] stopAnimating];
                                     }
                                         failure:^{
                                             //NSLog(@"Error al cargar las fotos de la portada");
                                             
                                             [[self pullToRefreshView] finishLoading];
                                             [[[self collectionView] infiniteScrollingView] stopAnimating];
                                         }];
    }
}

@end
