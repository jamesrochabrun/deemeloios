//
//  FollowersViewController.m
//  Deemelo
//
//  Created by Marcelo Espina on 25-06-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "FollowersViewController.h"

@implementation FollowersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil email:(NSString *) email storyboard:(UIStoryboard *)storyboard followersCount:(NSString *)followersCount
{
    self = [super initWithNibName:@"UserCollectionViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setEmail:email];
        [self setMyStoryboard:storyboard];
        [self setFollowersCount:followersCount];
        
        [[self tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [self followersCount], PROFILE_TAB_TITLE_TYPE_FOLLOWERS]];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ( ![[[appDelegate currentUser] email] isEqualToString:[self email]] ) {
            // Me adiero al NotificationCenter para saber cuando comienzo a ser seguido por otros usuarios.
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(updateFollowed:)
                       name:FollowUserNotification
                     object:nil];
            
            [nc addObserver:self
                   selector:@selector(updateFollowed:)
                       name:UnfollowUserNotification
                     object:nil];
        }
    }
    return self;
}

// Al seguir/noSeguir un usuario desde su perfil se actualizar el contador y lista de seguidores
- (void) updateFollowed:(NSNotification *)notice
{
    // Chequeo que sea yo al que comenzaron a seguir
    if ([[[notice userInfo] valueForKey:@"email"] isEqualToString:[self email]]) {
        // Si ya se cargo la collection
        if ([[self collection] count]) {
            // ejecutar el método requerido por el protocolo para actualizar la colección
            [self performSelector:@selector(refreshCollection)];
        }
        
        // Actualizo el contador asociado a este TabBar
        [APIProvider getSummaryFromEmail:[self email]
                          withCompletion:^(Summary *summary) {
                              // Seteo el nuevo contador de seguidos
                              [self setFollowersCount:[summary followers]];
                              
                              // Reseteo el valor que indica cuantas prendas quiero en el MHTabBarController
                              [[self tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [self followersCount], PROFILE_TAB_TITLE_TYPE_FOLLOWERS]];
                              
                              // Le indico al MHTabBarController que se debe actualizar
                              [(MHTabBarController *)[self parentViewController] updateTabBarButtons];
                              
                              //NSLog(@"Se cargo el resumen del usuario");
                          }
                               withError:^{
                                   //NSLog(@"No se cargo el resumen del usuario");
                               }];
    }
}

- (void)loadCollection
{
    // Si los seguidores aun no se cargan
    if (![self collection]) {
        // Muestro el indicador de cargando
        [SVProgressHUD show];
        
        // Cargo la lista de seguidores
        [APIProvider getFollowersFromEmail:[self email]
                                withOffset:0
                            withCompletion:^(NSMutableArray *collection) {
                                [self setCollection:collection];
                                
                                [[self tableView] reloadData];
                                
//                                // Reviso si el contador precalculado que envia el servidor es diferente del total en la coleccion
//                                if ( ![[self followersCount] isEqualToString:[NSString stringWithFormat:@"%d", [collection count]]]) {
//                                    // Seteo el nuevo contador de seguidos
//                                    [self setFollowersCount:[NSString stringWithFormat:@"%d", [collection count]]];
//                                    
//                                    // Reseteo el valor que indica cuando perfiles de usuario estoy siguiendo en la MHTabBarController
//                                    [[self tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [self followersCount], PROFILE_TAB_TITLE_TYPE_FOLLOWERS]];
//                                    
//                                    // Le indico al MHTabBarController que se debe actualizar
//                                    [(MHTabBarController *)[self parentViewController] updateTabBarButtons];
//                                }
                                
                                [SVProgressHUD dismiss];
                            }
                                 withError:^{
                                     [SVProgressHUD dismiss];
                                 }];
    }
}

- (void)refreshCollection
{
    // Cargo la lista de seguidores
    [APIProvider getFollowersFromEmail:[self email]
                            withOffset:0
                        withCompletion:^(NSMutableArray *collection) {
                            [self setCollection:collection];
                            
                            [[self tableView] reloadData];
                            
//                            // Seteo el nuevo contador de seguidos
//                            [self setFollowersCount:[NSString stringWithFormat:@"%d", [collection count]]];
//                            
//                            // Reseteo el valor que indica cuando perfiles de usuario estoy siguiendo en la MHTabBarController
//                            [[self tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [self followersCount], PROFILE_TAB_TITLE_TYPE_FOLLOWERS]];
//                            
//                            // Le indico al MHTabBarController que se debe actualizar
//                            [(MHTabBarController *)[self parentViewController] updateTabBarButtons];
                            
                            [[self pullToRefreshView] finishLoading];
                        }
                             withError:^{
                                 [[self pullToRefreshView] finishLoading];
                             }];
}

@end
