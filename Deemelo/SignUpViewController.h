//
//  SignUpViewController.h
//  Deemelo
//
//  Created by Cesar Ortiz on 02-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <CMPopTipView/CMPopTipView.h>
#import "AppDelegate.h"
#import "APIProvider.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) IBOutlet UITextField *name, *email, *password, *repeatPassword;
@property (nonatomic) IBOutlet UIButton *cancel, *addUser;

@property (nonatomic) IBOutlet UIImageView *bottomImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)registerUser;

- (IBAction)cancelButtonPressed;
- (IBAction)registerButtonPressed;

//-(IBAction) policiesButtonPressed;

@end
