//
//  LoginViewController.m
//  Deemelo
//
//  Created by Cesar Ortiz on 09-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

@synthesize userName, password, cancel, login, bottomImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userName.delegate = self;
    password.delegate = self;
    [password setSecureTextEntry:TRUE];
    [self setButtonStyle:cancel];
    [self setButtonStyle:login];
    
    if([AppDelegate isRetina4]) {
        [bottomImage setImage:[UIImage imageNamed:@"login_retina4"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)forgotPasswordButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PASSWORD_URL]];
}

- (IBAction)cancelLogin
{
    AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
    [sharedApp setNewRootControllerWithSB:@"Main" andIdentifier:@"main"];
}

- (IBAction)loginWithApplication
{
    [SVProgressHUD show];
    [APIProvider loginAppWithUsername:userName.text andPasword:password.text];
    
    /*
    [SVProgressHUD show];
    __block NSMutableArray *fetchedClothes = [APIProvider getPopularClothes:@"0" withCompletion:^{
        AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
        sharedApp.prendas = fetchedClothes;
        [APIProvider loginAppWithUsername:userName.text andPasword:password.text];
    } withError:^{
        // handle the error here
    }];
    */
}

- (void)setButtonStyle:(UIButton *)button
{
    [button.layer setCornerRadius:7.0f];
    button.layer.borderColor = [UIColor colorWithRed:1./255 green:1./255 blue:1./255 alpha:1].CGColor;
    button.layer.borderWidth = 1;
    button.layer.masksToBounds = TRUE;
}

-(void) keyboardWillShow:(NSNotification *)notif {
    NSDictionary* infoDict = [notif userInfo];
    CGRect keyboardScreenFrame = [[infoDict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect viewFrame = self.view.frame;
    CGRect keyboardFrame = [self.view.superview convertRect:keyboardScreenFrame fromView:nil];
    CGRect hiddenRect = CGRectIntersection(viewFrame, keyboardFrame);
    CGRect remainder, slice;
    CGRectDivide(viewFrame, &slice, &remainder, CGRectGetHeight(hiddenRect), CGRectMaxYEdge);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.0f];
    self.view.frame = remainder;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)notif {
    float kbh = 0;
    kbh = [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect frame = self.view.frame;
    frame.size.height += kbh;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    self.view.frame = frame;
    [UIView commitAnimations];
}

@end
