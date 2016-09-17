//
//  Store.h
//  Deemelo
//
//  Created by Pablo Branchi on 6/7/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Store : NSObject

@property (nonatomic) NSUInteger storeID;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *address;

// OJO: acá estamos usando strings para guardar longitud y latitud, debe ser convertido a DOUBLE y eso va en un cllocationcoordinate2d
@property (copy, nonatomic) NSString *latitude;
@property (copy, nonatomic) NSString *longitude;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *province;
@property (copy, nonatomic) NSString *region;
@property (copy, nonatomic) NSString *country;

// se registra un email para la tienda,
// el que actualmente no es retornado por ningún método del servidor
// pero que es necesario para traer el catálogo de la tienda (!)
@property (copy, nonatomic) NSString *email;

// thumbnail del avatar de la tienda
@property (copy, nonatomic) NSString *ruta_thumbnail;

// los próximos properties son requeridos para mapear error del apiprovider
@property (copy, nonatomic) NSString *status;
@property (copy, nonatomic) NSString *desc;

@end
