//
//  UpdateUserViewController.m
//  Deemelo
//
//  Created by Marcelo Espina on 31-07-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "UpdateUserViewController.h"
#import "CustomBarButtonItems.h"
#import "AppDelegate.h"
#import "Constants.h"

typedef enum {
    rotateLeft,
    rotateRight
} rotationType;

@implementation UpdateUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [SVProgressHUD dismiss];
    
    // Seteo la barra de navegación
    [[self navigationItem] setTitleView:[CustomBarButtonItems titleView:[[self navigationController] navigationBar]
                                                                   view:[self view]]];
    
    // corregir colores de los uibarbuttonitems
    [[[self navigationController] navigationBar] setTintColor:[UIColor colorWithRed:(236/255.0)
                                                                              green:(100/255.0)
                                                                               blue:(114/255.0)
                                                                              alpha:1]];
    
    // agregar botón para logout
    UIBarButtonItem *logOutButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Salir"
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(logOutButtonTapped:)];
    
    [logOutButtonItem setTintColor:[UIColor colorWithRed:(236/255.0)
                                                   green:(100/255.0)
                                                    blue:(114/255.0)
                                                   alpha:1]];
    
    [[self navigationItem] setRightBarButtonItem:logOutButtonItem];
    
    // Seteo los dato actuales en los inputs
    AppDelegate* appDelegate = [AppDelegate sharedAppdelegate];

    [[self usernameTextField] setText:[[appDelegate currentUser] userName]];
    [[self nameTextField] setText:[[appDelegate currentUser] name]];
    [[self urlTextField] setText:[[appDelegate currentUser] url]];
    [[self emailLabel] setText:[[appDelegate currentUser] email]];

    [[self avatarImageView] setImageWithURL:[NSURL URLWithString:[[appDelegate currentUser] routeThumbnail]]
                           placeholderImage:[UIImage imageNamed:@"avatar.png"]];
    
    
    // Estilo de los botones
    [self setButtonStyle:[self cancelButton] andRadius:5.0f andWidth:0.0f andColor:[UIColor whiteColor]];
    [self setButtonStyle:[self updateButton] andRadius:5.0f andWidth:0.0f andColor:[UIColor whiteColor]];
    
    // Agrego callback para ver cuando aparece el teclado
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(apareceElTeclado:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    // Agrego callback para ver cuando desaparece el teclado
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(desapareceElTeclado:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // Agrego callback para ver cuando se sale del foco del input
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(scrollViewPulsado)];
    [tapRecognizer setCancelsTouchesInView:NO];
    [[self scrollView] addGestureRecognizer:tapRecognizer];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

// Accion que se realiza al pinchar en el boton atras de los perfiles de otros usuarios
- (void)backFromProfile:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Métodos de UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setCampoActivo:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setCampoActivo:nil];
}

# pragma mark - Método para teclado
- (void) apareceElTeclado:(NSNotification *)notice
{
    // Obtenemos el tamaño del teclado
    NSDictionary *infoNotificacion = [notice userInfo];
    CGSize                  kbSize = [[infoNotificacion objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    AppDelegate* appDelegate = [AppDelegate sharedAppdelegate];
    float tabBarHeight = [[[appDelegate tabController] tabBar] frame].size.height;
    
    // Calculamos el nuevo tamaño de la 'ventana' de nuestro UIScrollView
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height - tabBarHeight, 0.0);
    
    // Modificamos el tamaño de la 'ventana' de nuestro UIScrollView con el tamaño previamiemente calculado
    [[self scrollView] setContentInset:edgeInsets];
    
    // Modificamos el scroll de la 'ventana' de nuestro UIScrollView con el tamaño previamiemente calculado
    [[self scrollView] setScrollIndicatorInsets:edgeInsets];
    
    
    // Creo un punto para mover el scroll en funcion del input
    // NOTA: Revisar por que hay q sumar el tabBarHeight
    float ycoordinate = [[self campoActivo] frame].origin.y - kbSize.height + tabBarHeight;
    CGPoint scrollPoint = CGPointMake(0.0, ycoordinate);
    
    // Scroll al input para hacerlo visible
    [[self scrollView] setContentOffset:scrollPoint animated:YES];
}

- (void) desapareceElTeclado:(NSNotification *)notice
{
    // Creamos una animación para que la vuelta a la normalidad se realice de forma algo más fluida e intuitiva
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    // Recalculamos el tamaño original de la 'ventana' de nuestro UIScrollView
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    
    // Modificamos el scroll de la 'ventana' de nuestro UIScrollView con el tamaño original
    [[self scrollView] setContentInset:edgeInsets];
    
    // Modificamos el scroll de la 'ventana' de nuestro UIScrollView con el tamaño original
    [[self scrollView] setScrollIndicatorInsets:edgeInsets];
    
    
    [UIView commitAnimations];
}

# pragma mark - Pinchar fuera del input
- (void) scrollViewPulsado
{
    [[self view] endEditing:YES];
}

# pragma mark - Utilities
+ (UIImage *)rotateImage:(UIImage *)image withRotationType:(rotationType)rotation
{
    CGImageRef imageRef = [image CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaNoneSkipLast;
    
    CGContextRef bitmap;
    
    bitmap = CGBitmapContextCreate(NULL, image.size.height, image.size.width, CGImageGetBitsPerComponent(imageRef), 4 * image.size.height/*CGImageGetBytesPerRow(imageRef)*/, colorSpaceInfo, alphaInfo);
    CGColorSpaceRelease(colorSpaceInfo);
    
    if (rotation == rotateLeft) {
        CGContextTranslateCTM (bitmap, image.size.height, 0);
        CGContextRotateCTM (bitmap, M_PI/2 /*radians(90)*/);
    }
    else {
        CGContextTranslateCTM (bitmap, 0, image.size.width);
        CGContextRotateCTM (bitmap, - (M_PI/2) /*radians(-90)*/);
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    CGContextRelease(bitmap);
    return result;
}

# pragma mark - Actions
- (IBAction)pickAvatarButtonPressed:(id)sender
{
    // crear y presentar el ImagePickerController
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)updateButtonPressed:(id)sender
{
    if ([[[self newpassTextField] text] isEqualToString:[[self confirmNewpassTextField] text]]) {
        [SVProgressHUD show];

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
        int selectedSegmentIndex= [[self sexSegmentedControl] selectedSegmentIndex] || 0;
    
        [APIProvider updateUser:[[appDelegate currentUser] email]
                       username:[[self usernameTextField] text]
                           name:[[self nameTextField] text]
                            url:[[self urlTextField] text]
                            sex:[[self sexSegmentedControl] titleForSegmentAtIndex:selectedSegmentIndex]
                 withCompletion:^{
                     [[appDelegate currentUser] setUserName:[[self usernameTextField] text]];
                     [[appDelegate currentUser] setName:[[self nameTextField] text]];
                     [[appDelegate currentUser] setUrl:[[self urlTextField] text]];
                     
                     // guardar currentUser en nsuserdefaults
                     NSData *currentUserData = [NSKeyedArchiver archivedDataWithRootObject:[appDelegate currentUser]];
                     [[NSUserDefaults standardUserDefaults] setObject:currentUserData
                                                               forKey:DEEMELO_CURRENT_USER_DATA_PREF_KEY];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                     NSNotification *notice     = [NSNotification notificationWithName:UserUpdatedNotification
                                                                                object:self];
                     [[NSNotificationCenter defaultCenter] postNotification:notice];
                     
                     if ([[[self newpassTextField] text] length] > 0) {                         
                         [APIProvider updateUser:[[appDelegate currentUser] email]
                                    withPassword:[[self newpassTextField] text]
                                  withCompletion:^{
                                      //NSLog(@"password success");
                                      NSNotification *notice = [NSNotification notificationWithName:UserUpdatedNotification object:self];
                                      [[NSNotificationCenter defaultCenter] postNotification:notice];
                                      
                                      [[self navigationController] popViewControllerAnimated:YES];
                                      [SVProgressHUD dismiss];
                                  }
                                       withError:^(NSString *error) {
                                           
                                           NSLog(@"password error %@", error);
                                           [SVProgressHUD dismiss];
                                       }];
                     } else {
                         NSNotification *notice = [NSNotification notificationWithName:UserUpdatedNotification object:self];
                         [[NSNotificationCenter defaultCenter] postNotification:notice];

                         [[self navigationController] popViewControllerAnimated:YES];
                         [SVProgressHUD dismiss];
                     }
                 }
                      withError:^(NSString *errorMessage) {
                          [SVProgressHUD dismiss];
                      }];
    } else {
        [[[self newpassTextField] layer] setCornerRadius:7.0f];
        [[[self newpassTextField] layer] setBorderColor:[UIColor colorWithRed:255./255 green:1./255 blue:1./255 alpha:1].CGColor];
        [[[self newpassTextField] layer] setBorderWidth:2];
        [[[self newpassTextField] layer] setMasksToBounds:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Nueva contraseña no coindice con la confirmación"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // sacar imagen del info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // corregir la rotación de la imagen
    switch ([image imageOrientation]) {
            // case 0: la imagen viene ok
        case 1:
            // quitar la metadata
            image = [UIImage imageWithCGImage:[image CGImage]];
            image = [UpdateUserViewController rotateImage:[UpdateUserViewController rotateImage:image withRotationType:rotateLeft] withRotationType:rotateLeft];
            break;
            
        case 2:
            image = [UIImage imageWithCGImage:[image CGImage]];
            image = [UpdateUserViewController rotateImage:image withRotationType:rotateLeft];
            break;
            
        case 3:
            image = [UIImage imageWithCGImage:[image CGImage]];
            image = [UpdateUserViewController rotateImage:image withRotationType:rotateRight];
            break;
            
        default:
            break;
    }
    
    // sacar el image picker de la pantalla
    UIViewController *presentingVC = [picker presentingViewController];
    [presentingVC dismissViewControllerAnimated:YES completion:^{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [SVProgressHUD show];

        [APIProvider updateUser:[[appDelegate currentUser] email]
                     withAvatar:image
                 withCompletion:^{
                     // Cargo el perfil del usuario logeado
                     [APIProvider getProfileWithEmail:[[appDelegate currentUser] email]
                                       withCompletion:^(User *profile) {
                                           [[appDelegate currentUser] setRouteThumbnail:[profile routeThumbnail]];
                                           
                                           // guardar currentUser en nsuserdefaults
                                           NSData *currentUserData = [NSKeyedArchiver archivedDataWithRootObject:[appDelegate currentUser]];
                                           [[NSUserDefaults standardUserDefaults] setObject:currentUserData
                                                                                     forKey:DEEMELO_CURRENT_USER_DATA_PREF_KEY];
                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                           
                                           // Seteo en la vista el avatar del usuario
                                           [[self avatarImageView] setImageWithURL:[NSURL URLWithString:[[appDelegate currentUser] routeThumbnail]]
                                                                  placeholderImage:[UIImage imageNamed:@"avatar.png"]];
                                           
                                           NSNotification *notice = [NSNotification notificationWithName:UserUpdatedNotification
                                                                                                  object:self];
                                           [[NSNotificationCenter defaultCenter] postNotification:notice];
                                           
                                           [SVProgressHUD dismiss];
                                       }
                                            withError:^{
                                                [SVProgressHUD dismiss];
                                            }];
                 }
                      withError:^{
                          [SVProgressHUD dismiss];
                      }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[picker presentingViewController] dismissViewControllerAnimated:YES
                                                          completion:^{
                                                              //NSLog(@"Usuario cancela carga de imagen");
                                                          }];
    
}

# pragma mark - Button/Label style

-(void) setButtonStyle:(UIButton *)button andRadius:(CGFloat)radius andWidth:(CGFloat)width andColor:(UIColor*)color  {
    [button.layer setCornerRadius:radius];
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = width;
    button.layer.masksToBounds = TRUE;
}

# pragma mark - logout methods
- (void)logOutButtonTapped:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                 message:@"¿Estás seguro que deseas salir?"
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:@"No", @"Sí", nil];
    [av setAlertViewStyle:UIAlertViewStyleDefault];
    [av show];
}

#pragma mark - métodos para uialertviewdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // si clickee sí, entonces hacer logout
    if (buttonIndex == 1) {
        
        // si hay sesión de facebook abierta, entonces hay que cerrarla
        if (FBSession.activeSession.isOpen) {
            [[FBSession activeSession] closeAndClearTokenInformation];
            [[FBSession activeSession] close];
            [FBSession setActiveSession:nil];
        }
        
        // limpiar currentUser en nsuserdefaults
        [[NSUserDefaults standardUserDefaults] setObject:nil
                                                  forKey:DEEMELO_CURRENT_USER_DATA_PREF_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
        [sharedApp setCurrentUser:nil];
        [sharedApp setNewRootControllerWithSB:@"Main" andIdentifier:@"main"];
    }
}

@end
