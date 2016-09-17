//
//  ItemDetailViewController.h
//  Deemelo
//
//  Created by Cesar Ortiz on 29-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBarButtonItems.h"
#import "ImageDetail.h"
#import <QuartzCore/CALayer.h>
#import "AppDelegate.h"

@interface ItemDetailViewController : UIViewController <UIAlertViewDelegate, UINavigationBarDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) IBOutlet ImageDetail *objectDetail;

@property (nonatomic) Product *pictureDetails;
@property (nonatomic) Store   *itemStore;

@property (weak, nonatomic) UIStoryboard *myStoryboard;

@property (weak, nonatomic) id backViewController;

@property (weak, nonatomic) IBOutlet UIButton *wantButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

////////////////////////////////////
// Contenedor de la imagen grande //
@property (weak, nonatomic) IBOutlet UIView *imageViewContainer;

// Imagen grande
@property (weak, nonatomic) IBOutlet UIImageView *imageItem;


/////////////////////////////////////////
// Contenedor para los datos del owner //
@property (weak, nonatomic) IBOutlet UIView *ownerViewContainer;

@property (nonatomic, weak) IBOutlet UIView *avatarImageContainerView;

// Avatar del usuario dueño de la prenda
@property (weak, nonatomic) IBOutlet UIImageView *userThumbnail;

// Nombre del usuario dueño de la prenda
@property (weak, nonatomic) IBOutlet UIButton *authorButton;

// Contenedor para boton reportar
@property (weak, nonatomic) IBOutlet UIView *reportViewContainer;

// Boton reportar
@property (weak, nonatomic) IBOutlet UIButton *reportButton;


////////////////////////////////////////
// Contenedor para datos de la prenda //
@property (weak, nonatomic) IBOutlet UIView *structureDataViewContainer;

// Contenedor para categoria de la prenda
@property (weak, nonatomic) IBOutlet UIView *categoryViewContainer;

// Data de la prenda, premite saber la categoria a la que se encuentra asociada
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

// Contenedor para tienda de la prenda
@property (weak, nonatomic) IBOutlet UIView *storeViewContainer;

// Data de la prenda, premite saber la tienda donde se puede encontrar
@property (weak, nonatomic) IBOutlet UIButton *storeButton;


////////////////////////////
// Contenedor para social //
@property (weak, nonatomic) IBOutlet UIView *socialViewContainer;

// Contenedor para crear un nuevo comentarios
@property (weak, nonatomic) IBOutlet UIView *commentViewContainer;

// Input para escribir un nuevo comentario
@property (weak, nonatomic) IBOutlet UITextField *comentaryTextField;

// Boton para enviar comentario
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

// Tabla con los comentarios en la prenda
@property (weak, nonatomic) IBOutlet UITableView *comentaryTableView;

// Lista con comentarios en la prenda
@property (strong, nonatomic) NSMutableArray *comments;


//////////////////////////////////////////////////////
// Contenedor para productos similares de la tienda //
@property (weak, nonatomic) IBOutlet UIView *anotherViewContainer;

// ScrollView para otros productos
@property (weak, nonatomic) IBOutlet UIImageView *anotherProduct0ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *anotherProduct1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *anotherProduct2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *anotherProduct3ImageView;

@property (nonatomic, copy) NSString *commentIdToDelete;

@property (nonatomic) bool want_loaded;
@property (nonatomic) bool details_loaded;
@property (nonatomic) bool another_loaded;
@property (nonatomic) bool comments_loaded;

- (IBAction)iWantButtonPressed:(id)sender;
- (IBAction)shareButtonPressed:(id)sender;
- (IBAction)authorButtonPressed:(id)sender;
- (IBAction)storeButtonPressed:(id)sender;
- (IBAction)reportButtonPressed:(id)sender;

// borrar comentario
- (void)deleteCommentButtonPressed:(id)sender
                       atIndexPath:(NSIndexPath *)indexPath;

// Para ocultar el teclado al pinchar fuera
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)commentButtonPressed:(id)sender;

@end
