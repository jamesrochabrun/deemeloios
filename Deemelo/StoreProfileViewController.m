//
//  StoreProfileViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 6/18/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "StoreProfileViewController.h"
#import "StoresProfileSearchByProductViewController.h"
#import "StoresProfileSearchByProductResultsViewController.h"

@implementation StoreProfileViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tiendas" image:nil tag:3];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tiendas_activo.png"]
                      withFinishedUnselectedImage:[UIImage imageNamed:@"tiendas"]];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, 0, 0);
        self.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
        
        // crear el buscador de tiendas por prenda
        storesProfileSearchVC = [[StoresProfileSearchByProductViewController alloc] initWithNibName:nil bundle:nil];
        [storesProfileSearchVC setParentVC:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [CustomBarButtonItems titleView:self.navigationController.navigationBar view:self.view];
    
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
    
    // agregar botón para buscar prendas
    UIImage *searchImage = [UIImage imageNamed:@"lupa.png"];
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setBounds:CGRectMake( 0, 0, [searchImage size].width, [searchImage size].height)];
    [searchButton setImage:searchImage
                  forState:UIControlStateNormal];
    
    [searchButton addTarget:self
                     action:@selector(searchStoreProfileButtonTapped:)
           forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    [[self navigationItem] setRightBarButtonItem:searchButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // agregar nombre de la tienda
    [[self selectedStoreLabel] setText:[[self selectedStore] name]];
    
    // agregar avatar de la tienda
    if ([[self selectedStore] ruta_thumbnail]) {
        
        // si tengo la url del avatar poner foto en el uiimageview
        [self setStoreAvatarImage];
        
    } else {
        [APIProvider getStoreDetailFromStoreID:[[self selectedStore] storeID]
                                   withSuccess:^(Store *store) {
                                       
                                       [[self selectedStore] setRuta_thumbnail:[store ruta_thumbnail]];
                                       
                                       // poner foto en el uiimageview
                                       [self setStoreAvatarImage];
                                       
                                   }
                                       failure:^{
                                           
                                           //NSLog(@"Error al cargar el detalle de la tienda");
                                           
                                       }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self tab]) {
        // agregar los viewcontrollers del container
        [self setTab:[[MHTabBarController alloc] init]];
        
        StoreProfileCommunityViewController *communityVC =
            [[StoreProfileCommunityViewController alloc] initWithNibName:nil bundle:nil];
        [communityVC setMyStoryboard:[self storyboard]];
        [communityVC setSelectedStore:[self selectedStore]];
        
        StoreProfileCatalogViewController *catalogVC =
            [[StoreProfileCatalogViewController alloc] initWithNibName:nil bundle:nil];
        [catalogVC setMyStoryboard:[self storyboard]];
        [catalogVC setSelectedStore:[self selectedStore]];
        
        StoreProfileLocationViewController *locationVC =
            [[self storyboard] instantiateViewControllerWithIdentifier:@"storeProfileLocationViewController"];
        [locationVC setSelectedStore:[self selectedStore]];
        
        [[self tab] setViewControllers:@[communityVC, catalogVC, locationVC]];
        
        [self addChildViewController:[self tab]];
        [[[self tab] view] setFrame:[[self storeDetailsContainerView] frame]];
        [[self view] addSubview:[[self tab] view]];
        
        [[self tab] didMoveToParentViewController:self];
    } else {
        // en caso que un memory warning haya eliminado la vista de tab, recargarla
        if (![[self tab] isViewLoaded]) {
            [self addChildViewController:[self tab]];
            [[[self tab] view] setFrame:[[self storeDetailsContainerView] frame]];
            [[self view] addSubview:[[self tab] view]];
            
            [[self tab] didMoveToParentViewController:self];
        }
    }
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

// este método asume que tenemos [[self selectedStore] ruta_thumbnail], lo baja y lo pone en el uiimageview
- (void)setStoreAvatarImage
{
    if (![[[self selectedStore] ruta_thumbnail] isEqualToString:@""]) {
        NSURLRequest *imageReq = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self selectedStore] ruta_thumbnail]]];
        [[self selectedStoreImageView] setImageWithURLRequest:imageReq
                                             placeholderImage:[UIImage imageNamed:@"avatarTienda@2x.png"]
                                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                          
                                                          // setear imagen
                                                          [[self selectedStoreImageView] setImage:image];
                                                          
                                                          // configurar border del imageview
                                                          self.selectedStoreImageView.layer.borderColor = [[UIColor colorWithRed:109/255
                                                                                                                           green:103/255
                                                                                                                            blue:98/255
                                                                                                                           alpha:1.0] CGColor];
                                                          self.selectedStoreImageView.layer.borderWidth = 1.0f;
                                                          
                                                      }
                                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                          
                                                          // no llegó la imagen
                                                          
                                                      }];
    }
}

- (void)searchStoreProfileButtonTapped:(id)sender
{
    [self presentSemiViewController:storesProfileSearchVC
                        withOptions:@{KNSemiModalOptionKeys.animationDuration: @(0.2),
     KNSemiModalOptionKeys.pushParentBack: @(YES)}
                         completion:^{
                             [[storesProfileSearchVC productSearchBar] becomeFirstResponder];
                             [self resizeSemiView:CGSizeMake([[storesProfileSearchVC view] frame].size.width,
                                                             260)];
                         }
                       dismissBlock:^{
                           
                       }];
}

- (void)showSearchResultForSearchString:(NSString *)searchString
{
    //NSLog(@"%@", searchString);
    
    StoresProfileSearchByProductResultsViewController *storesProfileSearchByProductResultsVC =
        [[StoresProfileSearchByProductResultsViewController alloc] initWithNibName:nil bundle:nil];
    
    [storesProfileSearchByProductResultsVC setMyStoryboard:[self storyboard]];
    [storesProfileSearchByProductResultsVC setSearchString:searchString];
    [storesProfileSearchByProductResultsVC setStoreID:[[self selectedStore] storeID]];
    [[storesProfileSearchByProductResultsVC navigationItem] setTitle:searchString];
    
    [[self navigationController] pushViewController:storesProfileSearchByProductResultsVC animated:YES];
}

@end
