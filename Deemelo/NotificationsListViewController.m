//
//  NotificationsListViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 9/5/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "NotificationsListViewController.h"

#import "APIProvider.h"
#import "NotificationTableViewCell.h"
#import "Notification.h"
#import "ItemDetailViewController.h"
#import "ProfileViewController.h"

@implementation NotificationsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
        [self setCurrentUserEmail:[[sharedApp currentUser] email]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    
//    [SVProgressHUD dismiss];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // necesario para que no se creen celdas vacías
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    [[self tableView] setTableFooterView:footer];
    
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"NotificationTableViewCell" bundle:nil];
    
    // Register this NIB which contains the cell
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"NotificationTableViewCell"];
    
    // corregir colores de los uibarbuttonitems
    [[[self navigationController] navigationBar] setTintColor:[UIColor colorWithRed:(236/255.0)
                                                                              green:(100/255.0)
                                                                               blue:(114/255.0)
                                                                              alpha:1]];
    
    // agregar el botón "cerrar" al navbar
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cerrar"
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(closeButtonTapped:)];
    
    [closeButtonItem setTintColor:[UIColor colorWithRed:(236/255.0)
                                                  green:(100/255.0)
                                                   blue:(114/255.0)
                                                  alpha:1]];
    
    [[self navigationItem] setLeftBarButtonItem:closeButtonItem];
    
    // agregar control para pull to refresh del collectionview
    [self setPullToRefreshView:[[SSPullToRefreshView alloc] initWithScrollView:[self tableView] delegate:self]];
    
    // agregar infinite scrolling
    [[self tableView] addInfiniteScrollingWithActionHandler:^{
        
        //NSLog(@"INFINITE SCROLL JUST TRIGGERED!!!!!!!!!!!!");
        // agregar más elementos a la colección
        
        // definir cuántos elementos tiene ahora la colección
        NSUInteger currentCollectionCount = [[self collection] count];
        
        // cargar nuevos elementos desde este offset y agregarlos a la colección
        [self loadMoreCollectionItemsFromOffset:[NSNumber numberWithInt:currentCollectionCount]];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationItem] setTitle:@"Notificaciones"];
    
    // limpiar celda previamente seleccionada del tableview
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // ejecutar el método requerido por el protocolo para cargar la colección
    [self loadCollection];
}

- (void)closeButtonTapped:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES
                                                        completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self collection] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationTableViewCell"];
    
    // Setear el selected view con los colores corporativos
    UIView *selectedView = [[UIView alloc] init];
    [selectedView setBackgroundColor:[UIColor colorWithRed:(236/255.0)
                                                     green:(100/255.0)
                                                      blue:(114/255.0)
                                                     alpha:1]];
    [cell setSelectedBackgroundView:selectedView];
    
    // Obtengo una referencia a la notificación que se va a mostrar en la cell
    Notification *notification = [[self collection] objectAtIndex:[indexPath row]];
    
    // mostrar imagen
    [[cell avatarImageView] setImageWithURL:[NSURL URLWithString:[notification callerThumbnailURL]]];
    
    // mostrar nombre
    [[cell nameLabel] setText:[notification callerName]];
    
    // mostrar texto
    switch ([notification type]) {
        case 11:
            // Juanito quiere tu prenda -> prenda
            [[cell descriptionLabel] setText:@"quiere tu prenda"];
            break;
            
        case 12:
            // Juanito comentó tu prenda -> prenda
            [[cell descriptionLabel] setText:@"comentó tu prenda"];
            break;
            
        case 21:
            // Juanito te sigue -> perfil
            [[cell descriptionLabel] setText:@"te sigue"];
            break;
            
        case 22:
            // Juanito ahora está en Deemelo -> perfil
            [[cell descriptionLabel] setText:@"ahora está en Deemelo"];
            break;
            
        default:
            break;
    }
    
    // pintar la celda de acuerdo a si está leída la notificación
    if ([notification read] == 0) {
        [[cell cellContainerView] setBackgroundColor:[UIColor colorWithRed:(247/255.0)
                                                                     green:(245/255.0)
                                                                      blue:(240/255.0)
                                                                     alpha:1]];
    } else {
        [[cell cellContainerView] setBackgroundColor:[UIColor colorWithRed:(230/255.0)
                                                                     green:(226/255.0)
                                                                      blue:(215/255.0)
                                                                     alpha:1]];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Obtengo una referencia a la notificación
    Notification *notification = [[self collection] objectAtIndex:[indexPath row]];
    
    id targetVC;
    
    switch ([notification type]) {
        case 11:
        {
            // Juanito quiere tu prenda -> prenda
            
            AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
            
            // Almaceno en el AppDelegate una referencia a la prenda clickeada
            ImageDetail *prenda = [[ImageDetail alloc] init];
            [prenda setIdImage:[notification targetId]];
            sharedApp.objectDetail = prenda;
            
            // Cargo una referencia a la vista del Storyboard que muestra los datos de una prenda
            targetVC = [[ItemDetailViewController alloc] initWithNibName:nil bundle:nil];
            [(ItemDetailViewController *)targetVC setMyStoryboard:[self myStoryboard]];
            
            // Configuro la referencia a este VC (se usa para volver automáticamente cuando el usuario borra un producto)
            [(ItemDetailViewController *)targetVC setBackViewController:self];
        }
            break;
            
        case 12:
        {
            // Juanito comentó tu prenda -> prenda
            
            AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
            
            // Almaceno en el AppDelegate una referencia a la prenda clickeada
            ImageDetail *prenda = [[ImageDetail alloc] init];
            [prenda setIdImage:[notification targetId]];
            sharedApp.objectDetail = prenda;
            
            // Cargo una referencia a la vista del Storyboard que muestra los datos de una prenda
            targetVC = [[ItemDetailViewController alloc] initWithNibName:nil bundle:nil];
            [(ItemDetailViewController *)targetVC setMyStoryboard:[self myStoryboard]];
            
            // Configuro la referencia a este VC (se usa para volver automáticamente cuando el usuario borra un producto)
            [(ItemDetailViewController *)targetVC setBackViewController:self];
        }
            break;
            
        case 21:
            // Juanito te sigue -> perfil
            
            // Cargo una referencia a la vista del Storyborad que muestra un perfil de usuario
            targetVC = [[self myStoryboard] instantiateViewControllerWithIdentifier:@"profileViewController"];
            
            // A la vista del perfil le indico que email debe utilizar para cargarse
            [(ProfileViewController *)targetVC setCurrentEmail:[notification callerEmail]];
            
            break;
            
        case 22:
            // Juanito ahora está en Deemelo -> perfil
            
            // Cargo una referencia a la vista del Storyborad que muestra un perfil de usuario
            targetVC = [[self myStoryboard] instantiateViewControllerWithIdentifier:@"profileViewController"];
            
            // A la vista del perfil le indico que email debe utilizar para cargarse
            [(ProfileViewController *)targetVC setCurrentEmail:[notification callerEmail]];
            
            break;
            
        default:
            break;
    }
    
    // Muestro el vc
    [[self navigationController] pushViewController:targetVC animated:YES];
    
    if ([notification read] == 0) {
        // si la notificación no ha sido leída, entonces la marco
        
        [APIProvider markReadNotificationWithId:[notification notificationId]
                                 withCompletion:^(BOOL successfully) {
                                     
                                     if (successfully) {
                                         
                                         //NSLog(@"marcó leída la notificación");
                                         [notification setRead:1];
                                         
                                         // recargar tableview para corregir los colores
                                         [[self tableView] reloadData];
                                         
                                     } else {
                                         
                                         //NSLog(@"error al marcar la notificación");
                                         
                                     }
                                     
                                 }
                                      withError:^{
                                          
                                          //NSLog(@"error al marcar la notificación");
                                          
                                      }];
    }
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
    [self refreshCollection];
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
        
        // cargar las notificaciones
        [APIProvider getNotificationsFromUserEmail:[self currentUserEmail]
                                            offset:0
                                       withSuccess:^(NSMutableArray *collection) {
                                           [self setCollection:collection];
                                           
                                           [[self tableView] reloadData];
                                           
                                           //NSLog(@"Cargó las notificaciones");
                                           
                                           [SVProgressHUD dismiss];
                                       }
                                           failure:^{
                                               //NSLog(@"Error al cargar las notificaciones");
                                               
                                               [SVProgressHUD dismiss];
                                           }];
    }
}

- (void)refreshCollection
{
    [self setCollection:nil];
    
    // mostrar el indicador de cargando
    [[self pullToRefreshView] startLoading];
    
    // cargar las notificaciones
    [APIProvider getNotificationsFromUserEmail:[self currentUserEmail]
                                        offset:0
                                   withSuccess:^(NSMutableArray *collection) {
                                       [self setCollection:collection];
                                       
                                       [[self tableView] reloadData];
                                       
                                       //NSLog(@"Cargó las notificaciones");
                                       
                                       [[self pullToRefreshView] finishLoading];
                                       [[[self tableView] infiniteScrollingView] stopAnimating];
                                   }
                                       failure:^{
                                           //NSLog(@"Error al cargar las notificaciones");
                                           
                                           [[self pullToRefreshView] finishLoading];
                                           [[[self tableView] infiniteScrollingView] stopAnimating];
                                       }];
}

- (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset
{
    if ([self collection]) {
        // cargar más notificaciones
        [APIProvider getNotificationsFromUserEmail:[self currentUserEmail]
                                            offset:[offset intValue]
                                       withSuccess:^(NSMutableArray *collection) {
                                           [[self collection] addObjectsFromArray:collection];
                                           
                                           [[self tableView] reloadData];
                                           
                                           //NSLog(@"Cargó las notificaciones");
                                           
                                           [[self pullToRefreshView] finishLoading];
                                           [[[self tableView] infiniteScrollingView] stopAnimating];
                                       }
                                           failure:^{
                                               //NSLog(@"Error al cargar las notificaciones");
                                               
                                               [[self pullToRefreshView] finishLoading];
                                               [[[self tableView] infiniteScrollingView] stopAnimating];
                                           }];
    }
}

@end
