//
//  AppDelegate.m
//  Deemelo
//
//  Created by Cesar Ortiz on 02-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoViewController.h"

@implementation AppDelegate

@synthesize tabController;
@synthesize session = _session;
@synthesize prendas, categories, categoryImages, categorySelected;
@synthesize objectDetail;

NSString *const FBSessionStateChangedNotification = @"cl.acid.Deemelo:FBSessionStateChangedNotification";


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // configurar nivel de log de restkit
    RKLogConfigureByName("RestKit/Network", RKLogLevelOff);
    //RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
    
    // cargar testflight
    [TestFlight setOptions:@{TFOptionDisableInAppUpdates: @YES}];
    [TestFlight takeOff:TESTFLIGHT_APP_TOKEN];
    
    // cargar categorías
    [self performSelectorInBackground:@selector(fetchCategories) withObject:nil];
    
    // traer último usuario logeado
    User *lastUser = nil;
    NSData *lastUserData = [[NSUserDefaults standardUserDefaults] dataForKey:DEEMELO_CURRENT_USER_DATA_PREF_KEY];
    if (lastUserData) {
        lastUser = [NSKeyedUnarchiver unarchiveObjectWithData:lastUserData];
    }
    
    if (!lastUser) {
        // si no encontró un último usuario logeado, presentar menú de ingreso
        [self setCurrentUser:nil];
        [self setNewRootControllerWithSB:@"Main" andIdentifier:@"main"];
        //NSLog(@"NO currentUser: %@", [self currentUser]);
    } else {
        // si lo encontró, presentar momentáneamente el menú del usuario
        [self setCurrentUser:lastUser];
        [self setNewRootControllerWithSB:@"Dashboard" andIdentifier:@"dashboard"];
        
        // chequear si el token aún es válido
        [APIProvider validateToken:[lastUser token]
                    withCompletion:^{
                        // lo comentamos ya que lo hicimos más arriba
                        //[self setCurrentUser:lastUser];
                        //[self setNewRootControllerWithSB:@"Dashboard" andIdentifier:@"dashboard"];
                        //NSLog(@"OK currentUser: %@", [self currentUser]);
                    }
                         withError:^{
                             //NSLog(@"ERROR currentUser: %@", [self currentUser]);
                             //avisar que la sesión expiró
                             [SVProgressHUD dismiss];
                             //[SVProgressHUD showErrorWithStatus:@"Sesión Expirada"];
                             
                             //limpiar currentUser en nsuserdefaults
                             [[NSUserDefaults standardUserDefaults] setObject:nil
                                                                       forKey:DEEMELO_CURRENT_USER_DATA_PREF_KEY];
                             [[NSUserDefaults standardUserDefaults] synchronize];
                             
                             [self setCurrentUser:nil];
                             [self setNewRootControllerWithSB:@"Main" andIdentifier:@"main"];
                         }];
    }
    
    return YES;
}

+ (AppDelegate*)sharedAppdelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)setNewRootControllerWithSB:(NSString*)storyboardName andIdentifier:(NSString*)identifier
{
    UIViewController *controller = [[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateViewControllerWithIdentifier:identifier];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.window setRootViewController:controller];
    
    // Para que el tab bar button que toma fotos funcione "bien",
    // seteo el property tabController al tab bar controller del dashboard
    // y luego seteo a self como delegate de este tab bar controller
    if ([[[self window] rootViewController] isKindOfClass:[UITabBarController class]]) {
        [self setTabController:(UITabBarController *)[[self window] rootViewController]];
        [[self tabController] setDelegate:self];
    }
}

- (void)setNewRootControllerWithModifiedViewController:(UIViewController*)viewController
{
    [self.window setRootViewController:viewController];
}

+ (BOOL)isRetina4
{
    return (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && (([UIScreen mainScreen].bounds.size.height * [[UIScreen mainScreen] scale]) >= 1136));
}

- (void)fetchCategories
{
    categories = [APIProvider getCategories];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // We need to properly handle activation of the app with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [FBSession.activeSession close];
}


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"email", @"user_likes",  nil];
   
    return [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:allowLoginUI  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                [self sessionStateChanged:session state:state  error:error];
            }];
}

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"We have a valid session");
                [SVProgressHUD dismiss];
                AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
                [sharedApp setNewRootControllerWithSB:@"Dashboard" andIdentifier:@"dashboard"];
                
            }
            break;
        case FBSessionStateClosed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:[error debugDescription]
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - UITabBarControllerDelegate methods

// este método llama al action sheet para crear un nuevo producto
// y evita que el tab bar button quede apretado
// en caso que el usuario cancele
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        if ([[(UINavigationController *)viewController topViewController] isKindOfClass:[PhotoViewController class]]) {
            
            // guardar referencia al navcontroller que contiene el photoviewcontroller
            [self setANewProductNavController:(UINavigationController *)viewController];
            
            // guardar referencia al photoviewcontroller
            [self setPhotoController:(PhotoViewController *)[(UINavigationController *)viewController topViewController]];
            
            // configurar botones del action sheet
            NSString *cameraButtonTitle = @"Tomar Foto";
            NSString *libraryButtonTitle = @"Escoger Foto";
            NSString *cancelButtonTitle = @"Cancelar";
            
            UIActionSheet *actionSheet;
            
            // crear el action sheet
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                // si la cámara está disponible, mostrar botones para tomar foto y escoger de la biblioteca
                actionSheet =
                [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:(PhotoViewController *)[(UINavigationController *)viewController topViewController]
                                   cancelButtonTitle:cancelButtonTitle
                              destructiveButtonTitle:nil
                                   otherButtonTitles:cameraButtonTitle, libraryButtonTitle, nil];
            } else {
                
                // si la cámara no está disponible, mostrar sólo el botón de la biblioteca
                actionSheet =
                [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:(PhotoViewController *)[(UINavigationController *)viewController topViewController]
                                   cancelButtonTitle:cancelButtonTitle
                              destructiveButtonTitle:nil
                                   otherButtonTitles:libraryButtonTitle, nil];
            }
            
            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
            
            // mostrar el action sheet
            [actionSheet showFromTabBar:[[self tabController] tabBar]];
            
            return NO;
        }
    }
    return YES;
}

@end
