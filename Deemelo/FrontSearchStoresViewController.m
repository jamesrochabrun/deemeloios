//
//  FrontSearchStoresViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 7/12/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "FrontSearchStoresViewController.h"

@implementation FrontSearchStoresViewController

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
    
    // necesario para que no se creen celdas vacías
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    [[self tableView] setTableFooterView:footer];
    
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"StoreTableViewCell" bundle:nil];
    
    // Register this NIB which contains the cell
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"StoreTableViewCell"];
    
    // agregar control para pull to refresh del collectionview
    [self setPullToRefreshView:[[SSPullToRefreshView alloc] initWithScrollView:[self tableView] delegate:self]];
    
    // agregar infinite scrolling
    [[self tableView] addInfiniteScrollingWithActionHandler:^{
        
        //NSLog(@"INFINITE SCROLL JUST TRIGGERED!!!!!!!!!!!!");
        // agregar más elementos a la colección
        
        // definir cuántos elementos tiene ahora la colección
        NSUInteger currentCollectionCount = [[self collection] count];
        
        // cargar nuevos elementos desde este offset y agregarlos a la colección
        [self performSelector:@selector(loadMoreCollectionItemsFromOffset:)
                   withObject:[NSNumber numberWithInt:currentCollectionCount]];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // limpiar celda previamente seleccionada del tableview
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // cargar la colección
    [self loadCollection];
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

#pragma mark - UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self collection] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // obtener la instancia de la tienda correspondiente a ESTA celda
    Store *st = ((Store *)[[self collection] objectAtIndex:[indexPath row]]);
    
    StoreTableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:@"StoreTableViewCell"];
    
    // setear el selected view
    UIView *selectedView = [[UIView alloc] init];
    [selectedView setBackgroundColor:[UIColor colorWithRed:(236/255.0)
                                                     green:(100/255.0)
                                                      blue:(114/255.0)
                                                     alpha:1]];
    [cell setSelectedBackgroundView:selectedView];
    
    // setear los datos de la celda
    
    // setear nombre tienda
    [[cell storeNameLabel] setText:[st name]];
    
    // setear dirección tienda
    [[cell storeAddressLabel] setText:@""];
    
    return cell;
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Store *st = ((Store *)[[self collection] objectAtIndex:[indexPath row]]);
    
    // mostrar el perfil de la tienda
    StoreProfileViewController *storeProfileVC =
        [[self myStoryboard] instantiateViewControllerWithIdentifier:@"storeProfile"];
    
    [storeProfileVC setSelectedStore:st];
    
    [[self navigationController] pushViewController:storeProfileVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

#pragma mark - SSPullToRefreshView Delegate Methods

- (BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView *)view
{
    return YES;
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self performSelector:@selector(refreshCollection)];
    //NSLog(@"StartLoading");
}

- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view
{
    //NSLog(@"FinishLoading");
}

#pragma mark - data source

- (void)loadCollection
{
    if (![self collection]) {
        // mostrar el indicador de cargando
        [SVProgressHUD show];
        
        // cargar las tiendas de la búsqueda
        [APIProvider getFrontSearchStoresFromSearchString:[self searchString]
                                                   offset:0
                                              withSuccess:^(NSMutableArray *collection) {
                                                  [self setCollection:collection];
                                                  
                                                  [[self tableView] reloadData];
                                                  
                                                  //NSLog(@"Cargó las tiendas de la búsqueda");
                                                  
                                                  [SVProgressHUD dismiss];
                                              }
                                                  failure:^{
                                                      //NSLog(@"Error al cargar las tiendas de la búsqueda");
                                                      
                                                      [SVProgressHUD dismiss];
                                                  }];
    }
}

- (void)refreshCollection
{
    [self setCollection:nil];
    
    // mostrar el indicador de cargando
    [[self pullToRefreshView] startLoading];
    
    // cargar las tiendas de la búsqueda
    [APIProvider getFrontSearchStoresFromSearchString:[self searchString]
                                               offset:0
                                          withSuccess:^(NSMutableArray *collection) {
                                              [self setCollection:collection];
                                              
                                              [[self tableView] reloadData];
                                              
                                              //NSLog(@"Cargó las tiendas de la búsqueda");
                                              
                                              [[self pullToRefreshView] finishLoading];
                                              [[[self tableView] infiniteScrollingView] stopAnimating];
                                          }
                                              failure:^{
                                                  //NSLog(@"Error al cargar las tiendas de la búsqueda");
                                                  
                                                  [[self pullToRefreshView] finishLoading];
                                                  [[[self tableView] infiniteScrollingView] stopAnimating];
                                              }];
}

- (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset
{
    if ([self collection]) {
        // cargar más tiendas de la búsqueda
        [APIProvider getFrontSearchStoresFromSearchString:[self searchString]
                                                   offset:[offset intValue]
                                              withSuccess:^(NSMutableArray *collection) {
                                                  [[self collection] addObjectsFromArray:collection];
                                                  
                                                  [[self tableView] reloadData];
                                                  
                                                  //NSLog(@"Cargó las tiendas de la búsqueda");
                                                  
                                                  [[self pullToRefreshView] finishLoading];
                                                  [[[self tableView] infiniteScrollingView] stopAnimating];
                                              }
                                                  failure:^{
                                                      //NSLog(@"Error al cargar las tiendas de la búsqueda");
                                                      
                                                      [[self pullToRefreshView] finishLoading];
                                                      [[[self tableView] infiniteScrollingView] stopAnimating];
                                                  }];
    }
}

@end
