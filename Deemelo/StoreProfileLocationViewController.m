//
//  StoreProfileLocationViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 6/19/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "StoreProfileLocationViewController.h"

@implementation StoreProfileLocationViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:nil image:nil tag:300]];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"ubicacionActive.png"]];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[self selectedStore] latitude] && [[self selectedStore] longitude]) {
        [self setupMapAnnotation];
    } else {
        // cargar detalle de la tienda
        //[SVProgressHUD show];
        [APIProvider getStoreDetailFromStoreID:[[self selectedStore] storeID]
                                   withSuccess:^(Store *store) {
                                       
                                       [[self selectedStore] setLatitude:[store latitude]];
                                       [[self selectedStore] setLongitude:[store longitude]];
                                       
                                       [self setupMapAnnotation];
                                       
                                       //NSLog(@"Cargó el detalle de la tienda");
                                       
                                       //[SVProgressHUD dismiss];
                                   }
                                       failure:^{
                                           //NSLog(@"Error al cargar el detalle de la tienda");
                                           
                                           //[SVProgressHUD dismiss];
                                       }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMapAnnotation
{
    // limpiar mapa
    [[self mapView] removeAnnotations:[[self mapView] annotations]];
    
    // agregar pin flotante
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([[[self selectedStore] latitude] doubleValue],
                                                            [[[self selectedStore] longitude] doubleValue]);
    StoreMapPoint *newStoreMapPoint = [[StoreMapPoint alloc] initWithCoordinate:loc
                                                                          title:[[self selectedStore] name]];
    [[self mapView] addAnnotation:newStoreMapPoint];
    
    // hacer zoom del mapa usando un rect de 1000 (m) x 1000 (m)
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 1000, 1000);
    [[self mapView] setRegion:region animated:YES];
}

# pragma mark - MKMapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *normalAnnotationViewID = @"normalAnnotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:normalAnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:normalAnnotationViewID];
    }
    
    [annotationView setImage:[UIImage imageNamed:@"marker.png"]];
    [annotationView setAnnotation:annotation];
    [annotationView setCanShowCallout:YES];
    [annotationView setDraggable:NO];
    
    return annotationView;
}

@end
