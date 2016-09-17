//
//  ItemDetailViewController.m
//  Deemelo
//
//  Created by Cesar Ortiz on 29-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "ItemDetailViewController.h"

#import "Constants.h"
#import "ProfileViewController.h"
#import "StoreProfileViewController.h"
#import "CommentTableViewCell.h"

#define LOQUIERO @"Lo quiero"
#define NOLOQUIERO @"No lo quiero"

@implementation ItemDetailViewController

// NOTA: Dado que este vista hace varios request a la API, estos llamados se encadenaron uno tras otro.
//       Por esto solo se debe llamar a loadPictureDetails el cual en caso de exito va a intentar cargar
//       otros productos de la tienda (loadAnotherProducts), en caso de error, dado que no se tiene la tienda
//       va a cargar directamente los comentario (loadComments). Por su parte loadAnotherProducts carga los
//       comentario (loadComments). En tanto que loadComments, solo carga los comentario, esta funcion ademas
//       se utiliza para recargar comentarios.
//       EJ:
//              loadPictureDetails() ->
//                  success->
//                      loadAnotherProducts() ->
//                          success->
//                              loadComments()
//                          error->
//                              loadComments()
//                  error->
//                      loadComments()

//@synthesize objectDetail, imageItem, userThumbnail, authorButton, categoryLabel, storeButton, comentaryScroll;
@synthesize wantButton, shareButton, sendButton, reportButton, comentaryTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD show];
    
    [[self navigationItem] setTitleView:[CustomBarButtonItems titleView:[[self navigationController] navigationBar] view:[self view]]];
    
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"CommentTableViewCell" bundle:nil];
    
    // Register this NIB which contains the cell
    [[self comentaryTableView] registerNib:nib forCellReuseIdentifier:@"CommentTableViewCell"];
    
    AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
    [self setObjectDetail:[sharedApp objectDetail]];
    
    // limpiar objectdetail (nos quedamos sólo con el id, lo de más lo cargaremos de nuevo)
    [[self objectDetail] setAuthor:nil];
    [[self objectDetail] setEmailfriend:nil];
    [[self objectDetail] setImageSizeH:PICTURE_COLLECTION_ITEM_WIDTH];
    [[self objectDetail] setRuta_thumbnail:nil];
    
    // Seteo el borde del botón enviar
    [self setButtonStyle:sendButton andRadius:3.0f andWidth:1 andColor:[UIColor grayColor]];
    
    // Seteo el borde del botón lo quiero
    [self setButtonStyle:wantButton andRadius:3.0f andWidth:0 andColor:[UIColor whiteColor]];
    
    // Seteo el borde del botón compartir
    [self setButtonStyle:shareButton andRadius:3.0f andWidth:0 andColor:[UIColor whiteColor]];
    
    // Seteo el borde del contenedor de comentario
    comentaryTextField.layer.cornerRadius = 3.0f;
    comentaryTextField.layer.borderColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header.png"]].CGColor;
    comentaryTextField.layer.borderWidth = 1;
    comentaryTextField.layer.masksToBounds = TRUE;
    
    // Deshabilito el botón para ver al dueño de la imagen hasta recibir la imagen del producto
    [[self authorButton] setHidden:YES];
    [[self authorButton] setEnabled:NO];
    
    // Deshabilito el boton lo-quiero/no-lo-quiero hasta saber la posicion del usuario respecto de la prenda
    [[self wantButton] setEnabled:NO];
    
    // Deshabilito el botón para compartir hasta recibir la imagen del producto
    [[self shareButton] setEnabled:NO];
    
    // Deshabilito oculto el botón para reportar hasta recibir la imagen del producto
    [[self reportButton] setEnabled:NO];
    [[self reportButton] setHidden:YES];
    
    // Me inscribo en el NSNotificationCenter para saber cuando aparece el teclado
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAppears:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    // Me inscribo en el NSNotificationCenter para saber cuando desaparece el teclado
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDisappears:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // Calculo nueva altura del contenedor y por ende de la imagen grande
    [self adjustProductImageViewSize];
    
    // Cambio el constraint de altura del contenedor con los comentarios
    for(NSLayoutConstraint *constraint in [[self socialViewContainer] constraints])
    {
        if([constraint firstAttribute] == NSLayoutAttributeHeight)
        {
            // El origin de la tabla es el espacio que esta definido para los otros componentes vale decir la altura que estos ocupan. A esto le agrego un delta por cada comentario (igual al alto de una columan de la tabla)
            float height = [[self comentaryTableView] frame].origin.y + [[self comentaryTableView] rowHeight] * [[self comments] count];
            
            [constraint setConstant: height];
        }
    }
    
    // Seteo el borde del contenedor de la imagen grande
    self.imageViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageViewContainer.layer.shadowRadius = 3.0f;
    self.imageViewContainer.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.imageViewContainer.layer.shadowOpacity = 0.4f;
    
    // Seteo el borde del contenedor del owner
    self.ownerViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.ownerViewContainer.layer.shadowRadius = 3.0f;
    self.ownerViewContainer.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.ownerViewContainer.layer.shadowOpacity = 0.4f;
    
    // Seteo el borde del contenedor del avatar del owner
    [[self avatarImageContainerView] setHidden:YES];
    
    self.avatarImageContainerView.layer.borderColor = [[UIColor colorWithRed:109/255 green:103/255 blue:98/255 alpha:0.1] CGColor];
    self.avatarImageContainerView.layer.borderWidth = 1.0f;
    
    self.avatarImageContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.avatarImageContainerView.layer.shadowRadius = 2.0f;
    self.avatarImageContainerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.avatarImageContainerView.layer.shadowOpacity = 0.4f;
    
    // Seteo el borde del contenedor de la categoria y de la tienda
    self.structureDataViewContainer.layer.cornerRadius = 3.0f;
    self.structureDataViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.structureDataViewContainer.layer.shadowRadius = 3.0f;
    self.structureDataViewContainer.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.structureDataViewContainer.layer.shadowOpacity = 0.2f;
    
    // Seteo el borde del contenedor de otros productos en la tienda
    self.anotherViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.anotherViewContainer.layer.shadowRadius = 2.0f;
    self.anotherViewContainer.layer.shadowOffset = CGSizeMake(-1.0f, 1.0f);
    self.anotherViewContainer.layer.shadowOpacity = 0.2f;
    
    // Agrego handler para ocultar teclado al pinchar fuera (sobre el scrollview)
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [tapRecognizer setCancelsTouchesInView:NO];
    [[self view] addGestureRecognizer:tapRecognizer];
    
    // agregar el botón "volver" al navbar
    UIImage  *backImage  = [UIImage imageNamed:@"back.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBounds:CGRectMake( 0, 0, [backImage size].width, [backImage size].height)];
    [backButton setImage:backImage forState:UIControlStateNormal];
    
    [backButton addTarget:self
                   action:@selector(backFromCategoryImages:)
         forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [[self navigationItem] setLeftBarButtonItem:backButtonItem];
    
    // Limpio el texto que muestra el dueño de la imagen
    [[self authorButton] setTitle:@"" forState:UIControlStateNormal];
    
    // Limpio el texto que muestra la categoria
    [[self categoryLabel] setText:@""];
    
    // Limpio el texto que muestra la tienda
    [[self storeButton]  setTitle:@"" forState:UIControlStateNormal];
    
    // Por defecto asumo que no hay otras imagenes de la tienda que mostrar, en caso contrario al cargar la coleccion se debe mostrar
    [[self anotherViewContainer] setHidden:YES];
    
    // Desabilito el scrollView para que al modificar los constraint no pasen cosas raras, por tanto no de debe quitar
    [[self scrollView] setScrollEnabled:NO];
    
    [self loadPictureDetails]; // LOAD DATA
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Muevo el scroll al tope
    // Con esto evito que se den problemas al volver habiendo dejado el scroll en un punto distinto del (0, 0)
    [[self scrollView] setContentOffset:CGPointZero animated:YES];
}

# pragma mark - Button/Label style

- (void)adjustProductImageViewSize
{
    float heightOriginalCell = [[self objectDetail] imageSizeH];
    float widthOriginalCell = PICTURE_COLLECTION_ITEM_WIDTH;
    
    float height = [[self imageItem] frame].size.width * heightOriginalCell / widthOriginalCell;
    
    // Cambio el constraint de altura del contenedor con la imagen grande
    for(NSLayoutConstraint *constraint in [[self imageViewContainer] constraints])
    {
        if([constraint firstAttribute] == NSLayoutAttributeHeight)
        {
            [constraint setConstant: height];
        }
    }
}

- (void)setButtonStyle:(UIButton *)button andRadius:(CGFloat)radius andWidth:(CGFloat)width andColor:(UIColor*)color
{
    [button.layer setCornerRadius:radius];
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = width;
    button.layer.masksToBounds = TRUE;
}

- (void)setLabelStyle:(UILabel *)label andRadius:(CGFloat)radius andWidth:(CGFloat)width andColor:(UIColor*)color
{
    [label.layer setCornerRadius:radius];
    label.layer.borderColor = color.CGColor;
    label.layer.borderWidth = width;
    label.layer.masksToBounds = TRUE;
}

# pragma mark - Keyboard

- (void) keyboardAppears:(NSNotification *)notice
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
    float ycoordinate = [[self socialViewContainer] frame].origin.y + [[self comentaryTableView] frame].origin.y - kbSize.height + tabBarHeight;
    CGPoint scrollPoint = CGPointMake(0.0, ycoordinate);
    
    // Scroll al input para hacerlo visible
    [[self scrollView] setContentOffset:scrollPoint animated:YES];
}

- (void) keyboardDisappears:(NSNotification *)notice
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

# pragma mark - Actions

// Acction para volver a la pantalla anterior
- (void)backFromCategoryImages:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

// Accion para decir que quiero/noQuiero una prenda
- (IBAction)iWantButtonPressed:(id)sender
{
    // Deshabilito el boton para que no lo pinchen mas de una vez seguido
    [[self wantButton] setEnabled:NO];
    
    [SVProgressHUD show];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([[[[self wantButton] titleLabel] text] isEqualToString:LOQUIERO]) {
        [APIProvider iWantPictureWithId:[[self objectDetail] idImage]
                                  email:[[appDelegate currentUser] email]
                         withCompletion:^(BOOL successfully) {
                             // Logre querer una prenda?
                             if (successfully) {
                                 [[self wantButton] setTitle:NOLOQUIERO forState:UIControlStateNormal];
                                 
                                 NSNotification *notice = [NSNotification notificationWithName:IWantPictureNotification
                                                                                        object:self
                                                                                      userInfo:nil];
                                 [[NSNotificationCenter defaultCenter] postNotification:notice];
                             }
                             
                             [SVProgressHUD dismiss];
                             
                             // habilito el boton para que lo puedan volver a pinchar
                             [[self wantButton] setEnabled:YES];
                         }
                              withError:^(NSString *message){
                                  [SVProgressHUD dismiss];
                                  
                                  // habilito el boton para que lo puedan volver a pinchar
                                  [[self wantButton] setEnabled:YES];
                              }];
    } else {
        [APIProvider notWantPictureWithId:[[self objectDetail] idImage]
                                    email:[[appDelegate currentUser] email]
                           withCompletion:^(BOOL successfully) {
                               // Logre dejar de querer una prenda?
                               if (successfully) {
                                   [[self wantButton] setTitle:LOQUIERO forState:UIControlStateNormal];
                                   
                                   NSNotification *notice = [NSNotification notificationWithName:NotWantPictureNotification
                                                                                          object:self
                                                                                        userInfo:nil];
                                   [[NSNotificationCenter defaultCenter] postNotification:notice];
                               }
                               
                               [SVProgressHUD dismiss];
                               
                               // habilito el boton para que lo puedan volver a pinchar
                               [[self wantButton] setEnabled:YES];
                           }
                                withError:^(NSString *message){
                                    [SVProgressHUD dismiss];
                                    
                                    // habilito el boton para que lo puedan volver a pinchar
                                    [[self wantButton] setEnabled:YES];
                                }];
    }
}

- (IBAction)shareButtonPressed:(id)sender
{
    // Deshabilito el boton para que no lo pinchen mas de una vez seguido
    [[self shareButton] setEnabled:NO];
    
    // configurar texto a compartir
    NSString *shareText = [NSString stringWithFormat:@"#%@ #deemelo", [[self pictureDetails] categoryName]];
    
    NSString *storeName = [[self pictureDetails] storeName];
    if (storeName) {
        NSArray *words = [storeName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *storeNameWithoutWhitespace = [words componentsJoinedByString:@""];
        shareText = [NSString stringWithFormat:@"%@ #%@", shareText, storeNameWithoutWhitespace];
    }
    
    // configurar url a compartir
    NSURL *shareURL = [NSURL URLWithString:APPLE_APPSTORE_APP_URL];
    
    // configurar imagen a compartir
    UIImage *shareImage = [[self imageItem] image];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[shareText,
                                                              shareURL,
                                                              shareImage]
                                      applicationActivities:nil];
    
    [activityViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [activityViewController setExcludedActivityTypes:@[UIActivityTypePostToWeibo,
                                                       UIActivityTypeAssignToContact,
                                                       UIActivityTypeSaveToCameraRoll,
                                                       UIActivityTypePrint,
                                                       UIActivityTypeCopyToPasteboard,
                                                       UIActivityTypeMessage]];
    
    [self presentViewController:activityViewController animated:YES completion:^{
        [[self shareButton] setEnabled:YES];
    }];
}

- (IBAction)authorButtonPressed:(id)sender
{
    // Cargo una referencia a la vista del Storyborad que muestra un perfil de usuario
    ProfileViewController *profileViewController = [[self myStoryboard] instantiateViewControllerWithIdentifier:@"profileViewController"];
    
    //NSLog(@"%@", [self myStoryboard]);
    
    // A la vista del perfil le indico que email debe utilizar para cargarse
    [profileViewController setCurrentEmail:[[self objectDetail] emailfriend]];
    
    // Muestro la prenda en la vista previamente cargada
    [[self navigationController] pushViewController:profileViewController animated:YES];
}

- (IBAction)storeButtonPressed:(id)sender
{
    // si la prenda no tiene storeId asociado, salir
    if ((![[self pictureDetails] storeId])) {
        return;
    }
    
    // cargar detalle de la tienda
    [SVProgressHUD show];
    int storeId = [[[self pictureDetails] storeId] intValue];
    
    if ([self itemStore]) {
        // mostrar el perfil de la tienda
        StoreProfileViewController *storeProfileVC = [[self myStoryboard] instantiateViewControllerWithIdentifier:@"storeProfile"];
        
        [storeProfileVC setSelectedStore:[self itemStore]];
        
        [[self navigationController] pushViewController:storeProfileVC animated:YES];
    } else {
        [APIProvider getStoreDetailFromStoreID:storeId
                                   withSuccess:^(Store *store) {
                                       [self setItemStore:store];
                                       
                                       // mostrar el perfil de la tienda
                                       StoreProfileViewController *storeProfileVC = [[self myStoryboard] instantiateViewControllerWithIdentifier:@"storeProfile"];
                                       
                                       [storeProfileVC setSelectedStore:store];
                                       
                                       [[self navigationController] pushViewController:storeProfileVC animated:YES];
                                       
                                       //NSLog(@"Cargó el detalle de la tienda");
                                       
                                       // [SVProgressHUD dismiss];
                                   }
                                       failure:^{
                                           //NSLog(@"Error al cargar el detalle de la tienda");
                                           
                                           [SVProgressHUD dismiss];
                                       }];
    }
}

- (IBAction)reportButtonPressed:(id)sender
{
    AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
    
    if ( [[[self objectDetail] emailfriend] isEqualToString:[[sharedApp currentUser] email]] ) {
        
        // comenzar el flujo para borrar el producto
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"¿Eliminar prenda?"
                                                     message:@"Confirma si estás seguro que quieres eliminar esta prenda."
                                                    delegate:self
                                           cancelButtonTitle:@"Cancelar"
                                           otherButtonTitles:ITEM_DETAIL_DELETE_CONFIRMATION_BUTTON_TITLE, nil];
        [av setAlertViewStyle:UIAlertViewStyleDefault];
        [av show];
        
    } else {
        
        // reportar producto
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"¿Imagen inapropiada?"
                                                     message:@"Cuéntamos por qué estás denunciando esta imagen:"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancelar"
                                           otherButtonTitles:ITEM_DETAIL_REPORT_CONFIRMATION_BUTTON_TITLE, nil];
        [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [av show];
        
    }
}

// Accion para ocultar el teclado al pinchar fuera del texfield
- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
}

// Accion para crear un nuevo comentario
- (IBAction)commentButtonPressed:(id)sender {
    // Se ingreso algun comentario?
    if ([[[self comentaryTextField] text] length] > 0) {
        // Deshabilito el boton para que no lo pinchen mas de una vez seguido
        [[self sendButton] setEnabled:NO];
        
        [SVProgressHUD show];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [APIProvider createComment:[[self comentaryTextField] text]
                        forPicture:[[self objectDetail] idImage]
                 commentAuthorName:[[appDelegate currentUser] name]
                commentAuthorEmail:[[appDelegate currentUser] email]
                    withCompletion:^{
                        [[self comentaryTextField] setText:@""];
                        
                        // Actualizo lista de comentarios de la prenda
                        [self loadComments];
                        
                        // NOTA: El dismis se lo dejo al cargar comentarios
                        // [SVProgressHUD dismiss];
                        
                        // habilito el boton para que lo puedan volver a pinchar
                        [[self sendButton] setEnabled:YES];
                    }
                         withError:^(NSString *errorMessage) {
                             // ACA HAY QUE UTILIZAR EL MENSAJE DE LA API Y MOSTRARSELO AL USUARIO
                             
                             [SVProgressHUD dismiss];
                             
                             // habilito el boton para que lo puedan volver a pinchar
                             [[self sendButton] setEnabled:YES];
                         }];
    }
}

- (void)deleteCommentButtonPressed:(id)sender
                       atIndexPath:(NSIndexPath *)indexPath
{
    // comenzar el flujo para borrar el comentario
    Comment *comment = [[self comments] objectAtIndex:[indexPath row]];
    [self setCommentIdToDelete:[comment comment_ID]];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"¿Borrar comentario?"
                                                 message:@"Confirma si estás seguro que quieres borrar este comentario."
                                                delegate:self
                                       cancelButtonTitle:@"Cancelar"
                                       otherButtonTitles:ITEM_DETAIL_COMMENT_DELETE_CONFIRMATION_BUTTON_TITLE, nil];
    [av setAlertViewStyle:UIAlertViewStyleDefault];
    [av show];
}

#pragma mark - Load Data

// Reviso si el usuario logeado esta siguiendo este perfil
- (void) checkWant
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [APIProvider userWantPictureWithId:[[self objectDetail] idImage]
                                 email:[[appDelegate currentUser] email]
                        withCompletion:^(BOOL want) {
                            if (want) {
                                [[self wantButton] setTitle:NOLOQUIERO forState:UIControlStateNormal];
                            } else {
                                [[self wantButton] setTitle:LOQUIERO forState:UIControlStateNormal];
                            }
                            
                            [[self wantButton] setEnabled:YES];
                            
                            //NSLog(@"Logro saber si el usuario logeado quiere la prenda");
                        }
                             withError:^{
                                 //NSLog(@"No logro saber si el usuario logeado quiere la prenda");
                             }];
}

// Carga los detalles de una imagen
- (void) loadPictureDetails
{
    [APIProvider getPictureDetails:[[self objectDetail] idImage]
                    withCompletion:^(Product *details) {
                        [self setPictureDetails:details];
                        
                        // setear objectdetail
                        [[self objectDetail] setAuthor:[[self pictureDetails] ownerName]];
                        [[self objectDetail] setEmailfriend:[[self pictureDetails] emailfriend]];
                        [[self objectDetail] setRuta_thumbnail:[[self pictureDetails] ruta_thumbnail]];
                        
                        if ([[[self pictureDetails] role] isEqualToString:PICTURE_DETAILS_STORE_ROLE_NAME]) {
                            
                            // si el autor de la imagen tiene rol tienda
                            
                            [[self avatarImageContainerView] setHidden:YES];
                            [[self authorButton] setHidden:YES];
                            
                        } else {
                            
                            // si el autor de la imagen tiene otro rol (ejemplo: usuario)
                            
                            [[self avatarImageContainerView] setHidden:NO];
                            [[self authorButton] setHidden:NO];
                            
                            // setear avatar del creador de la imagen
                            [[self userThumbnail] setImageWithURL:[NSURL URLWithString:[[self objectDetail] ruta_thumbnail]]];
                            
                            // setear nombre del creador de imagen
                            [[self authorButton] setTitle:[[self objectDetail] author] forState:UIControlStateNormal];
                            [[self authorButton] setEnabled:YES];
                            
                        }
                        
                        AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
                        if ( [[[self objectDetail] emailfriend] isEqualToString:[[sharedApp currentUser] email]] ) {
                            // configurar reportbutton para borrar la imagen
                            [reportButton setHidden:NO];
                            [reportButton setImage:[UIImage imageNamed:@"borrar.png"]
                                          forState:UIControlStateNormal];
                        } else {
                            // Configuro botton lo-quiero/no-lo-quiero
                            [self checkWant];// LOAD DATA
                            
                            // configurar reportbutton para denunciar la imagen
                            [reportButton setHidden:NO];
                            [reportButton setImage:[UIImage imageNamed:@"flag_activa.png"]
                                          forState:UIControlStateNormal];
                        }
                        
                        [[self imageItem] setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[details images]]]
                                                placeholderImage:nil
                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *imageLoaded) {
                                                             
                                                             // ajustar tamaño del image view
                                                             float ancho = [imageLoaded size].width;
                                                             float alto = [imageLoaded size].height;
                                                             
                                                             [[self objectDetail] setImageSizeH:(alto / ancho) * PICTURE_COLLECTION_ITEM_WIDTH];
                                                             
                                                             [self adjustProductImageViewSize];
                                                             
                                                             // Seteo la imagen en el UIImageView
                                                             [[self imageItem] setImage:imageLoaded];
                                                             
                                                             // Habilito el botón para compartir
                                                             [[self shareButton] setEnabled:YES];
                                                             
                                                             // Habilito el botón para reportar/borrar
                                                             [[self reportButton] setEnabled:YES];
                                                         }
                                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                             //NSLog(@"Fallo carga foto grande");
                                                         }];
                        
                        
                        
                        
                        
                        [[self categoryLabel] setText:[details categoryName]];
                        [[self storeButton] setTitle:[details storeName] forState:UIControlStateNormal];
                        
                        [self loadAnotherProducts]; // LOAD DATA
                        
                        //NSLog(@"Logro saber los detalles de la prenda");
                    }
                         withError:^(NSString *errorMessage) {
                             //NSLog(@"No logro saber los detalles de la prenda");
                             
                             // NOTA: Como no tengo los detalles del producto solo pueda cargar los comentarios

                             // Cargo comentarios de la prenda
                             [self loadComments];
                         }];
}

// Carga los otros productos en la tienda
- (void) loadAnotherProducts
{
    [APIProvider getAnotherPictures:[[self objectDetail] idImage]
                            inStore:[[self pictureDetails] storeName]
                     withCompletion:^(NSMutableArray *other_products) {
                         
                         if ([other_products count] > 0) {
                             [[self anotherProduct0ImageView] setImageWithURL:[NSURL URLWithString:[(Product *)[other_products objectAtIndex:0] images]]];
                             
                             if ([other_products count] > 1) {
                                 [[self anotherProduct1ImageView] setImageWithURL:[NSURL URLWithString:[(Product *)[other_products objectAtIndex:1] images]]];
                             }
                             
                             if ([other_products count] > 2) {
                                 [[self anotherProduct2ImageView] setImageWithURL:[NSURL URLWithString:[(Product *)[other_products objectAtIndex:2] images]]];
                             }
                             
                             if ([other_products count] > 3) {
                                 [[self anotherProduct3ImageView] setImageWithURL:[NSURL URLWithString:[(Product *)[other_products objectAtIndex:3] images]]];
                             }
                             
                             for(NSLayoutConstraint *constraint in [[self scrollView] constraints])
                             {
                                 if([constraint firstAttribute] == NSLayoutAttributeBottom && [constraint secondItem] == [self socialViewContainer] && [constraint firstItem] == [self anotherViewContainer])
                                 {
                                     [[self scrollView] removeConstraint:constraint];
                                 }
                                 
                                 if([constraint firstAttribute] == NSLayoutAttributeBottom && [constraint firstItem] == [self socialViewContainer] && [constraint secondItem] == [self anotherViewContainer])
                                 {
                                     [[self scrollView] removeConstraint:constraint];
                                 }
                             }
                             
                             for(NSLayoutConstraint *constraint in [[self scrollView] constraints])
                             {
                                 
                                 if([constraint firstAttribute] == NSLayoutAttributeBottom && [constraint secondItem] == [self socialViewContainer])
                                 {
                                     [constraint setConstant:124];
                                 }
                             }
                             
                             [[self scrollView] setScrollEnabled:YES];
                             
                             [[self anotherViewContainer] setHidden:NO];
                         } else {
                             [[self scrollView] setScrollEnabled:YES];
                         }
                         
                         // NOTA: Luego de cargar cargo los comentarios
                         
                         // Cargo comentarios de la prenda
                         [self loadComments];
                     }
                          withError:^(NSString *errorMessage) {
                              [[self scrollView] setScrollEnabled:YES];
                              
                              // NOTA: Luego de cargar cargo los comentarios
                              
                              // Cargo comentarios de la prenda
                              [self loadComments];
                          }];
}

// Funcion para cargar los comentarios de la prenda
- (void)loadComments
{
    [SVProgressHUD show];
    
    [APIProvider getCommentsInto:[[self objectDetail] idImage]
                  withCompletion:^(NSMutableArray *comments) {
                      [self setComments:comments];
                      
                      [[self comentaryTableView] reloadData];
                      
                      for(NSLayoutConstraint *constraint in [[self socialViewContainer] constraints])
                      {
                          if([constraint firstAttribute] == NSLayoutAttributeHeight)
                          {
                              // El origin de la tabla es el espacio que esta definido para los otros componentes vale decir la altura que estos ocupan. A esto le agrego un delta por cada comentario (igual al alto de una columan de la tabla)
                              float height = [[self comentaryTableView] frame].origin.y + [[self comentaryTableView] contentSize].height;
                              
                              [constraint setConstant:height];
                          }
                      }
                      
                      [SVProgressHUD dismiss];
                  }
                       withError:^(NSString *errorMessage) {
                           [SVProgressHUD dismiss];
                       }];
}

#pragma mark - métodos para uialertviewdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // en caso que quiera borrar una foto
    if ([buttonTitle isEqualToString:ITEM_DETAIL_DELETE_CONFIRMATION_BUTTON_TITLE]) {
        
        [SVProgressHUD showWithStatus:@"Eliminando la prenda..."];
        
        [APIProvider deletePictureWithId:[[self objectDetail] idImage]
                                   email:[[appDelegate currentUser] email]
                          withCompletion:^(BOOL successfully) {
                              
                              // Logre borrar la prenda?
                              if (successfully) {
                                  
                                  // reload de la colección de fotos del vc anterior
                                  if ([[self backViewController] isKindOfClass:[PictureCollectionViewController class]]) {
                                      //[backVC performSelector:@selector(refreshCollection)];
                                      [[self backViewController] setCollection:nil];
                                  }
                                  
                                  // volver a la colección de fotos del vc anterior
                                  [[self navigationController] popViewControllerAnimated:YES];
                                  
                                  // refrescar el contador de fotos del perfil del usuario
                                  // refrescar la colección de fotos del perfil del usuario
                                  NSNotification *note = [NSNotification notificationWithName:DeletedPictureNotification
                                                                                       object:self
                                                                                     userInfo:nil];
                                  [[NSNotificationCenter defaultCenter] postNotification:note];
                                  
                                  [SVProgressHUD showSuccessWithStatus:@"Prenda eliminada"];
                                  
                              } else {
                                  
                                  [SVProgressHUD showErrorWithStatus:@"Error al eliminar la prenda"];
                                  
                              }
                              
                          }
                               withError:^{
                                   
                                   [SVProgressHUD showErrorWithStatus:@"Error al eliminar la prenda"];
                                   
                               }];
        
    }
    
    // en caso que quiera reportar una foto
    if ([buttonTitle isEqualToString:ITEM_DETAIL_REPORT_CONFIRMATION_BUTTON_TITLE]) {
        
        // validar string del motivo
        NSString *reason = [[alertView textFieldAtIndex:0] text];
        
        [SVProgressHUD show];
        
        [APIProvider reportPictureWithId:[[self objectDetail] idImage]
                                  reason:reason
                                   email:[[appDelegate currentUser] email]
                          withCompletion:^(BOOL successfully) {
                              
                              // Logre reportar la imagen?
                              if (successfully) {
                                  
                                  // deshabilitar el botón para reportar
                                  [[self reportButton] setEnabled:NO];
                                  
                                  [SVProgressHUD showSuccessWithStatus:@"Imagen reportada"];
                                  
                              } else {
                                  
                                  [SVProgressHUD showErrorWithStatus:@"Error al reportar la imagen"];
                                  
                              }
                              
                          }
                               withError:^{
                                   
                                   [SVProgressHUD showErrorWithStatus:@"Error al reportar la imagen"];
                                   
                               }];
        
    }
    
    // en caso que quiera borrar un comentario
    if ([buttonTitle isEqualToString:ITEM_DETAIL_COMMENT_DELETE_CONFIRMATION_BUTTON_TITLE]) {
        
        [SVProgressHUD showWithStatus:@"Borrando el comentario..."];
        
        [APIProvider deleteCommentWithId:[self commentIdToDelete]
                          withCompletion:^(BOOL successfully) {
                              
                              // Logre borrar la prenda?
                              if (successfully) {
                                  
                                  // recargar los comentarios
                                  [self loadComments];
                                  
                                  [SVProgressHUD showSuccessWithStatus:@"Comentario borrado"];
                                  
                              } else {
                                  
                                  [SVProgressHUD showErrorWithStatus:@"Error al borrar el comentario"];
                                  
                              }
                              
                          }
                               withError:^{
                                   
                                   [SVProgressHUD showErrorWithStatus:@"Error al borrar el comentario"];
                                   
                               }];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self comments] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Obtengo una referencia al comentario que se va a mostrar en la cell
    Comment *comment = [[self comments] objectAtIndex:[indexPath row]];
    
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell"];
    
    // Setear el selected view
    UIView *selectedView = [[UIView alloc] init];
    [selectedView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectedBackgroundView:selectedView];
    
    // Setear botón para borrar comentario
    [cell setController:self];
    [cell setTableView:tableView];
    
    AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
    BOOL pictureIsMine = [[[self objectDetail] emailfriend] isEqualToString:[[sharedApp currentUser] email]];
    BOOL commentIsMine = [[comment comment_author_email] isEqualToString:[[sharedApp currentUser] email]];
    
    if (((pictureIsMine) || (commentIsMine))) {
        [[cell deleteCommentButton] setHidden:NO];
        [[cell deleteCommentButton] setEnabled:YES];
    } else {
        [[cell deleteCommentButton] setHidden:YES];
        [[cell deleteCommentButton] setEnabled:NO];
    }
    
    // Setear las imágenes y los textos
    [[cell nameLabel] setText:[comment comment_author]];
    [[cell commentTextView] setText:[comment comment_content]];
    [[cell avatarImageView] setImageWithURL:[NSURL URLWithString:[comment ruta_thumbnail]]];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [[self comments] objectAtIndex:[indexPath row]];
    
    // Cargo una referencia a la vista del Storyborad que muestra un perfil de usuario
    ProfileViewController *profileViewController = [[self myStoryboard] instantiateViewControllerWithIdentifier:@"profileViewController"];
    
    // A la vista del perfil le indico que email debe utilizar para cargarse
    [profileViewController setCurrentEmail:[comment comment_author_email]];
    
    // Muestro la prenda en la vista previamente cargada
    [[self navigationController] pushViewController:profileViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CommentTableViewCell *cell = (CommentTableViewCell *)[self tableView:tableView
//                                                   cellForRowAtIndexPath:indexPath];
//    
//    CGSize commentTextViewSize = [[cell commentTextView] contentSize];
//    
//    return 43 + commentTextViewSize.height + 16;
    
    Comment *comment = [[self comments] objectAtIndex:[indexPath row]];
    
    CGSize textSize = [[comment comment_content] sizeWithFont:[UIFont systemFontOfSize:13]
                                            constrainedToSize:CGSizeMake(302 -19 -16, 9999)
                                                lineBreakMode:NSLineBreakByWordWrapping];
    
    return 43 + textSize.height + 16;
}

@end
