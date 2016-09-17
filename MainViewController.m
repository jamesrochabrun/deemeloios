//
//  MainViewController.m
//  Deemelo
//
//  Created by Cesar Ortiz on 09-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "MainViewController.h"

/*
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation MainViewController

@synthesize  facebookLogin, appLogin, signUp, bottomImage;
@synthesize accountStore, facebookAccount;

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    if([AppDelegate isRetina4]) {
        [bottomImage setImage:[UIImage imageNamed:@"login_retina4"]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // advertencia de sistema operativo no soportado
    
    /*
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        
        NSString *message = [NSString stringWithFormat:@"Detectamos iOS %@ en tu iPhone. Ten presente que la experiencia de usuario no será la óptima, ya que Deemelo fue diseñado para iOS 6.", [[UIDevice currentDevice] systemVersion]];
                             
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Versión no soportada"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil];
        [av show];
    }
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loginWithApplication
{
    AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
    [sharedApp setNewRootControllerWithSB:@"Main" andIdentifier:@"login"];
}

- (void) goToSignUp
{
    AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
    [sharedApp setNewRootControllerWithSB:@"Main" andIdentifier:@"signup"];
}

- (void)loginWithFacebook
{
    [SVProgressHUD show];
    
    AppDelegate *sharedApp = [AppDelegate sharedAppdelegate];
    
    // The person using the app has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    if(FBSession.activeSession.isOpen){
        [SVProgressHUD dismiss];
        [sharedApp setNewRootControllerWithSB:@"Dashboard" andIdentifier:@"dashboard"];
    } else {
        //NSLog(@"No activeSession");
//        [sharedApp openSessionWithAllowLoginUI:YES];
        
        // limpiar facebook access token
        [[FBSession activeSession] closeAndClearTokenInformation];
        
        // configurar permisos ya que necesitamos traer el email del usuario
        NSArray *permissions = [NSArray arrayWithObjects:@"email", @"user_friends", nil];
        
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              //run your user info request here
                                              [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                                                  if (!error) {
                                                      //NSLog(@"\n Nombre: %@ \n URL: %@ \n Email: %@",user.name, user.link, [user objectForKey:@"email"]);
                                                      NSString *nombres = user.name;
                                                      NSString *link    = user.link;
                                                      NSString *email   = [user objectForKey:@"email"];
                                                      NSString *genero  = [user objectForKey:@"gender"];
                                                      NSString *desc    = @"User Facebook";
                                                      NSString *user_id = [user objectForKey:@"id"];
                                                      NSString *img     = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",user_id];
                                                      [APIProvider loginWithFB:email names:nombres link:link img:img gender:genero desc:desc user_id:user_id];
                                                  } else {
                                                      NSLog(@"No activeSession error: %@", [error debugDescription]);
                                                  }
                                                  
                                              }];
                                          }
                                      }];
    }
}

@end
