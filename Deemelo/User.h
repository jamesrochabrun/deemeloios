//
//  User.h
//  Deemelo
//
//  Created by Cesar Ortiz on 03-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding>

//  {"id":124,"username":"ejemplo2","correo":"","nombre":"ejemplo2"}
//  {"status":"existing_user_login"}

@property (nonatomic) NSInteger idUser;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *status;

@property (nonatomic) NSString *url;
@property (nonatomic) NSString *userDescription;
@property (nonatomic) NSString *routeThumbnail;

@property (nonatomic) NSString *facebook_id;
@property (nonatomic) NSString *token;


// Detalle del error
@property (nonatomic) NSString *errorMessage;

@end
