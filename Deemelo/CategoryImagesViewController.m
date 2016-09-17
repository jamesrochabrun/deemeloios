//
//  CategoryImagesViewController.m
//  Deemelo
//
//  Created by Cesar Ortiz on 29-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "CategoryImagesViewController.h"

@implementation CategoryImagesViewController

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
    
    self.navigationItem.titleView = [CustomBarButtonItems titleView:self.navigationController.navigationBar view:self.view];
    
    //AppDelegate *sharedApp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //self.array = sharedApp.categoryImages;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // agregar el nombre de la categoría al navbar
    [[self navigationItem] setTitleView:nil];
    [[self navigationItem] setTitle:[[self selectedCategory] name]];
    
    // agregar el botón "volver" al navbar
    UIImage *backImage = [UIImage imageNamed:@"back.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBounds:CGRectMake( 0, 0, [backImage size].width, [backImage size].height)];
    [backButton setImage:backImage
                forState:UIControlStateNormal];
    
    [backButton addTarget:self
                   action:@selector(backFromCategoryImages:)
         forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [[self navigationItem] setLeftBarButtonItem:backButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backFromCategoryImages:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - PictureCollectionViewControllerDatasource

- (void)loadCollection
{
    if (![self collection] || ([[self collection] count] < 3)) {
        // mostrar el indicador de cargando
        [SVProgressHUD show];
        
        // cargar las fotos de la categoría
        [APIProvider getImagesOfSelectedCategory:[[self selectedCategory] name]
                                          offset:0
                                     withSuccess:^(NSMutableArray *collection) {
                                         [self setCollection:collection];
                                         
                                         [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                         
                                         //NSLog(@"Cargó las fotos de la categoría");
                                         
                                         [SVProgressHUD dismiss];
                                     }
                                         failure:^{
                                             [self setCollection:nil];
                                             
                                             [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                             
                                             //NSLog(@"Error al cargar las fotos de la categoría");
                                             
                                             [SVProgressHUD dismiss];
                                         }];
    }
}

- (void)refreshCollection
{
    [self setCollection:nil];
    
    // mostrar el indicador de cargando
    [[self pullToRefreshView] startLoading];
    
    // cargar las fotos de la categoría
    [APIProvider getImagesOfSelectedCategory:[[self selectedCategory] name]
                                      offset:0
                                 withSuccess:^(NSMutableArray *collection) {
                                     [self setCollection:collection];
                                     
                                     [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                     
                                     //NSLog(@"Cargó las fotos de la categoría");
                                     
                                     [[self pullToRefreshView] finishLoading];
                                     [[[self collectionView] infiniteScrollingView] stopAnimating];
                                 }
                                     failure:^{
                                         //NSLog(@"Error al cargar las fotos de la categoría");
                                         
                                         [[self pullToRefreshView] finishLoading];
                                         [[[self collectionView] infiniteScrollingView] stopAnimating];
                                     }];
}

- (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset
{
    if ([self collection]) {
        // cargar más fotos de la categoría
        [APIProvider getImagesOfSelectedCategory:[[self selectedCategory] name]
                                          offset:[offset intValue]
                                     withSuccess:^(NSMutableArray *collection) {
                                         [[self collection] addObjectsFromArray:collection];
                                         
                                         [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                         
                                         //NSLog(@"Cargó las fotos de la categoría");
                                         
                                         [[self pullToRefreshView] finishLoading];
                                         [[[self collectionView] infiniteScrollingView] stopAnimating];
                                     }
                                         failure:^{
                                             //NSLog(@"Error al cargar las fotos de la categoría");
                                             
                                             [[self pullToRefreshView] finishLoading];
                                             [[[self collectionView] infiniteScrollingView] stopAnimating];
                                         }];
    }
}

@end
