//
//  PhotoViewController.m
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "PhotoViewController.h"

typedef enum {
    rotateLeft,
    rotateRight
} rotationType;

@implementation PhotoViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:nil tag:2];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"principal_activo.png"]
                      withFinishedUnselectedImage:[UIImage imageNamed:@"principal.png"]];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, 2, 0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [CustomBarButtonItems titleView:self.navigationController.navigationBar view:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods

- (void)takePictureWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:sourceType];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

+ (UIImage *)rotateImage:(UIImage *)image
       withRotationType:(rotationType)rotation
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

- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = IMAGEPICKER_MAX_RESOLUTION; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Tomar Foto"]) {
        [self takePictureWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    if ([buttonTitle isEqualToString:@"Escoger Foto"]) {
        [self takePictureWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    if ([buttonTitle isEqualToString:@"Cancelar"]) {
        // si cancelamos el action sheet, eliminar el nuevo producto que estábamos creando
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setIsAddingNewProduct:NO];
        [appDelegate setANewProduct:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // sacar imagen del info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // corregir la rotación de la imagen
    image = [self scaleAndRotateImage:image];
    
    /*
    switch ([image imageOrientation]) {
        // case 0: la imagen viene ok
        case 1:
            // quitar la metadata
            image = [UIImage imageWithCGImage:[image CGImage]];
            image = [PhotoViewController rotateImage:[PhotoViewController rotateImage:image withRotationType:rotateLeft] withRotationType:rotateLeft];
            break;
            
        case 2:
            image = [UIImage imageWithCGImage:[image CGImage]];
            image = [PhotoViewController rotateImage:image withRotationType:rotateLeft];
            break;
            
        case 3:
            image = [UIImage imageWithCGImage:[image CGImage]];
            image = [PhotoViewController rotateImage:image withRotationType:rotateRight];
            break;
            
        default:
            break;
    }
    */
        
    // crear un nuevo producto y pasarle la imagen
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Product *nProduct = [[Product alloc] init];
    [nProduct setImage:image];
    [nProduct setUserEmail:[[appDelegate currentUser] email]];
    
    // sacar el image picker de la pantalla
    //NSLog(@"\n\nPRESENTING VIEWCONTROLLER: %@\n\n", [picker presentingViewController]);
    //NSLog(@"\n\nnPRESENTED VIEWCONTROLLER TO DISMISS: %@\n\n", [[picker presentingViewController] presentedViewController]);
    UIViewController *presentingVC = [picker presentingViewController];
    [presentingVC dismissViewControllerAnimated:YES completion:^{
        
        // decirle al appdelegate que estamos agregando un nuevo producto
        // y pasarle el producto con la imagen
        [appDelegate setIsAddingNewProduct:YES];
        [appDelegate setANewProduct:nProduct];
        
        // presentar el viewcontroller para escoger categorías
        //[self performSegueWithIdentifier:@"chooseCategory" sender:self];
        
        UIViewController *categoryVC =
            [[presentingVC storyboard] instantiateViewControllerWithIdentifier:@"newProductCategory"];
        [appDelegate setANewProductCategoryController:categoryVC];
        [categoryVC setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [presentingVC presentViewController:categoryVC animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //NSLog(@"\n\nPRESENTING VIEWCONTROLLER: %@\n\n", [picker presentingViewController]);
    //NSLog(@"\n\nnPRESENTED VIEWCONTROLLER TO DISMISS: %@\n\n", [[picker presentingViewController] presentedViewController]);
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:^{
        
        // si cancelamos la toma de imagen, eliminar el nuevo producto que estábamos creando
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setIsAddingNewProduct:NO];
        [appDelegate setANewProduct:nil];
    }];
    
}

@end
