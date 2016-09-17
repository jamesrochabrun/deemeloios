//
//  LoginViewController.h
//  Deemelo
//
//  Created by Cesar Ortiz on 09-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "AppDelegate.h"
#import "Constants.h"
#import "APIProvider.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) IBOutlet UITextField *userName, *password;
@property (nonatomic) IBOutlet UIButton *cancel, *login;

@property (nonatomic) IBOutlet UIImageView *bottomImage;
@property (weak, nonatomic) IBOutlet UIView *controlContainerView;

- (IBAction)forgotPasswordButtonPressed:(id)sender;
- (IBAction)cancelLogin;
- (IBAction)loginWithApplication;
- (void)setButtonStyle:(UIButton *)button;

@end
