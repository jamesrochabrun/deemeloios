//
//  PoliciesViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 8/28/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "PoliciesViewController.h"
#import "AppDelegate.h"

@implementation PoliciesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Cancelar"
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(cancel:)];
        
        [cancelItem setTintColor:[UIColor colorWithRed:(236/255.0)
                                                 green:(100/255.0)
                                                  blue:(114/255.0)
                                                 alpha:1]];
        
        [[self navigationItem] setLeftBarButtonItem:cancelItem];
    }
    return self;
}

- (void)loadView
{
    // crear webview
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    [self setWebView:[[UIWebView alloc] initWithFrame:screenFrame]];
    [[self webView] setDelegate:self];
    [[self webView] setScalesPageToFit:YES];
    [self setView:[self webView]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // corregir colores de los uibarbuttonitems
    [[[self navigationController] navigationBar] setTintColor:[UIColor colorWithRed:(236/255.0)
                                                                              green:(100/255.0)
                                                                               blue:(114/255.0)
                                                                              alpha:1]];
}

- (void)viewDidAppear:(BOOL)animated
{
    // cargar url
    NSURL *url = [NSURL URLWithString:POLICIES_URL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [[self webView] loadRequest:req];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAcceptButton
{
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Aceptar"
                                 style:UIBarButtonItemStyleDone
                                 target:self
                                 action:@selector(accept:)];
    
    [doneItem setTintColor:[UIColor colorWithRed:(236/255.0)
                                           green:(100/255.0)
                                            blue:(114/255.0)
                                           alpha:1]];
    
    [[self navigationItem] setRightBarButtonItem:doneItem animated:YES];
}

- (void)accept:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES
                                                        completion:[self acceptedPoliciesDismissBlock]];
}

- (void)cancel:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES
                                                        completion:nil];
}

#pragma mark - UIWebView Delegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    
    [self showAcceptButton];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [error localizedDescription]]];
    
    [self showAcceptButton];
}

@end
