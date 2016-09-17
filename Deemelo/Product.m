//
//  Product.m
//  Deemelo
//
//  Created by Pablo Branchi on 6/4/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "Product.h"

@implementation Product

- (NSString *)description
{
    return [NSString stringWithFormat:@"< Product: email: %@, categoría: %@, tienda: %@, imagen: %@ >", _userEmail, _categoryName, _storeName, _image];
}

@end
