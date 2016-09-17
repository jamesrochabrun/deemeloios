//
//  UpdateUserViewController.h
//  Deemelo
//
//  Created by Marcelo Espina on 31-07-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateUserViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UITextField *campoActivo;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sexSegmentedControl;


@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;


@property (strong, nonatomic) IBOutlet UITextField *newpassTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmNewpassTextField;

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *updateButton;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)updateButtonPressed:(id)sender;

- (IBAction)pickAvatarButtonPressed:(id)sender;

@end
