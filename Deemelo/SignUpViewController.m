//
//  SignUpViewController.m
//  Deemelo
//
//  Created by Cesar Ortiz on 02-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "SignUpViewController.h"
#import "PoliciesViewController.h"

@implementation SignUpViewController

@synthesize name, email, password, repeatPassword;
@synthesize cancel, addUser, bottomImage;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.name.delegate = self;
    self.email.delegate = self;
    self.password.delegate = self;
    self.repeatPassword.delegate = self;
    [password setSecureTextEntry:TRUE];
    [repeatPassword setSecureTextEntry:TRUE];
    
    if([AppDelegate isRetina4]) {
        [bottomImage setImage:[UIImage imageNamed:@"login_retina4"]];
    }
    
    [self setButtonStyle:cancel];
    [self setButtonStyle:addUser];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPulsado)];
    [tapRecognizer setCancelsTouchesInView:NO];
    [[self view] addGestureRecognizer:tapRecognizer];
}

- (void) scrollViewPulsado
{
    [[self view] endEditing:YES];
}

- (void)dealloc
{
    // Me des-inscribo en el NSNotificationCenter para saber cuando aparece el teclado
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    // Me des-inscribo en el NSNotificationCenter para saber cuando desaparece el teclado
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:TRUE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    BOOL validName=false, validEmail=false, validPassword=false, validRepeatPassword=false;
    
    if(textField == name) {
        NSString *nameRegex = @"[a-zA-Z0-9]{2,32}";
        NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
        validName = [regExPredicate evaluateWithObject:textField.text];
    } else if (textField == email) {
        NSString *emailRegex = @"[a-zA-Z0-9.\\-_]{2,32}@[a-zA-Z0-9.\\-_]{2,32}\\.[A-Za-z]{2,4}";
        NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        validEmail = [regExPredicate evaluateWithObject:textField.text];
    } else if (textField == password) {
        validPassword = textField.text.length > 0 ? TRUE : FALSE;
    } else {
        validRepeatPassword = textField.text.length > 0 && [textField.text isEqualToString:password.text] ? TRUE : FALSE;
    }
    
    if(validName || validEmail || validPassword || validRepeatPassword) {
        textField.layer.borderColor = [UIColor colorWithRed:255./255 green:255/255 blue:255./255 alpha:1].CGColor;
        textField.layer.borderWidth = 0;
    } else {
        [textField.layer setCornerRadius:7.0f];
        textField.layer.borderColor = [UIColor colorWithRed:255./255 green:1./255 blue:1./255 alpha:1].CGColor;
        textField.layer.borderWidth = 2;
        textField.layer.masksToBounds = TRUE;
    }
}

-(BOOL) validateFields {

    NSString *nameRegex = @"[a-zA-Z0-9]{2,32}";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    BOOL validName = [regExPredicate evaluateWithObject:name.text];
    NSString *emailRegex = @"[a-zA-Z0-9.\\-_]{2,32}@[a-zA-Z0-9.\\-_]{2,32}\\.[A-Za-z]{2,4}";
    regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL validEmail = [regExPredicate evaluateWithObject:email.text];
    BOOL validPassword = password.text.length > 0 ? TRUE : FALSE;
    BOOL validRepeatPassword = repeatPassword.text.length > 0 && [repeatPassword.text isEqualToString:password.text] ? TRUE : FALSE;
    
    if(validName && validEmail && validPassword && validRepeatPassword)
        return TRUE;
    
    return FALSE;
}

-(void) setButtonStyle:(UIButton *)button {
    [button.layer setCornerRadius:7.0f];
    button.layer.borderColor = [UIColor colorWithRed:1./255 green:1./255 blue:1./255 alpha:1].CGColor;
    button.layer.borderWidth = 1;
    button.layer.masksToBounds = TRUE;
}

- (void)registerUser
{
    [SVProgressHUD show];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [APIProvider registerUser:name.text email:email.text password:password.text];
    });
}

- (IBAction)registerButtonPressed
{
    if([self validateFields]) {
        
        // presentar vista modal con webview con términos y condiciones
        PoliciesViewController *pvc = [[PoliciesViewController alloc] init];
        
        [pvc setAcceptedPoliciesDismissBlock:^{
            [self registerUser];
        }];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pvc];
        [[navController navigationBar] setBackgroundImage:[UIImage imageNamed:@"header.png"]
                                            forBarMetrics:UIBarMetricsDefault];
        
        [self presentViewController:navController
                           animated:YES
                         completion:nil];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Hay campos incorrectos"];
    }
}

- (IBAction)cancelButtonPressed
{
    AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
    [sharedApp setNewRootControllerWithSB:@"Main" andIdentifier:@"main"];
}


-(void)keyboardWillShow:(NSNotification *)notif {
    NSDictionary* infoDict = [notif userInfo];
    CGRect keyboardScreenFrame = [[infoDict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //CGRect viewFrame = self.view.frame;
    CGRect viewFrame = self.scrollView.frame;
    CGRect keyboardFrame = [self.view.superview convertRect:keyboardScreenFrame fromView:nil];
    CGRect hiddenRect = CGRectIntersection(viewFrame, keyboardFrame);
    CGRect remainder, slice;
    CGRectDivide(viewFrame, &slice, &remainder, CGRectGetHeight(hiddenRect), CGRectMaxYEdge);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.0f];
    //self.view.frame = remainder;
    self.scrollView.frame = remainder;
    self.scrollView.contentSize = remainder.size;
    [UIView commitAnimations];
    
    // Creo un punto para mover el scroll en funcion del input
    // NOTA: Revisar por que hay q sumar el tabBarHeight
    CGSize                  kbSize = [[infoDict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float ycoordinate = [[self cancel] frame].origin.y - kbSize.height + 20;
    CGPoint scrollPoint = CGPointMake(0.0, ycoordinate);
    
    // Scroll al input para hacerlo visible
    [[self scrollView] setContentOffset:scrollPoint animated:YES];
}

-(void)keyboardWillHide:(NSNotification *)notif {
    float kbh = 0;
    kbh = [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    //CGRect frame = self.view.frame;
    CGRect frame = self.scrollView.frame;
    frame.size.height += kbh;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    //self.view.frame = frame;
    self.scrollView.frame = frame;
    [UIView commitAnimations];
}

//-(IBAction) policiesButtonPressed
//{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://deemelo.com/?page_id=284"]];
//}

@end
