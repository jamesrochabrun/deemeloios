//
//  TransferObject
//  Deemelo
//
//  Created by Marcelo Espina on 25-06-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>

// Objecto para manejar los mensajes simples de la API.
// Diseñada basicamente para manejar los status que envia la API.
// Un ejemplo puede ser el decir que quiero una prenda:
//   http://deemelo.com/?page_id=12&op=loquiero&email=test@acid.cl&post_id=1
@interface TransferObject : NSObject


@property (nonatomic) NSString *status;
@property (nonatomic) NSString *errorMessage;


// NOTA: Los flags 'like' y 'want' son enviados por la API al momento de consultar si un usuario quiere una determinada prenda,
//       por tanto solo estan disponibles dentro del contexto de esa consulta.
//       http://deemelo.com/?page_id=12&op=megustaloquiero&email=test@acid.cl&post_id=1
@property (nonatomic) NSString *like;

@property (nonatomic) NSString *want;

@property (nonatomic) int count;

@end
