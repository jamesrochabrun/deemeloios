//
//  IWantPicturesViewController.m
//  Deemelo
//
//  Created by Marcelo Espina on 24-06-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "IWantPicturesViewController.h"

#import "MHTabBarController.h"

@implementation IWantPicturesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil email:(NSString *)email storyboard:(UIStoryboard *)storyboard iWantCount:(NSString *)iWantCount
{
    self = [super initWithNibName:nil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setEmail:email];        
        [self setMyStoryboard:storyboard];
        [self setIWantCount:iWantCount];
        
        [[self tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [self iWantCount], PROFILE_TAB_TITLE_TYPE_IWANTPICTURES]];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ( [[[appDelegate currentUser] email] isEqualToString:[self email]] ) {
            // Me adiero al NotificationCenter para saber cuando comienzo a seguir otros usuarios.
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(updateIWantCount:)
                       name:IWantPictureNotification
                     object:nil];
            
            [nc addObserver:self
                   selector:@selector(updateIWantCount:)
                       name:NotWantPictureNotification
                     object:nil];
        }
    }
    return self;
}

// Al querer/noQuerer una prenda se actualizar el contador de 'Lo Quiero' del usuario logeado
- (void) updateIWantCount:(NSNotification *)notice
{
    // Si ya se cargo la collection
    if ([[self collection] count]) {
        // ejecutar el método requerido por el protocolo para actualizar la colección
        [self performSelector:@selector(refreshCollection)];
    }
    
    // Actualizo el contador asociado a este TabBar
    [APIProvider getSummaryFromEmail:[self email]
                      withCompletion:^(Summary *summary) {
                          // Seteo el nuevo contador de seguidos
                          [self setIWantCount:[summary want]];
                          
                          // Reseteo el valor que indica cuantas prendas quiero en el MHTabBarController
                          [[self tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [self iWantCount], PROFILE_TAB_TITLE_TYPE_IWANTPICTURES]];
                          
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
	// Do any additional setup after loading the view.
}

#pragma mark - PictureCollectionViewControllerDatasource

- (void)loadCollection
{
    if (![self collection] || ([[self collection] count] < 3)) {
        // Muestro el indicador de cargando
        [SVProgressHUD show];
        
        // Cargo las fotos de las cosas que quiero
        [APIProvider getIWantPicturesFromEmail:[self email]
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
    
    // Cargo las fotos de las cosas que quiero
    [APIProvider getIWantPicturesFromEmail:[self email]
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
        // cargar más fotos de las cosas que quiero
        [APIProvider getIWantPicturesFromEmail:[self email]
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
