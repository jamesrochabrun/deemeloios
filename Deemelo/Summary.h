//
//  Summary.h
//  Deemelo
//
//  Created by Marcelo Espina on 25-06-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>

// Objecto para manejar el resumen de un usuario
// Esta clase maneja contadores para cada categoria del perfil del usuario
// entre las cuales destaca 'mis imagenes', 'lo quiero', 'siguiendo' y 'seguidores'
// pero ademas se entraga la cantidad de 'Me gusta'.
@interface Summary : NSObject


@property (nonatomic) NSString *post_user;//Mis imagenes
@property (nonatomic) NSString *want;//Lo quiero
@property (nonatomic) NSString *following;//Siguiendo
@property (nonatomic) NSString *followers;//Seguidores

@property (nonatomic) NSString *likes;//Me gusta

@end
