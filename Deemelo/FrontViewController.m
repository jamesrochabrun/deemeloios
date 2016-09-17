//
//  FrontViewController.m
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "FrontViewController.h"
#import "FrontPopularClothesViewController.h"
#import "FrontNearClothesViewController.h"
#import "FrontSearchViewController.h"
#import "FrontSearchClothesViewController.h"
#import "FrontSearchStoresViewController.h"
#import "FrontSearchUsersViewController.h"
#import "NotificationsListViewController.h"

@implementation FrontViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Portada" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"portada_activo.png"]
                      withFinishedUnselectedImage:[UIImage imageNamed:@"portada.png"]];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, 0, 0);
        self.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
        
        // crear el buscador
        frontSearchVC = [[FrontSearchViewController alloc] initWithNibName:nil bundle:nil];
        [frontSearchVC setParentVC:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [CustomBarButtonItems titleView:self.navigationController.navigationBar view:self.view];
    
    // agregar botón para mostrar las notificaciones
    [[self navigationItem] setLeftBarButtonItem:[self notifButtonWithCount:0]];
    
    // agregar botón para buscar prendas, tiendas, personas
    UIImage *searchImage = [UIImage imageNamed:@"lupa.png"];
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setBounds:CGRectMake( 0, 0, [searchImage size].width, [searchImage size].height)];
    [searchButton setImage:searchImage
                  forState:UIControlStateNormal];
    
    [searchButton addTarget:self
                     action:@selector(searchButtonTapped:)
           forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    [[self navigationItem] setRightBarButtonItem:searchButtonItem];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // recargar el botón de notificaciones
    [self updateNotifButton];
    
    if (![self tab]) {
        // agregar los viewcontrollers del container
        [self setTab:[[MHTabBarController alloc] init]];
        
        FrontPopularClothesViewController *popularClothesVC =
        [[FrontPopularClothesViewController alloc] initWithNibName:nil bundle:nil];
        [popularClothesVC setMyStoryboard:[self storyboard]];
        
        FrontNearClothesViewController *nearClothesVC =
        [[FrontNearClothesViewController alloc] initWithNibName:nil bundle:nil];
        [nearClothesVC setMyStoryboard:[self storyboard]];
        
        [[self tab] setViewControllers:@[popularClothesVC, nearClothesVC]];
        
        [self addChildViewController:[self tab]];
        [[[self tab] view] setFrame:[[self frontContainerView] frame]];
        [[self view] addSubview:[[self tab] view]];
        
        [[self tab] didMoveToParentViewController:self];
    } else {
        // en caso que un memory warning haya eliminado la vista de tab, recargarla
        if (![[self tab] isViewLoaded]) {
            [self addChildViewController:[self tab]];
            [[[self tab] view] setFrame:[[self frontContainerView] frame]];
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

- (UIBarButtonItem *)notifButtonWithCount:(int)count
{
    UIImage *notifImage;
    UIButton *notifButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (count == 0) {
        
        notifImage = [UIImage imageNamed:@"notifications_disabled.png"];
        
    } else {
        
        notifImage = [UIImage imageNamed:@"notifications_enabled.png"];
        
        [notifButton setTitle:[NSString stringWithFormat:@"%d", count]
                     forState:UIControlStateNormal];
        [notifButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 4.0, 0, 0)];
        [[notifButton titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
        //    [[notifButton titleLabel] setShadowOffset:CGSizeMake(-1.0, 1.0)];
        [notifButton setTitleColor:[UIColor colorWithRed:(236/255.0)
                                                   green:(100/255.0)
                                                    blue:(114/255.0)
                                                   alpha:1]
                          forState:UIControlStateNormal];
        
    }
    [notifButton setShowsTouchWhenHighlighted:YES];
    
    [notifButton setBounds:CGRectMake( 0, 0, [notifImage size].width, [notifImage size].height)];
    
    [notifButton setBackgroundImage:notifImage
                           forState:UIControlStateNormal];
    
    [notifButton addTarget:self
                    action:@selector(notifButtonTapped:)
          forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *notifButtonItem = [[UIBarButtonItem alloc] initWithCustomView:notifButton];
    
    return notifButtonItem;
}

- (void)updateNotifButton
{
    [APIProvider getUnreadNotificationsCountWithCompletion:^(int count) {
        // actualizar el botón
        [[self navigationItem] setLeftBarButtonItem:[self notifButtonWithCount:count]];
    }
                                                 withError:^{
                                                     
                                                     //NSLog(@"error al obtener el conteo de notificaciones no leídas");
                                                     
                                                 }];
}

- (void)notifButtonTapped:(id)sender
{
    // presentar vista modal con lista de notificaciones
    NotificationsListViewController *nvc = [[NotificationsListViewController alloc] init];
    [nvc setMyStoryboard:[self storyboard]];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:nvc];
    [[navController navigationBar] setBackgroundImage:[UIImage imageNamed:@"header.png"]
                                        forBarMetrics:UIBarMetricsDefault];
    
    [self presentViewController:navController
                       animated:YES
                     completion:nil];
}

- (void)searchButtonTapped:(id)sender
{
    [self presentSemiViewController:frontSearchVC
                        withOptions:@{KNSemiModalOptionKeys.animationDuration: @(0.2),
     KNSemiModalOptionKeys.pushParentBack: @(YES)}
                         completion:^{
                             [[frontSearchVC searchBar] becomeFirstResponder];
                             [self resizeSemiView:CGSizeMake([[frontSearchVC view] frame].size.width,
                                                             304)];
                         }
                       dismissBlock:^{
                           
                       }];
}

- (void)showSearchResultForType:(FrontSearchType)searchType
                   searchString:(NSString *)searchString
{
    //NSLog(@"%d %@", searchType, searchString);
    
    switch (searchType) {
        case FrontSearchTypeClothing:
        {
            FrontSearchClothesViewController *frontSearchClothesVC = [[FrontSearchClothesViewController alloc] initWithNibName:nil bundle:nil];
            
            [frontSearchClothesVC setMyStoryboard:[self storyboard]];
            [frontSearchClothesVC setSearchString:searchString];
            [[frontSearchClothesVC navigationItem] setTitle:searchString];
            
            id selectedVC = [[self tab] selectedViewController];
            
            if ([selectedVC isMemberOfClass:[FrontPopularClothesViewController class]]) {
                
                [frontSearchClothesVC setSearchType:FRONT_SEARCH_TYPE_POPULAR];
                
            }
            
            if ([selectedVC isMemberOfClass:[FrontNearClothesViewController class]]) {
                
                [frontSearchClothesVC setSearchType:FRONT_SEARCH_TYPE_NEAR];
                [frontSearchClothesVC setSearchLocation:[(FrontNearClothesViewController *)selectedVC lastLocation]];
                
            }
            
            [[self navigationController] pushViewController:frontSearchClothesVC animated:YES];
        }
            break;
            
        case FrontSearchTypeStore:
        {
            FrontSearchStoresViewController *frontSearchStoresVC = [[FrontSearchStoresViewController alloc] initWithNibName:nil bundle:nil];
            
            [frontSearchStoresVC setMyStoryboard:[self storyboard]];
            [frontSearchStoresVC setSearchString:searchString];
            [[frontSearchStoresVC navigationItem] setTitle:searchString];
            
            [[self navigationController] pushViewController:frontSearchStoresVC animated:YES];
        }
            break;
            
        case FrontSearchTypePerson:
        {
            FrontSearchUsersViewController *frontSearchUsersVC = [[FrontSearchUsersViewController alloc] initWithNibName:nil bundle:nil];
            
            [frontSearchUsersVC setMyStoryboard:[self storyboard]];
            [frontSearchUsersVC setSearchString:searchString];
            [[frontSearchUsersVC navigationItem] setTitle:searchString];
            
            [[self navigationController] pushViewController:frontSearchUsersVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

@end
