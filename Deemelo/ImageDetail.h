//
//  ImageDetail.h
//  Deemelo
//
//  Created by Manuel Gomez on 23-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageDetail : NSObject

@property (nonatomic) NSString *idImage;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *images;
@property (nonatomic) NSString *ruta_thumbnail;
@property (nonatomic) NSData   *thumbnailData;
@property (nonatomic) NSString *emailfriend;
@property (nonatomic) NSData   *imageData;
@property (nonatomic) CGFloat   imageSizeH;

- (void) loadImageData;

@end
