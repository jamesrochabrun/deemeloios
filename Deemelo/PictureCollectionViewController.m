//
//  PictureCollectionViewController.m
//  Deemelo
//
//  Created by Pablo Branchi on 6/24/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "PictureCollectionViewController.h"
#import "UICollectionViewWaterfallCell.h"

#define CELL_IDENTIFIER @"WaterfallCellPictures"
#define TITLE_BAR @"Fotos"

@implementation PictureCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"PictureCollectionViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setPendingImageViews:[NSMutableArray array]];
    }
    return self;
}

- (void)dealloc
{
    // cancelar todas las image requests pendientes del collection view
    if ([self collection] && [self collectionView]) {
        for (UIImageView *imageView in [self pendingImageViews]) {
            //NSLog(@"DEALLOC DE: %@", imageView);
            [imageView cancelImageRequestOperation];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"UICollectionViewWaterfallCell" bundle:nil];
    
    // Register this NIB which contains the cell
    [[self collectionView] registerNib:nib forCellWithReuseIdentifier:CELL_IDENTIFIER];
    
    // Creo el layout para dos columnas de prendas
    UICollectionViewWaterfallLayout *layout = [[UICollectionViewWaterfallLayout alloc] init];
    
    // Configuracion basica del layout
    layout.delegate = self;
    layout.columnCount = 2;
    layout.itemWidth = PICTURE_COLLECTION_ITEM_WIDTH;
    layout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
    
    // En la UICollectionView utilizo layout de dos columnas
    [[self collectionView] setCollectionViewLayout:layout];
    
    // Configuracion basica del UICollectionView
    [[self collectionView] setDataSource:self];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setShowsVerticalScrollIndicator:YES];
    [[self collectionView] setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    // agregar control para pull to refresh del collectionview
    [self setPullToRefreshView:[[SSPullToRefreshView alloc] initWithScrollView:[self collectionView] delegate:self]];
    
    // agregar infinite scrolling
    [[self collectionView] addInfiniteScrollingWithActionHandler:^{
        
        //NSLog(@"INFINITE SCROLL JUST TRIGGERED!!!!!!!!!!!!");
        // agregar más elementos a la colección
        
        // definir cuántos elementos tiene ahora la colección
        NSUInteger currentCollectionCount = [[self collection] count];
        
        // cargar nuevos elementos desde este offset y agregarlos a la colección
        [self performSelector:@selector(loadMoreCollectionItemsFromOffset:)
                   withObject:[NSNumber numberWithInt:currentCollectionCount]];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // ejecutar el método requerido por el protocolo para cargar la colección
    [self performSelector:@selector(loadCollection)];
}

- (void) handleTapGesture:(UITapGestureRecognizer *)sender
{
    if ([[[self collection] objectAtIndex:sender.view.tag] imageSizeH]) {        
        AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
        
        // Almaceno en el AppDelegate una referencia a la prenda clickeada
        sharedApp.objectDetail = [[self collection] objectAtIndex:sender.view.tag];
        
        // Cargo una referencia a la vista del Storyboard que muestra los datos de una prenda
        ItemDetailViewController *imageDetail = [[ItemDetailViewController alloc] initWithNibName:nil bundle:nil];
        [imageDetail setMyStoryboard:[self myStoryboard]];
        
        // Configuro la referencia a este VC (se usa para volver automáticamente cuando el usuario borra un producto)
        [imageDetail setBackViewController:self];
        
        // Muestro la prenda en la vista previamente cargada
        [[self navigationController] pushViewController:imageDetail animated:YES];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [[self collection] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageDetail *prenda = [[self collection] objectAtIndex:[indexPath item]];
    
    UICollectionViewWaterfallCell *cell =
        (UICollectionViewWaterfallCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                   forIndexPath:indexPath];
    
    [[cell productImageView] setImageWithURL:[NSURL URLWithString:[prenda images]]];
//    // Imagen de la prenda
//    if([prenda imageData]) {
//        
//        //NSLog(@"COLLECTIONVIEW: CELL: cargó la imagen desde el array: %d", [[prenda imageData] length]);
//        [[cell productImageView] setImage:[UIImage imageWithData:[prenda imageData]]];
//        [cell formatProductImageView];
//    } else {
//        
//        UIImageView * __weak weakPendingProductImageView = [cell productImageView];
//        [[self pendingImageViews] addObject:weakPendingProductImageView];
//        
//        //NSLog(@"COLLECTIONVIEW: REQUIERE CARGAR IMAGEN DESDE URL PARA: %@", indexPath);
//        NSLog(@"cargando imagen %@", [prenda images]);
//        NSURLRequest *imageReq = [NSURLRequest requestWithURL:[NSURL URLWithString:[prenda images]]
//                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
//                                              timeoutInterval:60];
//        
//        [[cell productImageView] setImageWithURLRequest:imageReq
//                                       placeholderImage:nil //[UIImage imageNamed:@"pictureplaceholder.png"]
//                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                    
//                                                    //NSLog(@"COLLECTIONVIEW: CELL: cargó la imagen: %@", request);
//                                                    [prenda setImageData:UIImagePNGRepresentation(image)];
//                                                    
//                                                    [[self pendingImageViews] removeObject:weakPendingProductImageView];
//                                                    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
//                                                    //[collectionView reloadData];
//                                                }
//                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                    
//                                                    //NSLog(@"COLLECTIONVIEW: no cargó la imagen: %@", request);
//                                                    [[self pendingImageViews] removeObject:weakPendingProductImageView];
//                                                }];
//    }
    
    [[cell avatarImageView] setImageWithURL:[NSURL URLWithString:[prenda ruta_thumbnail]]];
//    // Avatar del owner
//    if([prenda thumbnailData]) {
//        
//        //NSLog(@"COLLECTIONVIEW: CELL: cargó el avatar desde el array: %d", [[prenda thumbnailData] length]);
//        [[cell avatarImageView] setImage:[UIImage imageWithData:[prenda thumbnailData]]];
//        [cell formatAvatarImageView];
//    } else {
//        
//        UIImageView * __weak weakPendingAvatarImageView = [cell avatarImageView];
//        [[self pendingImageViews] addObject:weakPendingAvatarImageView];
//        
//        //NSLog(@"COLLECTIONVIEW: REQUIERE CARGAR AVATAR DESDE URL PARA: %@", indexPath);
//        NSURLRequest *avatarReq = [NSURLRequest requestWithURL:[NSURL URLWithString:[prenda ruta_thumbnail]]
//                                                   cachePolicy:NSURLRequestReloadIgnoringCacheData
//                                               timeoutInterval:60];
//        
//        [[cell avatarImageView] setImageWithURLRequest:avatarReq
//                                      placeholderImage:nil //[UIImage imageNamed:@"avatar.png"]
//                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                   
//                                                   //NSLog(@"COLLECTIONVIEW: CELL: cargó el avatar: %@", request);
//                                                   if ([UIImagePNGRepresentation(image) length] < 10000) {
//                                                       [prenda setThumbnailData:UIImagePNGRepresentation(image)];
//                                                   } else {
//                                                       image = nil;
//                                                       [prenda setThumbnailData:UIImagePNGRepresentation([UIImage imageNamed:@"avatar.png"])];
//                                                   }
//                                                   [[self pendingImageViews] removeObject:weakPendingAvatarImageView];
//                                               }
//                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                   
//                                                   //NSLog(@"COLLECTIONVIEW: no cargó el avatar: %@", request);
//                                                   [[self pendingImageViews] removeObject:weakPendingAvatarImageView];
//                                               }];
//    }
    
    // Datos del owner
    [[cell nameLabel] setText:[prenda author]];
    
    //[cell.view setClipsToBounds:TRUE];
    [cell setTag:indexPath.row];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [cell addGestureRecognizer:tap];
    
    [cell setImageDetail:[[self collection] objectAtIndex:[indexPath row]]];
    
    return cell;
}

#pragma mark - UICollectionViewWaterfallLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewWaterfallLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageDetail *prenda = [[self collection] objectAtIndex:[indexPath item]];
    
    // si no hay url, devuelve un tamaño "estándar" :)
    if (![prenda images]) {
        return PICTURE_COLLECTION_ITEM_WIDTH + 30;
    }
    
    // si no hay altura calculada, calcularla a partir del nombre de la imagen
    if (![prenda imageSizeH]) {
        
        [prenda setImageSizeH:PICTURE_COLLECTION_ITEM_WIDTH];
        
        // conseguir ancho y alto de la imagen
        NSString *widthString = nil;
        NSString *heightString = nil;
        
        // Create a regular expression with the pattern: Author
        NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@"-(\\d{1,})x(\\d{1,})."
                                                                        options:0
                                                                          error:nil];
        
        // Find matches in the string. The range
        // argument specifies how much of the string to search;
        // in this case, all of it.
        NSArray *matches = [reg matchesInString:[prenda images]
                                        options:0
                                          range:NSMakeRange(0, [[prenda images] length])];
        
        // If there was a match
        if ([matches count] == 1) {
            NSTextCheckingResult *result = [matches objectAtIndex:0];
            
            if ([result numberOfRanges] == 3) {
                
                NSRange widthRange = [result rangeAtIndex:1];
                NSRange heightRange = [result rangeAtIndex:2];
                
                widthString = [[prenda images] substringWithRange:widthRange];
                heightString = [[prenda images] substringWithRange:heightRange];
                
                float ancho = [widthString floatValue];
                float alto = [heightString floatValue];
                
                [prenda setImageSizeH:(alto / ancho) * PICTURE_COLLECTION_ITEM_WIDTH];
            }
        }
    }
    return [prenda imageSizeH] + 30;
}

#pragma mark - SSPullToRefreshView Delegate Methods

- (BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView *)view
{
    return YES;
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    // cancelar todas las image requests pendientes del collection view
    //NSLog(@"REFRESH: Cancelando todas las image requests pendientes del collection view");
    if ([self collection] && [self collectionView]) {
        //NSLog(@"REFRESH: pendingImageViews %d", [[self pendingImageViews] count]);
        for (UIImageView *imageView in [self pendingImageViews]) {
            //NSLog(@"REFRESH: cancelImageRequestOperation %@", imageView);
            [imageView cancelImageRequestOperation];
        }
    }
    
    [self performSelector:@selector(refreshCollection)];
    //NSLog(@"StartLoading");
}

- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view
{
    //NSLog(@"FinishLoading");
}

@end
