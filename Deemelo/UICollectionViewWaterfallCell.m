//
//  UICollectionViewWaterfallCell.m
//  Demo
//
//  Created by Nelson on 12/11/27.
//  Copyright (c) 2012年 Nelson. All rights reserved.
//

#import "UICollectionViewWaterfallCell.h"

@implementation UICollectionViewWaterfallCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // agregamos una sombra a la celda
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 3.0f;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.4f;
    
//    // formatear selected background view
//    UIView *backgroundView = [[UIView alloc]initWithFrame:self.bounds];
//    backgroundView.layer.borderColor = [[UIColor colorWithRed:0.529 green:0.808 blue:0.922 alpha:1] CGColor];
//    backgroundView.layer.borderWidth = 10.0f;
//    self.selectedBackgroundView = backgroundView;
    
    // formatear la imagen
    [self formatProductImageView];
    
    // formatear el contenedor del avatar
    [self formatAvatarImageContainerView];
}

//- (void)prepareForReuse
//{
//    [super prepareForReuse];
//    
//    NSLog(@"prepareForReuse");
//    
//    // limpiamos la celda
//    [[self nameLabel] setText:nil];
//    [[self productImageView] setImage:nil];
//    [[self avatarImageView] setImage:nil];
//    
////    // limpiamos la data de las imágenes
////    [[self imageDetail] setImageData:nil];
////    [[self imageDetail] setThumbnailData:nil];
////    
////    // formatear la imagen
////    [self formatProductImageView];
////    
////    // formatear el avatar
////    [self formatAvatarImageView];
//}

- (void)formatProductImageView
{
    self.productImageView.layer.borderColor = [[UIColor colorWithRed:109/255 green:103/255 blue:98/255 alpha:0.1] CGColor];
    self.productImageView.layer.borderWidth = 1.0f;
}

- (void)formatAvatarImageContainerView
{
    //self.avatarImageView.layer.cornerRadius = 10.0f;
    
    self.avatarImageContainerView.layer.borderColor = [[UIColor colorWithRed:109/255 green:103/255 blue:98/255 alpha:0.1] CGColor];
    self.avatarImageContainerView.layer.borderWidth = 1.0f;
    
    self.avatarImageContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.avatarImageContainerView.layer.shadowRadius = 2.0f;
    self.avatarImageContainerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.avatarImageContainerView.layer.shadowOpacity = 0.4f;
}

@end
