//
//  ProfilePicturesViewController.m
//  Deemelo
//
//  Created by Marcelo Espina on 19-06-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "ProfilePicturesViewController.h"

#import "MHTabBarController.h"

@implementation ProfilePicturesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil email:(NSString *)email storyboard:(UIStoryboard *)storyboard picturesCount:(NSString *)picturesCount
{
    self = [super initWithNibName:nil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setEmail:email];
        [self setMyStoryboard:storyboard];
        [self setPicturesCount:picturesCount];

        [[self tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [self picturesCount], PROFILE_TAB_TITLE_TYPE_PROFILEPICTURES]];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ( [[[appDelegate currentUser] email] isEqualToString:[self email]] ) {
            // Me adiero al NotificationCenter para saber cuando borré una foto
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(updatePicturesCount:)
                       name:AddedPictureNotification
                     object:nil];
            
            [nc addObserver:self
                   selector:@selector(updatePicturesCount:)
                       name:DeletedPictureNotification
                     object:nil];
        }
    }
    return self;
}

// Al borrar una foto se actualizará el contador de fotos del usuario logeado
- (void)updatePicturesCount:(NSNotification *)note
{
    // Si ya se cargo la collection
    if ([[self collection] count]) {
        // ejecutar el método requerido por el protocolo para actualizar la colección
        [self performSelector:@selector(refreshCollection)];
        //[self setCollection:nil];
    }
    
    // Actualizo el contador asociado a este TabBar
    [APIProvider getSummaryFromEmail:[self email]
                      withCompletion:^(Summary *summary) {
                          // Seteo el nuevo contador de fotos
                          [self setPicturesCount:[summary post_user]];
                          
                          // Reseteo el valor que indica cuantas prendas quiero en el MHTabBarController
                          [[self tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [self picturesCount], PROFILE_TAB_TITLE_TYPE_PROFILEPICTURES]];
                          
                          // Le indico al MHTabBarController que se debe actualizar
                          [(MHTabBarController *)[self parentViewController] updateTabBarButtons];
                          
                          //NSLog(@"Se cargo el resumen del usuario");
                      }
                           withError:^{
                               //NSLog(@"No se cargo el resumen del usuario");
                           }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - PictureCollectionViewControllerDatasource

- (void)loadCollection
{
    if (![self collection] || ([[self collection] count] < 3)) {
        // Muestro el indicador de cargando
        [SVProgressHUD show];
        
        // Cargo las fotos del perfil
        [APIProvider getProfilePicturesFromEmail:[self email]
                                      withOffset:0
                                  withCompletion:^(NSMutableArray *collection) {
                                      [self setCollection:collection];
                                      
                                      [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                      
                                      [SVProgressHUD dismiss];
                                  }
                                       withError:^{
                                           [self setCollection:nil];
                                           
                                           [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                           
                                           [SVProgressHUD dismiss];
                                       }];
    }
}

- (void)refreshCollection
{
    [self setCollection:nil];
    
    // Muestro el indicador de cargando
    [[self pullToRefreshView] startLoading];
    
    // Cargo las fotos del perfil
    [APIProvider getProfilePicturesFromEmail:[self email]
                                  withOffset:0
                              withCompletion:^(NSMutableArray *collection) {
                                  [self setCollection:collection];
                                  
                                  [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                  
                                  [[self pullToRefreshView] finishLoading];
                                  [[[self collectionView] infiniteScrollingView] stopAnimating];
                              }
                                   withError:^{
                                       [[self pullToRefreshView] finishLoading];
                                       [[[self collectionView] infiniteScrollingView] stopAnimating];
                                   }];
}

- (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset
{
    if ([self collection]) {
        // cargar más fotos del perfil
        [APIProvider getProfilePicturesFromEmail:[self email]
                                      withOffset:[offset intValue]
                                  withCompletion:^(NSMutableArray *collection) {
                                      [[self collection] addObjectsFromArray:collection];
                                      
                                      [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                      
                                      [[self pullToRefreshView] finishLoading];
                                      [[[self collectionView] infiniteScrollingView] stopAnimating];
                                  }
                                       withError:^{
                                           [[self pullToRefreshView] finishLoading];
                                           [[[self collectionView] infiniteScrollingView] stopAnimating];
                                       }];
    }
}

@end
