//
//  ProfileViewController.m
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "ProfileViewController.h"

#import "Summary.h"
#import "Constants.h"
#import "UpdateUserViewController.h"

#import "ProfilePicturesViewController.h"
#import "IWantPicturesViewController.h"
#import "FollowingViewController.h"
#import "FollowersViewController.h"

#define SEGUIR @"Seguir"
#define NOSEGUIR @"No seguir"

@implementation ProfileViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Perfil" image:nil tag:4];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"perfil_activo.png"]
                      withFinishedUnselectedImage:[UIImage imageNamed:@"perfil.png"]];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, 0, 0);
        self.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
        
        // Me adiero al NotificationCenter para saber cuando se actualizan mis datos.
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(userUpdated:)
                   name:UserUpdatedNotification
                 object:nil];
    }
    return self;
}

// Al seguir/noSeguir un usuario desde su perfil se actualizar el contador y lista de seguidores
- (void) userUpdated:(NSNotification *)notice
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ( [[self currentEmail] isEqualToString:[[appDelegate currentUser] email]] ) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // Seteo en la vista el nombre del usuario
        [[self profileName] setText:[[appDelegate currentUser] name]];
        
        // Seteo en la vista la URL del usuario
        [[self profileUrl] setText:[[appDelegate currentUser] url]];
        
        // Seteo en la vista el avatar del usuario
        [[self profileAvatar] setImageWithURL:[NSURL URLWithString:[[appDelegate currentUser] routeThumbnail]]
                             placeholderImage:[UIImage imageNamed:@"avatar.png"]];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UserUpdatedNotification
                                                  object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Seteo el boton Seguir/NoSeguir para hacerlo redondeado y similar a otros botones
    [[[self followButton] layer] setCornerRadius:7.0f];
    [[[self followButton] layer] setBorderWidth:1];
    [[[self followButton] layer] setMasksToBounds: TRUE];
    
    self.navigationItem.titleView = [CustomBarButtonItems titleView:self.navigationController.navigationBar view:self.view];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Reviso que email tengo que usar, por defecto usa el del usuario logeado
    if ([[[self navigationController] viewControllers] count] == 1) {
        [self setCurrentEmail:[[appDelegate currentUser] email]];
    }
    
    [APIProvider getUserRanking:[self currentEmail]
                 withCompletion:^(Ranking *ranking) {
                     self.navigationItem.rightBarButtonItem = [CustomBarButtonItems rightBarButtonWithImageName:@"star.png"
                                                                                                      andBadget:[ranking points]];
                 } withError:^(NSString *error) {
                     self.navigationItem.rightBarButtonItem = [CustomBarButtonItems rightBarButtonWithImageName:@"star.png"
                                                                                                      andBadget:0];
                 }];
    
    //[SVProgressHUD show];
    // El [SVProgressHUD dismiss]; se quito porque el SVProgressHUD de las pestañas del perfil se ocultaba antes de lo necesario.
    
    // Por defecto el boton seguir lo dejo oculto
    [[self followButton] setHidden:YES];
    
    // Por defecto el boton seguir lo dejo oculto
    [[self configureButton] setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Reviso si tengo que poner el boton volver
    if ([[[self navigationController] viewControllers] count] > 1) {
        UIImage  *backImage  = [UIImage imageNamed:@"back.png"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [backButton setBounds:CGRectMake(0, 0, [backImage size].width, [backImage size].height)];
        [backButton setImage:backImage
                    forState:UIControlStateNormal];
        
        [backButton addTarget:self
                       action:@selector(backFromProfile:)
             forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        [[self navigationItem] setLeftBarButtonItem:backButtonItem];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // si no se ha mostrado el nombre del usuario, cargar el avatar, nombre y url
    if ([[[self profileName] text] isEqualToString:@""]) {
        // Cargo el perfil del usuario logeado
        [APIProvider getProfileWithEmail:[self currentEmail]
                          withCompletion:^(User *profile) {
                              // Seteo en la vista el nombre del usuario
                              [[self profileName] setText:[profile name]];
                              
                              // Seteo en la vista la URL del usuario
                              [[self profileUrl] setText:[profile url]];
                              
                              // Seteo en la vista el avatar del usuario
                              [[self profileAvatar] setImageWithURL:[NSURL URLWithString:[profile routeThumbnail]]
                                                   placeholderImage:[UIImage imageNamed:@"avatar.png"]];
                              
                              //NSLog(@"Cargó ok el perfil del usuario");
                          }
                               withError:^{
                                   //NSLog(@"No cargó el perfil del usuario");
                               }];
    }
    
    // Configuro botton seguir/no-seguir
    if ( ![[self currentEmail] isEqualToString:[[appDelegate currentUser] email]] ) {
        // Reviso si el usuario logeado esta siguiendo este perfil
        [APIProvider followingUserWithEmail:[self currentEmail]
                                      email:[[appDelegate currentUser] email]
                             withCompletion:^(BOOL following) {
                                 if (following) {
                                     [[self followButton] setTitle:NOSEGUIR forState:UIControlStateNormal];
                                 } else {
                                     [[self followButton] setTitle:SEGUIR forState:UIControlStateNormal];
                                 }
                                 
                                 [[self followButton] setHidden:NO];
                                 
                                 //NSLog(@"Logro saber si el usuario logeado esta siguiendo este perfil");
                             }
                                  withError:^{
                                      //NSLog(@"No logro saber si el usuario logeado esta siguiendo este perfil");
                                  }];
        [[self configureButton] setHidden:YES];
    } else {
        [[self configureButton] setHidden:NO];
    }
    
    // si no se han mostrado el tabbar y sus viewcontrollers, cargarlos
    if (![self tab]) {
        
        // agregar los viewcontrollers del container
        [self setTab:[[MHTabBarController alloc] init]];
        
        ProfilePicturesViewController *profilePictures  =
        [[ProfilePicturesViewController alloc] initWithNibName:nil
                                                        bundle:nil
                                                         email:[self currentEmail]
                                                    storyboard:[self storyboard]
                                                 picturesCount:@""];
        
        IWantPicturesViewController *profileIWant =
        [[IWantPicturesViewController alloc] initWithNibName:nil
                                                      bundle:nil
                                                       email:[self currentEmail]
                                                  storyboard:[self storyboard]
                                                  iWantCount:@""];
        
        FollowingViewController *profileFollowing =
        [[FollowingViewController alloc] initWithNibName:nil
                                                  bundle:nil
                                                   email:[self currentEmail]
                                              storyboard:[self storyboard]
                                          followingCount:@""];
        
        FollowersViewController *profileFollowers =
        [[FollowersViewController alloc] initWithNibName:nil
                                                  bundle:nil
                                                   email:[self currentEmail]
                                              storyboard:[self storyboard]
                                          followersCount:@""];
        
        [self setProfilePicturesVC:profilePictures];
        [self setProfileIWantVC:profileIWant];
        [self setProfileFollowingVC:profileFollowing];
        [self setProfileFollowersVC:profileFollowers];
        
        // Agrego las vistas del TabBarController
        [[self tab] setViewControllers:@[profilePictures, profileIWant, profileFollowing, profileFollowers]];
        
        // Agrego el TabBarController a la vista del perfil
        [self addChildViewController:[self tab]];
        
        // Seteo el Frame del TabBarController
        [[[self tab] view] setFrame:[[self tabBarContainer] frame]];
        
        // Agrego las vistas del TabBarController a la vista del perfil
        [[self view] addSubview:[[self tab] view]];
        
        [[self tab] didMoveToParentViewController:self];
        
    } else {
        // en caso que un memory warning haya eliminado la vista de tab, recargarla
        if (![[self tab] isViewLoaded]) {
            [self addChildViewController:[self tab]];
            [[[self tab] view] setFrame:[[self tabBarContainer] frame]];
            [[self view] addSubview:[[self tab] view]];
            
            [[self tab] didMoveToParentViewController:self];
        }
    }
    
    // si algún contador muestra nada, cargar los contadores
    if ([[[self profilePicturesVC] picturesCount] isEqualToString:@""]) {
        [APIProvider getSummaryFromEmail:[self currentEmail]
                          withCompletion:^(Summary *summary) {
                              
                              // actualizar los contadores del tab bar
                              ProfilePicturesViewController *profilePictures = [self profilePicturesVC];
                              IWantPicturesViewController *profileIWant = [self profileIWantVC];
                              FollowingViewController *profileFollowing = [self profileFollowingVC];
                              FollowersViewController *profileFollowers = [self profileFollowersVC];
                              
                              // Seteo el nuevo contador de fotos
                              [profilePictures setPicturesCount:[summary post_user]];
                              [[profilePictures tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [profilePictures picturesCount], PROFILE_TAB_TITLE_TYPE_PROFILEPICTURES]];
                              
                              // Seteo el nuevo contador de prendas que quiero
                              [profileIWant setIWantCount:[summary want]];
                              [[profileIWant tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [profileIWant iWantCount], PROFILE_TAB_TITLE_TYPE_IWANTPICTURES]];
                              
                              // Seteo el nuevo contador de seguidos
                              [profileFollowing setFollowingCount:[summary following]];
                              [[profileFollowing tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [profileFollowing followingCount], PROFILE_TAB_TITLE_TYPE_FOLLOWING]];
                              
                              // Seteo el nuevo contador de seguidores
                              [profileFollowers setFollowersCount:[summary followers]];
                              [[profileFollowers tabBarItem] setTitle:[NSString stringWithFormat:@"%@\n%@", [profileFollowers followersCount], PROFILE_TAB_TITLE_TYPE_FOLLOWERS]];
                              
                              // Le indico al MHTabBarController que se debe actualizar
                              [(MHTabBarController *)[profilePictures parentViewController] updateTabBarButtons];
                              
                              //NSLog(@"Se cargo el resumen del usuario");
                          }
                               withError:^{
                                   //NSLog(@"No se cargo el resumen del usuario");
                               }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Accion que se realiza al pinchar en el boton atras de los perfiles de otros usuarios
- (void)backFromProfile:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}



# pragma mark - Actions
- (IBAction)followButtonPressed:(id)sender {
    // Deshabilito el boton para que no lo pinchen mas de una vez seguido
    [[self followButton] setEnabled:NO];
    
    [SVProgressHUD show];
    
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([[[[self followButton] titleLabel] text] isEqualToString:SEGUIR]) {
        [APIProvider followUserWithEmail:[self currentEmail]
                                   email:[[appDelegate currentUser] email]
                          withCompletion:^(BOOL successfully, NSString *errorMessage) {
                              // Logre dejar de seguir al usuario?
                              if (successfully) {
                                  [[self followButton] setTitle:NOSEGUIR forState:UIControlStateNormal];
                                  
                                  NSDictionary    *extraInfo = [NSDictionary dictionaryWithObject:[self currentEmail] forKey:@"email"];
                                  NSNotification *notice     = [NSNotification notificationWithName:FollowUserNotification
                                                                                             object:self
                                                                                           userInfo:extraInfo];
                                  [[NSNotificationCenter defaultCenter] postNotification:notice];
                              }
                              
                              [SVProgressHUD dismiss];
                              
                              // habilito el boton para que lo puedan volver a pinchar
                              [[self followButton] setEnabled:YES];
                          }
                               withError:^(NSString *message){
                                   [SVProgressHUD dismiss];
                                   
                                   // habilito el boton para que lo puedan volver a pinchar
                                   [[self followButton] setEnabled:YES];
                               }];
    } else {
        [APIProvider unfollowUserWithEmail:[self currentEmail]
                                     email:[[appDelegate currentUser] email]
                            withCompletion:^(BOOL successfully, NSString *errorMessage) {
                                // Logre dejar de seguir al usuario?
                                if (successfully) {
                                    [[self followButton] setTitle:SEGUIR forState:UIControlStateNormal];
                                    
                                    NSDictionary   *extraInfo = [NSDictionary dictionaryWithObject:[self currentEmail] forKey:@"email"];
                                    NSNotification *notice    = [NSNotification notificationWithName:UnfollowUserNotification
                                                                                              object:self
                                                                                            userInfo:extraInfo];
                                    [[NSNotificationCenter defaultCenter] postNotification:notice];
                                }
                                
                                [SVProgressHUD dismiss];
                                
                                // habilito el boton para que lo puedan volver a pinchar
                                [[self followButton] setEnabled:YES];
                            }
                                 withError:^(NSString *message){
                                     [SVProgressHUD dismiss];
                                     
                                     // habilito el boton para que lo puedan volver a pinchar
                                     [[self followButton] setEnabled:YES];
                                 }];
    }
}

- (IBAction)configureButtonPressed:(id)sender {
    // Cargo una referencia a la vista del Storyborad que muestra un perfil de usuario
    UpdateUserViewController *updateUserViewController = [[UpdateUserViewController alloc] initWithNibName:nil bundle:nil];
    
    // Muestro la prenda en la vista previamente cargada
    [[self navigationController] pushViewController:updateUserViewController animated:YES];
}

@end
