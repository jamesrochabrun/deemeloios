//
//  MappingProvider.h
//  Deemelo
//
//  Created by Cesar Ortiz on 03-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface MappingProvider : NSObject

+ (RKMapping *)userMapping;

+ (RKMapping *)imageMapping;

// Mapping para búsqueda de prendas dentro del perfil de una tienda
// NOTA: es igual a imageMapping, pero los parámetros del request
//       no coinciden con los del mapping por defecto.
+ (RKMapping *)imageMappingForStoreProfileSearchByProduct;

+ (RKMapping *)categoriesMapping;

+ (RKMapping *)storesMapping;

// Mapping para búsqueda de tiendas
// NOTA: Es una tienda, pero los parámetros del request
//       no coinciden con los del mapping por defecto de las tiendas.
+ (RKMapping *)searchStoresMapping;

// Mapping para búsqueda de tiendas por producto
// NOTA: Es una tienda, pero los parámetros del request
//       no coinciden con los del mapping por defecto de las tiendas.
+ (RKMapping *)searchStoresByProductMapping;

// Mapping para búsqueda de usuarios
// NOTA: Basicamente es un usuario, pero los parametros del request
//       no coinciden con los del maping por defecto de los usuarios.
+ (RKMapping *)searchUserMapping;

// Maping para usuarios que se estan me siguen/sigo.
// NOTA: Basicamente es un usuario, pero los parametros del request
//       no coinciden con los del maping por defecto de los usuarios.
+ (RKMapping *)followMapping;

// Maping para el resumen de un perfil de usuario,
// Eventualmente estos datos deberian pertenecer al un usuario.
+ (RKMapping *)summaryMapping;

// Maping para el status asociado a un request a la API,
// Diseñada basicamente para manejar los status que envia la API.
+ (RKMapping *)transferObjectMapping;

// Maping para los comentarios.
+ (RKMapping *)commentMapping;

// Maping para el detalle de una prenda.
+ (RKMapping *)productDetailsMapping;

// Maping para otros producto en una tienda.
+ (RKMapping *)otherProductMapping;

// Maping para ranking de un usuario.
+ (RKMapping *)rankingMapping;

// Mapping para respuesta luego de borrar una imagen
+ (RKMapping *)deleteImageStatusMapping;

// Mapping para listado de notificaciones
+ (RKMapping *)notificationMapping;

@end
