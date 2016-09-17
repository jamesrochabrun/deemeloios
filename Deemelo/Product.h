//
//  Product.h
//  Deemelo
//
//  Created by Pablo Branchi on 6/4/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

//
// http://deemelo.com/?page_id=12&op=upload&email=email&prenda=prenda&tienda=tienda&file=file
// email = correo del usuario.
// prenda = nombre de la categoría de la prenda.
// tienda = nombre simple de la tienda.
// file =
//
// File tiene que ser del tipo: $_FILES['file'], donde yo puedo extraer:
//
// $_FILES['file'][name] = nombre de la imagen,
// $_FILES['file']["type"] = tipo de imagen,
// $_FILES['file']["size"] = tamaño de la imagen,
// $_FILES['file']["tmp_name"] = carpeta temporal.
//
@property (copy, nonatomic) NSString *role;

@property (copy, nonatomic) NSString *userEmail;
@property (copy, nonatomic) NSString *categoryName;
@property (copy, nonatomic) NSString *storeName;
@property (strong, nonatomic) UIImage *image;


// Detalles del producto
// http://deemelo.com/?page_id=12&op=getpostimage&id=1
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *storeId;
@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *emailfriend;
@property (strong, nonatomic) NSString *ownerId;
@property (strong, nonatomic) NSString *ownerName;
//@property (strong, nonatomic) NSString *categoryName;
//@property (strong, nonatomic) NSString *storeName;
@property (strong, nonatomic) NSString *commentCount;
@property (strong, nonatomic) NSString *images;
@property (strong, nonatomic) NSString *ruta_thumbnail;


// Otros productos en tienda
// http://deemelo.com/?page_id=12&op=otrosprotienda&post_id=1&tienda=AcidLabs
@property (strong, nonatomic) NSString *productId;
//@property (strong, nonatomic) NSString *ownerName;
//@property (strong, nonatomic) NSString *images;

@end
