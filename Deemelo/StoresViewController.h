//
//  StoresViewController.h
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBarButtonItems.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "StoreTableViewCell.h"
#import "Store.h"
#import "StoreMapPoint.h"
#import <QuartzCore/QuartzCore.h>
#import <SSPullToRefresh/SSPullToRefresh.h>
#import "StoreProfileViewController.h"
#import "UIViewController+KNSemiModal.h"

@interface StoresViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, SSPullToRefreshViewDelegate>
{
    MKAnnotationView *draggableAnnotationView;
    
    CLLocationManager *locationManager;
    CLLocation *lastLocation;
    NSString *lastAddress;
    NSString *lastCity;
    NSString *lastProvince;
    NSString *lastRegion;
    NSString *lastCountry;
    
    // ivars para restaurar la ui entre seleccionar tienda y crear tienda
    BOOL isAddingNewStore;
    UIBarButtonItem *lastLeftBarButtonItem;
    UIBarButtonItem *lastRightBarButtonItem;
    CGPoint originalSearchFilterBarCenter;
    CGRect originalMapViewFrame;
    CGPoint originalTableCenter;
    CGPoint originalShadowBarCenter;
    CGPoint originalAddingStoreInputViewCenter;
}

@property (nonatomic, strong) NSMutableArray *tiendas; // arreglo de tiendas

@property (nonatomic, assign) Boolean isFiltered; // indica si estamos filtrando de acuerdo al string en el searchbar
@property (nonatomic, strong) NSMutableArray *filtroTiendas; // arreglo de tiendas filtradas

@property (nonatomic, weak) IBOutlet UISearchBar *searchFilterBar;
@property (nonatomic, weak) IBOutlet UITableView *table;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIImageView *shadowBar;

@property (weak, nonatomic) IBOutlet UIView *addingStoreInputView;
@property (weak, nonatomic) IBOutlet UITextField *addingStoreNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *addingStoreAddressTextField;

@property (nonatomic, copy) NSDate *lastLocationUpdate;

@property (nonatomic, copy) NSString *currentCity;

- (void)backFromNewProductStoreSelection:(id)sender;
- (NSMutableArray *)sortStoreArray:(NSMutableArray *)stores
                        byLocation:(CLLocation *)currentLocation;
- (void)presentAddStoreUI:(id)sender;
- (void)dismissAddStoreUI:(id)sender;
- (void)saveNewStore:(id)sender;
- (void)reloadMapAnnotations;

@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;

// animaciones
- (void)bounceView:(UIView *)view;
- (void)growView:(UIView *)view;
- (void)shrinkView:(UIView *)view;

@end
