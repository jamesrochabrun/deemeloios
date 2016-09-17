//
//  MainViewController.h
//  Deemelo
//
//  Created by Cesar Ortiz on 09-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h> 
#import "Constants.h"
#import "AppDelegate.h"

@interface MainViewController : UIViewController

@property (nonatomic) UIButton *facebookLogin, *appLogin, *signUp;
@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;
@property (nonatomic) IBOutlet UIImageView *bottomImage;

-(IBAction) loginWithFacebook;
-(IBAction) loginWithApplication;
-(IBAction) goToSignUp;


@end
