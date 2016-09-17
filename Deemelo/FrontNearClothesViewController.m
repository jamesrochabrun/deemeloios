//
//  FrontNearClothesViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 9/13/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "FrontNearClothesViewController.h"

@implementation FrontNearClothesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[self tabBarItem] setTitle:@"Cercanas"];
        
        // crear el location manager nativo
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    // Tell the location manager to stop sending us messages
    [locationManager setDelegate:nil];
}

#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations objectAtIndex:0];
    
    // si esta actualización es desde hace más de 2 minutos, ignórela
    NSTimeInterval t = [[currentLocation timestamp] timeIntervalSinceNow];
    if (t < -120) {
        // esta es data cacheada
        //NSLog(@"UBICACIÓN DESCARTADA: DATA CACHEADA");
        return;
    }
    
    // si la actualización anterior es desde hace menos de 6 segundos, salir de acá
    NSTimeInterval l = [[currentLocation timestamp] timeIntervalSinceDate:[self lastLocationUpdate]];
    if (l < 6) {
        // esta es data repetida por estar muy cerca de la anterior
        //NSLog(@"UBICACIÓN DESCARTADA: DATA REPETIDA");
        return;
    }
    
    // configurar el location manager para que deje de enviar la ubicación del usuario
    [locationManager stopUpdatingLocation];
    
    //NSLog(@"RECIBIÓ NUEVA UBICACIÓN: %@", currentLocation);
    [self setLastLocationUpdate:[currentLocation timestamp]];
    
    [self setLastLocation:currentLocation];
    
    // cargar las fotos de la portada
    [APIProvider getNearClothesFromLatitude:[[self lastLocation] coordinate].latitude
                               andLongitude:[[self lastLocation] coordinate].longitude
                                     offset:0
                                withSuccess:^(NSMutableArray *collection) {
                                    [self setCollection:collection];
                                    
                                    [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                    
                                    //NSLog(@"Cargó las prendas cercanas");
                                    
                                    [SVProgressHUD dismiss];
                                    [[self pullToRefreshView] finishLoading];
                                    [[[self collectionView] infiniteScrollingView] stopAnimating];
                                }
                                withFailure:^{
                                    //NSLog(@"Error al cargar las prendas cercanas");
                                    
                                    [SVProgressHUD dismiss];
                                    [[self pullToRefreshView] finishLoading];
                                    [[[self collectionView] infiniteScrollingView] stopAnimating];
                                }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"No pudo actualizar la ubicación: %@", error);
}

#pragma mark - PictureCollectionViewControllerDatasource

- (void)loadCollection
{
    if (![self collection] || ([[self collection] count] == 0)) {
        // mostrar el indicador de cargando
        [SVProgressHUD show];
        
        [locationManager stopUpdatingLocation];
        [locationManager startUpdatingLocation];
    }
}

- (void)refreshCollection
{
    [self setCollection:nil];
    
    // mostrar el indicador de cargando
    [[self pullToRefreshView] startLoading];
    
    [locationManager stopUpdatingLocation];
    [locationManager startUpdatingLocation];
}

- (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset
{
    if ([self lastLocation] && [self collection]) {
        // cargar más fotos de la portada
        [APIProvider getNearClothesFromLatitude:[[self lastLocation] coordinate].latitude
                                   andLongitude:[[self lastLocation] coordinate].longitude
                                         offset:[offset intValue]
                                    withSuccess:^(NSMutableArray *collection) {
                                        [[self collection] addObjectsFromArray:collection];
                                        
                                        [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                        
                                        //NSLog(@"Cargó las prendas cercanas");
                                        
                                        [[self pullToRefreshView] finishLoading];
                                        [[[self collectionView] infiniteScrollingView] stopAnimating];
                                    }
                                    withFailure:^{
                                        //NSLog(@"Error al cargar las prendas cercanas");
                                        
                                        [[self pullToRefreshView] finishLoading];
                                        [[[self collectionView] infiniteScrollingView] stopAnimating];
                                    }];
    }
}

@end
