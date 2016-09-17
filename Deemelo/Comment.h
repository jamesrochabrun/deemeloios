//
//  Comment.h
//  Deemelo
//
//  Created by Marcelo Espina on 02-07-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>


// Objecto para manejar los comentarios.
@interface Comment : NSObject

@property (nonatomic) NSString *status;

@property (nonatomic) NSString *comment_ID;
@property (nonatomic) NSString *comment_post_ID;
@property (nonatomic) NSString *comment_author;
@property (nonatomic) NSString *comment_author_email;
@property (nonatomic) NSString *comment_author_url;
@property (nonatomic) NSString *comment_author_IP;
@property (nonatomic) NSString *comment_date;
@property (nonatomic) NSString *comment_date_gmt;
@property (nonatomic) NSString *comment_content;
@property (nonatomic) NSString *comment_karma;
@property (nonatomic) NSString *comment_approved;
@property (nonatomic) NSString *comment_agent;
@property (nonatomic) NSString *comment_type;
@property (nonatomic) NSString *comment_parent;
@property (nonatomic) NSString *user_id;

// Similar a comment_author_url pero esta a diferencia de la anterior es devuelta por la API al momento de obtener un listado de comentarios
@property (nonatomic) NSString *ruta_thumbnail;

@end