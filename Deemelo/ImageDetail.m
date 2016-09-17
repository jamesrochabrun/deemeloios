//
//  ImageDetail.m
//  Deemelo
//
//  Created by Manuel Gomez on 23-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "ImageDetail.h"


@implementation ImageDetail

@synthesize idImage, author, images, ruta_thumbnail, thumbnailData, emailfriend, imageData, imageSizeH;

- (void) loadImageData {   
    NSURL *url = [NSURL URLWithString:self.images];
    self.imageData = [NSData dataWithContentsOfURL:url];
    
    UIImage *img = [UIImage imageWithData:self.imageData];

    CGFloat y = (152 * 100)/ img.size.width;
    self.imageSizeH = (img.size.height * y)/100;
        
   self.thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ruta_thumbnail]];
}

@end
