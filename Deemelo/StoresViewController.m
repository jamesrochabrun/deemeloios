//
//  StoresViewController.m
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "StoresViewController.h"

@implementation StoresViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tiendas" image:nil tag:3];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tiendas_activo.png"]
                      withFinishedUnselectedImage:[UIImage imageNamed:@"tiendas"]];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, 0, 0);
        self.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
        
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
    
    isAddingNewStore = NO;
    
    // necesario para que no se creen celdas vacías
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    [[self table] setTableFooterView:footer];
    
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"StoreTableViewCell" bundle:nil];
    
    // Register this NIB which contains the cell
    [[self table] registerNib:nib forCellReuseIdentifier:@"StoreTableViewCell"];
    
    [[self searchFilterBar] setDelegate:self];

    self.navigationItem.titleView = [CustomBarButtonItems titleView:self.navigationController.navigationBar view:self.view];
    //self.navigationItem.rightBarButtonItem = [CustomBarButtonItems rightBarButtonWithImageName:@"lupa.png"];
    
    // corregir colores de los uibarbuttonitems
    [[[self navigationController] navigationBar] setTintColor:[UIColor colorWithRed:(236/255.0)
                                                                              green:(100/255.0)
                                                                               blue:(114/255.0)
                                                                              alpha:1]];
    
    // agregar control para pull to refresh del tableview
    [self setPullToRefreshView:[[SSPullToRefreshView alloc] initWithScrollView:[self table] delegate:self]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // limpiar celda previamente seleccionada del tableview
    [[self table] deselectRowAtIndexPath:[[self table] indexPathForSelectedRow] animated:animated];
    
    if ([[self tiendas] count] == 0) {
        // configurar el location manager para que comience a enviar la ubicación del usuario
        [locationManager startUpdatingLocation];
        //[[self mapView] setShowsUserLocation:YES];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate isAddingNewProduct]) {
        // si estamos en el flujo para agregar nuevo producto
        
        // agregar el botón "volver" al navbar
        UIImage *backImage = [UIImage imageNamed:@"back.png"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setBounds:CGRectMake( 0, 0, [backImage size].width, [backImage size].height)];
        [backButton setImage:backImage
                    forState:UIControlStateNormal];
        
        [backButton addTarget:self
                       action:@selector(backFromNewProductStoreSelection:)
             forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        [[self navigationItem] setLeftBarButtonItem:backButtonItem];
        
        // agregar botón para crear nueva tienda
        UIBarButtonItem *addStoreButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newStore.png"]
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(presentAddStoreUI:)];
        
        [addStoreButtonItem setTintColor:[UIColor colorWithRed:(236/255.0)
                                                         green:(100/255.0)
                                                          blue:(114/255.0)
                                                         alpha:1]];
        
        [addStoreButtonItem setEnabled:NO];
        
        [[self navigationItem] setRightBarButtonItem:addStoreButtonItem];
    } else {
        [[self navigationItem] setLeftBarButtonItem:nil];
        [[self navigationItem] setRightBarButtonItem:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Localización no disponible"
                                                     message:@"Para determinar tu ubicación, habilita el servicio de localización en  \"Ajustes\" de tu iPhone."
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil];
        [av show];
    }
    
    originalAddingStoreInputViewCenter = [[self addingStoreInputView] center];
    
    [[self addingStoreInputView] setCenter:CGPointMake([[self addingStoreInputView] center].x,
                                                       [[self addingStoreInputView] center].y
                                                       - [[self addingStoreInputView] bounds].size.height)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // configurar el location manager para que deje de enviar la ubicación del usuario
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

- (NSMutableArray *)sortStoreArray:(NSMutableArray *)stores
                        byLocation:(CLLocation *)currentLocation
{
    NSArray *sortedArray = [stores sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        // distancia entre posición actual y obj1
        CLLocation *obj1location = [[CLLocation alloc] initWithLatitude:[[(Store *)obj1 latitude] doubleValue]
                                                              longitude:[[(Store *)obj1 longitude] doubleValue]];
        
        double distFromCurrLocToObj1 = [currentLocation distanceFromLocation:obj1location];
        
        // distancia entre posición actual y obj2
        CLLocation *obj2location = [[CLLocation alloc] initWithLatitude:[[(Store *)obj2 latitude] doubleValue]
                                                              longitude:[[(Store *)obj2 longitude] doubleValue]];
        
        double distFromCurrLocToObj2 = [currentLocation distanceFromLocation:obj2location];
        
        if (distFromCurrLocToObj1 < distFromCurrLocToObj2) {
            return NSOrderedAscending;
        } else if (distFromCurrLocToObj1 > distFromCurrLocToObj2) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    return [NSMutableArray arrayWithArray:sortedArray];
}

- (void)reloadMapAnnotations
{
    [[self mapView] removeAnnotations:[[self mapView] annotations]];
    
    NSArray *tiendasTemp;
    if ([self isFiltered])
        tiendasTemp = [self filtroTiendas];
    else
        tiendasTemp = [self tiendas];
    
    for (Store *st in tiendasTemp) {
        
        CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake([[st latitude] doubleValue], [[st longitude] doubleValue]);
        
        StoreMapPoint *mp = [[StoreMapPoint alloc] initWithCoordinate:coordinate
                                                                title:[st name]];
        
        [[self mapView] addAnnotation:mp];
    }
}

#pragma mark - UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowCount;
    if ([self isFiltered]) {
        rowCount = [[self filtroTiendas] count];
    }
    else {
        rowCount = [[self tiendas] count];
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // obtener la instancia de la tienda correspondiente a ESTA celda
    Store *st;
    if ([self isFiltered])
        st = ((Store *)[[self filtroTiendas] objectAtIndex:[indexPath row]]);
    else
        st = ((Store *)[[self tiendas] objectAtIndex:[indexPath row]]);
    
    StoreTableViewCell *cell = [[self table] dequeueReusableCellWithIdentifier:@"StoreTableViewCell"];
    
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
    NSString *address;
    if (![st address] || [[st address] isEqualToString:@"undefined"] || [[st address] isEqualToString:@"(null)"]) {
        address = @"";
    } else {
        address = [NSString stringWithFormat:@"%@", [st address]];
    }
    [[cell storeAddressLabel] setText:address];
    
    return cell;
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // apunto en el appdelegate a la instancia de store seleccionada
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Store *st;
    if ([self isFiltered])
        st = ((Store *)[[self filtroTiendas] objectAtIndex:[indexPath row]]);
    else
        st = ((Store *)[[self tiendas] objectAtIndex:[indexPath row]]);
    
    [appDelegate setStoreSelected:st];
    
    // escondo el teclado si es que está siendo mostrado
    [[self searchFilterBar] resignFirstResponder];
    
    if (![appDelegate isAddingNewProduct]) {
        
        // Si no estoy agregando un nuevo producto (entonces estoy consultando el bar button de tiendas "TIENDAS")
        
        // hacer zoom del mapa usando un rect de 1000 (m) x 1000 (m)
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([[[appDelegate storeSelected] latitude] doubleValue],
                                                                [[[appDelegate storeSelected] longitude] doubleValue]);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 1000, 1000);
        [[self mapView] setRegion:region animated:YES];
        
        // mostrar el perfil de la tienda
        StoreProfileViewController *storeProfileVC =
            [[self storyboard] instantiateViewControllerWithIdentifier:@"storeProfile"];
        
        [storeProfileVC setSelectedStore:[appDelegate storeSelected]];
        
        [[self navigationController] pushViewController:storeProfileVC animated:YES];
        
    } else {
        // Si estoy agregando un nuevo producto (entonces estoy dentro del flujo del bar button de la cámara)
        
        // agregar la tienda al producto
        [[appDelegate aNewProduct] setStoreName:[[appDelegate storeSelected] name]];
        
        [SVProgressHUD showWithStatus:@"Subiendo la imagen..."];
        
        // subir el nuevo producto
        [APIProvider createProduct:[appDelegate aNewProduct]];
        
        //[SVProgressHUD dismiss];//el dismiss lo hace el callback block que va en createProduct:
        
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
            // ir al perfil del usuario
            [[appDelegate tabController] setSelectedIndex:4];
            // eliminar referencia en el appdelegate respecto al nuevo producto que estábamos creando
            [appDelegate setIsAddingNewProduct:NO];
            [appDelegate setANewProduct:nil];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

#pragma mark - SSPullToRefreshView Delegate Methods (+ refreshStores)

- (BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView *)view
{
    return YES;
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self refreshStores];
    //NSLog(@"StartLoading");
}

- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view
{
    //NSLog(@"FinishLoading");
}

- (void)refreshStores
{
    [[self pullToRefreshView] startLoading];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ((![appDelegate isAddingNewProduct]) && ([self isFiltered])) {
        
        // si no está en el flujo de agregar nuevo producto y hay una búsqueda desplegada, volver a buscar
        [SVProgressHUD showWithStatus:@"Buscando tiendas..."];
        
        [APIProvider getStoresWithCategoryName:[[self searchFilterBar] text]
                                  fromLatitude:[lastLocation coordinate].latitude
                                  andLongitude:[lastLocation coordinate].longitude
                                   withSuccess:^(NSMutableArray *collection) {
                                       
                                       [self setIsFiltered:TRUE];
                                       [self setFiltroTiendas:collection];
                                       
                                       // re cargar los pines en el mapa
                                       [self reloadMapAnnotations];
                                       
                                       // re cargar el tableview
                                       [[self table] reloadData];
                                       
//                                       // zoom en los resultados
//                                       [self zoomToFitMapAnnotations];
                                       
                                       //NSLog(@"Cargó las tiendas de la búsqueda");
                                       
                                       [SVProgressHUD dismiss];
                                       
                                   }
                                       failure:^{
                                           
                                           //NSLog(@"Error al cargar las tiendas de la búsqueda");
                                           
                                           [SVProgressHUD showErrorWithStatus:@"No encontramos esta prenda"];
                                           
                                       }];
        
    } else {
        
        // configurar el location manager para que comience a enviar la ubicación del usuario
        [locationManager startUpdatingLocation];
        
    }
    
    [[self pullToRefreshView] finishLoading];
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBar:(UISearchBar*)searchBar
    textDidChange:(NSString*)text
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isAddingNewProduct]) {
        
        // si está en el flujo de agregar nuevo producto, filtrar la tabla a medida que el usuario va escribiendo
        if (text.length == 0) {
            [self setIsFiltered:FALSE];
        } else {
            [self setIsFiltered:TRUE];
            [self setFiltroTiendas:[[NSMutableArray alloc] init]];
            
            for (Store *st in [self tiendas]) {
                NSRange nameRange = [st.name rangeOfString:text options:NSCaseInsensitiveSearch];
                if(nameRange.location != NSNotFound) {
                    [[self filtroTiendas] addObject:st];
                }
            }
        }
        
        // re cargar los pines en el mapa
        [self reloadMapAnnotations];
        
        // re cargar el tableview
        [[self table] reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isAddingNewProduct]) {
        
        // si está en el flujo de agregar nuevo producto, recargar la tabla
        [[self table] reloadData];
        
    } else {
        
        // sino, buscar por tipo de prenda
        [searchBar resignFirstResponder];
        
        [SVProgressHUD showWithStatus:@"Buscando tiendas..."];
        
        [APIProvider getStoresWithCategoryName:[searchBar text]
                                  fromLatitude:[lastLocation coordinate].latitude
                                  andLongitude:[lastLocation coordinate].longitude
                                   withSuccess:^(NSMutableArray *collection) {
                                       
                                       [self setIsFiltered:TRUE];
                                       [self setFiltroTiendas:collection];
                                       
                                       // re cargar los pines en el mapa
                                       [self reloadMapAnnotations];
                                       
                                       // re cargar el tableview
                                       [[self table] reloadData];
                                       
//                                       // zoom en los resultados
//                                       [self zoomToFitMapAnnotations];
                                       
                                       //NSLog(@"Cargó las tiendas de la búsqueda");
                                       
                                       [SVProgressHUD dismiss];
                                       
                                   }
                                       failure:^{
                                           
                                           //NSLog(@"Error al cargar las tiendas de la búsqueda");
                                           
                                           [SVProgressHUD showErrorWithStatus:@"No encontramos esta prenda"];
                                           
                                       }];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar setText:@""];
    [self searchBar:searchBar textDidChange:[searchBar text]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![appDelegate isAddingNewProduct]) {
        
        // si no está en el flujo de agregar nuevo producto, traer todas las tiendas
        
        [self setIsFiltered:FALSE];
        
        // re cargar los pines en el mapa
        [self reloadMapAnnotations];
        
        // re cargar el tableview
        [[self table] reloadData];
        
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [SVProgressHUD showWithStatus:@"Cargando tiendas..."];
    
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
    
    lastLocation = currentLocation;
    
    // hacer zoom del mapa usando un rect de 1000 (m) x 1000 (m)
    CLLocationCoordinate2D loc = [currentLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 1000, 1000);
    [[self mapView] setRegion:region animated:YES];
    
    //NSLog(@"currentlocation lg: %f", [currentLocation coordinate].longitude);
    //NSLog(@"currentlocation lt: %f", [currentLocation coordinate].latitude);
    
    // consultar la ciudad actual a partir de la ubicación actual
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if ([placemarks count] != 0) {
                           [self setCurrentCity:[[placemarks objectAtIndex:0] administrativeArea]];
                           
                           //NSLog(@"CIUDAD RECIBIDA: %@", [self currentCity]);
                           
                           if ([[self currentCity] isEqualToString:@"Metropolitana de Santiago"]) {
                               [self setCurrentCity:@"Santiago"];
                           }
                           
                           //NSLog(@"CIUDAD PARA PREGUNTAR: %@", [self currentCity]);
                           
                           // guardar para usar en caso que se cree una nueva tienda
                           lastAddress = [NSString stringWithFormat:@"%@ %@", [[placemarks objectAtIndex:0] thoroughfare],
                                                                              [[placemarks objectAtIndex:0] subThoroughfare]];
                           lastCity = [self currentCity];
                           lastProvince = [self currentCity];
                           lastRegion = [[placemarks objectAtIndex:0] administrativeArea];
                           lastCountry = [[placemarks objectAtIndex:0] country];
                           
                           // traer listado de tiendas de la ciudad actual
                           [APIProvider getStoresFromLatitude:[currentLocation coordinate].longitude
                                                 andLongitude:[currentLocation coordinate].latitude
                                                  withSuccess:^(NSMutableArray *collection) {
                                                      // ordenar tiendas por ubicación
                                                      [self setTiendas:[self sortStoreArray:collection byLocation:currentLocation]];
                                                      
                                                      // recargar el tableview una vez que llega el listado de tiendas
                                                      [[self table] reloadData];
                                                      
                                                      // agregar pines al mapa con las tiendas
                                                      [self reloadMapAnnotations];
                                                      
                                                      [SVProgressHUD dismiss];
                                                      [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
                                                  } withFailure:^{
                                                      [SVProgressHUD showErrorWithStatus:CONNECTION_ERROR_TEXT_STRING];
                                                  }];
                       } else {
                           // si no recibió reverseGeocodeLocation
                           // configurar el location manager
                           // para que comience el ciclo nuevamente
                           [locationManager startUpdatingLocation];
                       }
                   }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"No pudo actualizar la ubicación: %@", error);
}

#pragma mark - MKMapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString *annotationViewID;
    
    static NSString *normalAnnotationViewID = @"normalAnnotationViewID";
    static NSString *draggableAnnotationViewID = @"draggableAnnotationViewID";
    
    if (isAddingNewStore) {
        annotationViewID = draggableAnnotationViewID;
    } else {
        annotationViewID = normalAnnotationViewID;
    }
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:annotationViewID];
    }
    
    [annotationView setImage:[UIImage imageNamed:@"marker.png"]];
    [annotationView setAnnotation:annotation];
    [annotationView setCanShowCallout:YES];
    [annotationView setDraggable:NO];
    
    if (isAddingNewStore) {
        [annotationView setImage:[UIImage imageNamed:@"marker_dragging_state.png"]];
        [annotationView setCanShowCallout:NO];
        [annotationView setDraggable:YES];
        draggableAnnotationView = annotationView;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (isAddingNewStore) {
        return;
    }
    
    // seleccionar la tienda de la tabla correspondiente al pin seleccionado
    
    NSArray *tiendasTemp;
    if ([self isFiltered])
        tiendasTemp = [self filtroTiendas];
    else
        tiendasTemp = [self tiendas];
    
    if ([tiendasTemp count] == 0) {
        return;
    }
    
    NSUInteger pos;
    
    for (Store *st in tiendasTemp) {
        if ([[st name] isEqualToString:[[view annotation] title]]) {
            pos = [tiendasTemp indexOfObject:st];
        }
    }
    
    [[self table] selectRowAtIndexPath:[NSIndexPath indexPathForRow:pos
                                                          inSection:0]
                              animated:YES
                        scrollPosition:UITableViewScrollPositionTop];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateStarting) {
        [self growView:view];
    }
    if (newState == MKAnnotationViewDragStateEnding) {
        //NSLog(@"dropped at %f, %f", [[view annotation] coordinate].latitude, [[view annotation] coordinate].longitude);
        
        [self shrinkView:view];
        
        lastLocation = [[CLLocation alloc] initWithLatitude:[[view annotation] coordinate].latitude
                                                  longitude:[[view annotation] coordinate].longitude];
        
        // consultar nueva dirección
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:lastLocation
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           if ([placemarks count] != 0) {
                               NSString *newAddress = [NSString stringWithFormat:@"%@ %@", [[placemarks objectAtIndex:0] thoroughfare],
                                                       [[placemarks objectAtIndex:0] subThoroughfare]];
                               
                               //NSLog(@"DIRECCIÓN RECIBIDA: %@", newAddress);
                               
                               
                               // actualizar el textfield de la dirección
                               [[self addingStoreAddressTextField] setText:newAddress];
                           }
                       }];
        
    }
}

#pragma mark - MKMapView Awesome Methods

- (void)zoomToFitMapAnnotations
{
    if ([[[self mapView] annotations] count] == 0) return;
    
    int i = 0;
    MKMapPoint points[[[[self mapView] annotations] count]];
    
    //build array of annotation points
    for (id<MKAnnotation> annotation in [[self mapView] annotations]) {
        points[i++] = MKMapPointForCoordinate([annotation coordinate]);
    }
    
    MKPolygon *poly = [MKPolygon polygonWithPoints:points
                                             count:i];
    
    [[self mapView] setRegion:MKCoordinateRegionForMapRect([poly boundingMapRect])
                     animated:YES];
}

#pragma mark - métodos para usar en creación de nuevo producto

- (void)backFromNewProductStoreSelection:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)presentAddStoreUI:(id)sender
{
    isAddingNewStore = YES;
    [[self addingStoreNameTextField] setText:@""];
    [[self addingStoreAddressTextField] setText:lastAddress];
    
    // esconder el teclado
    [[self searchFilterBar] resignFirstResponder];
    
    // limpiar pines
    [[self mapView] removeAnnotations:[[self mapView] annotations]];
    
    // cambiar el LeftBarButtonItem anterior
    lastLeftBarButtonItem = [[self navigationItem] leftBarButtonItem];
    
    UIBarButtonItem *dismissAddStoreUIButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(dismissAddStoreUI:)];
    
    [dismissAddStoreUIButtonItem setTintColor:[UIColor colorWithRed:(236/255.0)
                                                              green:(100/255.0)
                                                               blue:(114/255.0)
                                                              alpha:1]];
    
    [[self navigationItem] setLeftBarButtonItem:dismissAddStoreUIButtonItem
                                       animated:YES];
    
    // cambiar el RightBarButtonItem anterior
    lastRightBarButtonItem = [[self navigationItem] rightBarButtonItem];
    
    UIBarButtonItem *saveNewStoreButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(saveNewStore:)];
    
    [saveNewStoreButtonItem setTintColor:[UIColor colorWithRed:(236/255.0)
                                                         green:(100/255.0)
                                                          blue:(114/255.0)
                                                         alpha:1]];
    
    [saveNewStoreButtonItem setEnabled:NO];
    
    [[self navigationItem] setRightBarButtonItem:saveNewStoreButtonItem
                                        animated:YES];
    
    // esconder el searchbar
    // agrandar el mapa
    // esconder la tabla
    // esconder la sombra
    originalSearchFilterBarCenter = [[self searchFilterBar] center];
    originalMapViewFrame = [[self mapView] frame];
    originalTableCenter = [[self table] center];
    originalShadowBarCenter = [[self shadowBar] center];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [[self searchFilterBar] setCenter:CGPointMake([[self searchFilterBar] center].x,
                                                                       [[self searchFilterBar] center].y
                                                                       - [[self searchFilterBar] bounds].size.height)];
                         
                         [[self mapView] setFrame:CGRectMake([[[self mapView] superview] bounds].origin.x,
                                                             [[[self mapView] superview] bounds].origin.y,
                                                             [[[self mapView] superview] bounds].size.width,
                                                             [[[self mapView] superview] bounds].size.height)];
                         
                         [[self table] setCenter:CGPointMake([[self table] center].x,
                                                             [[self table] center].y
                                                             + [[self table] bounds].size.height)];
                         
                         [[self shadowBar] setCenter:CGPointMake([[self shadowBar] center].x,
                                                                 [[self shadowBar] center].y
                                                                 + [[self table] bounds].size.height)];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [[self searchFilterBar] setHidden:YES];
                             [[self table] setHidden:YES];
                             [[self shadowBar] setHidden:YES];
                             
                             [[self addingStoreInputView] setHidden:NO];
                             
                             [UIView animateWithDuration:0.25
                                              animations:^{
                                                  [[self addingStoreInputView] setCenter:originalAddingStoreInputViewCenter];
                                              }
                                              completion:^(BOOL finished) {
                                                  // hacer zoom del mapa usando un rect de 1000 (m) x 1000 (m)
                                                  CLLocationCoordinate2D loc = [lastLocation coordinate];
                                                  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 1000, 1000);
                                                  [[self mapView] setRegion:region animated:YES];
                                                  
                                                  // agregar pin flotante
                                                  StoreMapPoint *newStoreMapPoint = [[StoreMapPoint alloc] initWithCoordinate:[lastLocation coordinate]
                                                                                                                        title:@"Nueva Tienda"];
                                                  [[self mapView] addAnnotation:newStoreMapPoint];
                                                  [self bounceView:draggableAnnotationView];
                                              }];
                         }
                     }];
}

- (void)dismissAddStoreUI:(id)sender
{
    isAddingNewStore = NO;
    
    // esconder el teclado
    [[self addingStoreNameTextField] resignFirstResponder];
    [[self addingStoreAddressTextField] resignFirstResponder];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [[self addingStoreInputView] setCenter:CGPointMake([[self addingStoreInputView] center].x,
                                                                            [[self addingStoreInputView] center].y
                                                                            - [[self addingStoreInputView] bounds].size.height)];
                         // esconder pin flotante
                         [[self mapView] removeAnnotations:[[self mapView] annotations]];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [[self addingStoreInputView] setHidden:YES];
                             
                             // restaurar el LeftBarButtonItem anterior
                             [[self navigationItem] setLeftBarButtonItem:lastLeftBarButtonItem
                                                                animated:YES];
                             
                             // restaurar el RightBarButtonItem anterior
                             [[self navigationItem] setRightBarButtonItem:lastRightBarButtonItem
                                                                 animated:YES];
                             
                             [[self searchFilterBar] setHidden:NO];
                             [[self table] setHidden:NO];
                             [[self shadowBar] setHidden:NO];
                             
                             // restaurar el searchbar
                             // restaurar el mapa
                             // restaurar la tabla
                             // restaurar la sombra
                             [UIView animateWithDuration:0.25
                                              animations:^{
                                                  [[self searchFilterBar] setCenter:originalSearchFilterBarCenter];
                                                  [[self mapView] setFrame:originalMapViewFrame];
                                                  [[self table] setCenter:originalTableCenter];
                                                  [[self shadowBar] setCenter:originalShadowBarCenter];
                                              }
                                              completion:^(BOOL finished) {
                                                  // restaurar pines
                                                  [self reloadMapAnnotations];
                                              }];
                         }
                     }];
}

- (void)saveNewStore:(id)sender
{
    if ([[[self addingStoreNameTextField] text] length] < 1) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"Ingrese un nombre para la tienda."
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil];
        [av show];
    } else {
        // esconder el teclado
        [[self addingStoreNameTextField] resignFirstResponder];
        [[self addingStoreAddressTextField] resignFirstResponder];
        
        // crear la tienda
        Store *newStore = [[Store alloc] init];
        [newStore setName:[[self addingStoreNameTextField] text]];
        [newStore setAddress:[[self addingStoreAddressTextField] text]];
        [newStore setLatitude:[NSString stringWithFormat:@"%f", [lastLocation coordinate].latitude]];
        [newStore setLongitude:[NSString stringWithFormat:@"%f", [lastLocation coordinate].longitude]];
        [newStore setCity:lastCity];
        [newStore setProvince:lastProvince];
        [newStore setRegion:lastRegion];
        [newStore setCountry:lastCountry];
        //NSLog(@"%@", newStore);
        
        [SVProgressHUD showWithStatus:@"Creando la tienda..."];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [APIProvider createStore:newStore
                     withSuccess:^{
                         [SVProgressHUD showSuccessWithStatus:@"Tienda creada!"];
                         
                         // si guardó tienda, entonces guardar producto
                         
                         // decirle al appdelegate que esta es la tienda seleccionada
                         [appDelegate setStoreSelected:newStore];
                         
                         // agregar la tienda al producto
                         [[appDelegate aNewProduct] setStoreName:[[appDelegate storeSelected] name]];
                         
                         [SVProgressHUD showWithStatus:@"Subiendo la imagen..."];
                         
                         // subir el nuevo producto
                         [APIProvider createProduct:[appDelegate aNewProduct]];
                         
                         //[SVProgressHUD dismiss];//el dismiss lo hace el callback block que va en createProduct:
                         
                         // eliminar referencia en el appdelegate respecto al nuevo producto que estábamos creando
                         [appDelegate setIsAddingNewProduct:NO];
                         [appDelegate setANewProduct:nil];
                     }
                         failure:^{
                             [SVProgressHUD showErrorWithStatus:@"Error creando la tienda"];
                             
                             // eliminar referencia en el appdelegate respecto al nuevo producto que estábamos creando
                             [appDelegate setIsAddingNewProduct:NO];
                             [appDelegate setANewProduct:nil];
                         }];
        
        isAddingNewStore = NO;
        
        // volver al menú principal
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
            // ir al perfil del usuario
            [[appDelegate tabController] setSelectedIndex:4];
        }];
    }
}

#pragma mark - Animation Methods

- (void)bounceView:(UIView *)view
{
    // Create a key frame animation
    CAKeyframeAnimation *bounce =
    [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    // Create the values it will pass through
    CATransform3D forward = CATransform3DMakeScale(1.3, 1.3, 1);
    CATransform3D back = CATransform3DMakeScale(0.7, 0.7, 1);
    CATransform3D forward2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D back2 = CATransform3DMakeScale(0.9, 0.9, 1);
    [bounce setValues:[NSArray arrayWithObjects:
                       [NSValue valueWithCATransform3D:CATransform3DIdentity],
                       [NSValue valueWithCATransform3D:forward],
                       [NSValue valueWithCATransform3D:back],
                       [NSValue valueWithCATransform3D:forward2],
                       [NSValue valueWithCATransform3D:back2],
                       [NSValue valueWithCATransform3D:CATransform3DIdentity],
                       nil]];
    
    // Set the duration
    [bounce setDuration:0.6];
    
    // Animate the layer
    [[view layer] addAnimation:bounce
                        forKey:@"bounceAnimation"];
}

- (void)growView:(UIView *)view
{
    // Create a key frame animation
    CAKeyframeAnimation *grow =
    [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    // Create the values it will pass through
    CATransform3D forward = CATransform3DMakeScale(1.8, 1.8, 1);
    CATransform3D back = CATransform3DMakeScale(1.1, 1.1, 1);
    CATransform3D forward2 = CATransform3DMakeScale(1.6, 1.6, 1);
    CATransform3D back2 = CATransform3DMakeScale(1.3, 1.3, 1);
    [grow setValues:[NSArray arrayWithObjects:
                     [NSValue valueWithCATransform3D:CATransform3DIdentity],
                     [NSValue valueWithCATransform3D:forward],
                     [NSValue valueWithCATransform3D:back],
                     [NSValue valueWithCATransform3D:forward2],
                     [NSValue valueWithCATransform3D:back2],
                     [NSValue valueWithCATransform3D:CATransform3DIdentity],
                     nil]];
    
    // Set the duration
    [grow setDuration:0.6];
    
    // Animate the layer
    [[view layer] addAnimation:grow
                        forKey:@"growAnimation"];
}

- (void)shrinkView:(UIView *)view
{
    // Create a key frame animation
    CAKeyframeAnimation *shrink =
    [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    // Create the values it will pass through
    CATransform3D forward = CATransform3DMakeScale(1.3, 1.3, 1);
    CATransform3D back = CATransform3DMakeScale(0.7, 0.7, 1);
    CATransform3D forward2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D back2 = CATransform3DMakeScale(0.9, 0.9, 1);
    [shrink setValues:[NSArray arrayWithObjects:
                       [NSValue valueWithCATransform3D:CATransform3DIdentity],
                       [NSValue valueWithCATransform3D:forward],
                       [NSValue valueWithCATransform3D:back],
                       [NSValue valueWithCATransform3D:forward2],
                       [NSValue valueWithCATransform3D:back2],
                       [NSValue valueWithCATransform3D:CATransform3DIdentity],
                       nil]];
    
    // Set the duration
    [shrink setDuration:0.6];
    
    // Animate the layer
    [[view layer] addAnimation:shrink
                        forKey:@"shrinkAnimation"];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == [self addingStoreNameTextField]) {
        if (([string isEqualToString:@""]) && ([[[self addingStoreNameTextField] text] length] == range.length)) {
            [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
        } else {
            [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
        }
    }
    
    return YES;
}

@end
