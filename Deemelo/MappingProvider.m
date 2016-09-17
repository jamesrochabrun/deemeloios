//
//  MappingProvider.m
//  Deemelo
//
//  Created by Cesar Ortiz on 03-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "MappingProvider.h"
#import "User.h"
#import "ImageDetail.h"
#import "Categories.h"
#import "Store.h"
#import "Summary.h"
#import "TransferObject.h"
#import "Comment.h"
#import "Product.h"
#import "Ranking.h"
#import "Notification.h"

@implementation MappingProvider

+ (RKMapping *)userMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[User class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"url"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"id" : @"idUser",
     @"username": @"userName",
     @"correo": @"email",
     @"nombre": @"name",
     @"descripcion": @"userDescription",
     @"ruta_thumbnail": @"routeThumbnail",
     @"token": @"token"
     }];

    return mapping;
}

+ (RKMapping *)imageMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ImageDetail class]];
    [mapping addAttributeMappingsFromArray:@[@"author", @"images",@"ruta_thumbnail", @"emailfriend"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"id" : @"idImage"
     }];
    
    return mapping;
}

+ (RKMapping *)imageMappingForStoreProfileSearchByProduct
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ImageDetail class]];
    [mapping addAttributeMappingsFromArray:@[@"author", @"images",@"ruta_thumbnail", @"emailfriend"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"post_id" : @"idImage"
     }];
    
    return mapping;
}

+ (RKMapping *)categoriesMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Categories class]];
    [mapping addAttributeMappingsFromArray:@[@"term_id", @"name",@"slug"]];
        
    return mapping;
}

+ (RKMapping *)storesMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Store class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"desc"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"ID": @"storeID",
     @"display_name": @"name",
     @"latitud": @"latitude",
     @"longitud": @"longitude",
     @"direccion": @"address",
     @"email_tienda": @"email",
     @"ruta_thumbnail": @"ruta_thumbnail"
     }];
    
    return mapping;
}

+ (RKMapping *)searchStoresMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Store class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"desc"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"ID": @"storeID",
     @"user_email": @"email",
     @"display_name": @"name"
     }];
    
    return mapping;
}

+ (RKMapping *)searchStoresByProductMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Store class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"desc"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"tienda_id": @"storeID",
     @"nombre": @"name",
     @"latitud": @"latitude",
     @"longitud": @"longitude",
     @"direccion": @"address",
     @"email_tienda": @"email"
     }];
    
    return mapping;
}

+ (RKMapping *)searchUserMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[User class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"url"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"user_email": @"email",
     @"display_name": @"name",
     @"facebook_id": @"facebook_id",
     @"ruta_thumbnail": @"routeThumbnail"
     }];
    
    return mapping;
}

+ (RKMapping *)followMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[User class]];
    [mapping addAttributeMappingsFromArray:@[@"status"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"id" : @"idUser",
     @"email": @"email",
     @"nombre": @"name",
     @"ruta_thumbnail": @"routeThumbnail",
     @"facebook_id": @"facebook_id",
     @"desc": @"errorMessage"
     }];
    
    return mapping;
}

// Maping para el resumen de un perfil de usuario
+ (RKMapping *)summaryMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Summary class]];
    [mapping addAttributeMappingsFromArray:@[@"post_user", @"want", @"likes"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"siguiendo" : @"following",
     @"seguidores" : @"followers"
     }];
    return mapping;
}

+ (RKMapping *)transferObjectMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[TransferObject class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"errorMessage", @"want"]];
    
    [mapping addAttributeMappingsFromDictionary:@{
     @"megusta" : @"like",
     @"count" : @"count"
     }];

    return mapping;
}

+ (RKMapping *)commentMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Comment class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"comment_ID", @"comment_post_ID", @"comment_author", @"comment_author_email", @"comment_author_url", @"comment_author_IP", @"comment_date", @"comment_date_gmt", @"comment_content", @"comment_karma", @"comment_approved", @"comment_agent", @"comment_type", @"comment_parent", @"user_id", @"ruta_thumbnail"]];
    
    return mapping;
}

+ (RKMapping *)productDetailsMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Product class]];
    [mapping addAttributeMappingsFromArray:@[@"emailfriend", @"images", @"ruta_thumbnail"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"role" : @"role",
     @"direccion" : @"address",
     @"ID_tienda" : @"storeId",
     @"ciudad" : @"cityName",
     @"post_author" : @"ownerId",
     @"nombre" : @"ownerName",
     @"prendacat" : @"categoryName",
     @"tiendacat" : @"storeName",
     @"comment_count" : @"commentCount"
     }];
    
    return mapping;
}


+ (RKMapping *)otherProductMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Product class]];
    [mapping addAttributeMappingsFromArray:@[@"images"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"post_id" : @"productId",
     @"author" : @"ownerName"
     }];
    
    return mapping;
}

+ (RKMapping *)rankingMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Ranking class]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"puntos" : @"points",
     @"acumulador" : @"accumulator"
     }];
    
    return mapping;
}

+ (RKMapping *)deleteImageStatusMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[TransferObject class]];
    [mapping addAttributeMappingsFromArray:@[@"status"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"desc" : @"errorMessage"
     }];
    
    return mapping;
}

+ (RKMapping *)notificationMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Notification class]];
    [mapping addAttributeMappingsFromArray:@[@"status", @"desc"]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"id" : @"notificationId",
     @"type" : @"type",
     @"target_id" : @"targetId",
     @"caller_email" : @"callerEmail",
     @"caller_name" : @"callerName",
     @"caller_thumbnail" : @"callerThumbnailURL",
     @"read" : @"read"
     }];
    
    return mapping;
}

@end
