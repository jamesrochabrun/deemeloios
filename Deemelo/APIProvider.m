//
//  APIProvider.m
//  Deemelo
//
//  Created by Cesar Ortiz on 17-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "APIProvider.h"

#define STATUS_OK @"ok"
#define STATUS_ERROR @"error"

@implementation APIProvider

+ (void)manageRequestFailureWithOperation:(RKObjectRequestOperation *)operation
                                 andError:(NSError *)error
{
    NSLog(@"ERROR: %@", error);
    NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    NSLog(@"ERROR USERINFO: %@", [error userInfo]);
    
    if ([@[@-1003, @-1004, @-1005, @-1006, @-1007, @-1008, @-1009] containsObject:[NSNumber numberWithInteger:[error code]]]) {
        [SVProgressHUD showErrorWithStatus:CONNECTION_ERROR_TEXT_STRING];
    }
}

+ (void)validateToken:(NSString *)token
       withCompletion:(void (^)())successBlock
            withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForValidateToken:token];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        if ([[mappingResult array] count] > 0) {
            
            // si hay un elemento en el arreglo, llegó el resultado
            TransferObject *tr = [mappingResult.array objectAtIndex:0];
            
            if (![tr status]) {
                
                // si no llegó status, el token es válido
                successBlock();
                
            } else {
                
                // si llegó status, el token no es válido
                errorBlock();
            }
            
        } else {
            
            // si no hay un elemento en el arreglo, no llegó el resultado
            errorBlock();
            
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        errorBlock();
        
    }];
    
    [operation start];
}

+ (void)registerUser:(NSString*)username email:(NSString*)email password :(NSString*)password
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider userMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@registro&email=%@&pass=%@&nombre=%@", [Constants URLStringWithoutToken], email, password, username];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [SVProgressHUD dismiss];
        
        User *usr = [mappingResult.array objectAtIndex:0];
        if(usr.status != nil) {
            [SVProgressHUD showErrorWithStatus:usr.status];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"Usuario registrado exitosamente"];
            AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
            [sharedApp setNewRootControllerWithSB:@"Main" andIdentifier:@"login"];
            
            // testflight checkpoint
            [TestFlight passCheckpoint:TESTFLIGHT_NEW_USER_SIGN_UP];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        [SVProgressHUD showErrorWithStatus:CONNECTION_ERROR_TEXT_STRING];
    }];
    [operation start];
}

+ (void)loginWithFB:(NSString*)email names:(NSString*)names link:(NSString*)link img:(NSString*)img gender:(NSString*)gender desc:(NSString*)desc user_id:(NSString*)user_id
{
    NSString *fbAccessToken;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *emailArray = [NSMutableArray arrayWithArray:[defaults arrayForKey:DEEMELO_FB_TOKEN_SENT_EMAIL_ARRAY_PREF_KEY]];
    BOOL tokenHasBeenSent = [emailArray containsObject:email];
    
    if (tokenHasBeenSent) {
        fbAccessToken = @"0";
    } else {
        // si no encontró un token, traerlo
        fbAccessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    }
    
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];

    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider userMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@getinfoperfil&email=%@&nombres=%@&url=%@&img=%@&sexo=%@&desc=%@&facebook_id=%@&fb_token=%@", [Constants URLStringWithoutToken], email, names, link, img, gender, desc, user_id, fbAccessToken];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [SVProgressHUD dismiss];
        User *usr = [mappingResult.array objectAtIndex:0];

        if([usr status]) {
            [SVProgressHUD showErrorWithStatus:usr.status];
        }
        else {
            AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
            
            if (!tokenHasBeenSent) {
                
                // guardar el email en el array en nsuserdefaults
                [emailArray addObject:email];
                
                [[NSUserDefaults standardUserDefaults] setObject:emailArray
                                                          forKey:DEEMELO_FB_TOKEN_SENT_EMAIL_ARRAY_PREF_KEY];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            
            // agregar referencia al usuario en el appdelegate
            [sharedApp setCurrentUser:usr];
            
            // guardar currentUser en nsuserdefaults
            NSData *currentUserData = [NSKeyedArchiver archivedDataWithRootObject:[sharedApp currentUser]];
            [[NSUserDefaults standardUserDefaults] setObject:currentUserData
                                                      forKey:DEEMELO_CURRENT_USER_DATA_PREF_KEY];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // presentar dashboard
            [sharedApp setNewRootControllerWithSB:@"Dashboard" andIdentifier:@"dashboard"];
            
            // testflight checkpoint
            [TestFlight passCheckpoint:TESTFLIGHT_FACEBOOK_LOGIN];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        [SVProgressHUD showErrorWithStatus:CONNECTION_ERROR_TEXT_STRING];
    }];
    [operation start];
}

+ (void)loginAppWithUsername:(NSString*)username andPasword:(NSString*)password
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider userMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];

    NSString *urlString = [NSString stringWithFormat:@"%@iniciarsesion&username=%@&pass=%@",[Constants URLStringWithoutToken], username, password];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [SVProgressHUD dismiss];
        User *usr = [mappingResult.array objectAtIndex:0];
               
        if(usr.status != nil) {
            [SVProgressHUD showErrorWithStatus:usr.status];
        }
        else {
            // si no envía status, entonces el usuario es correcto y viene la data
            AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
            
            // agregar referencia al usuario en el appdelegate
            [sharedApp setCurrentUser:usr];
            
            // guardar currentUser en nsuserdefaults
            NSData *currentUserData = [NSKeyedArchiver archivedDataWithRootObject:[sharedApp currentUser]];
            [[NSUserDefaults standardUserDefaults] setObject:currentUserData
                                                      forKey:DEEMELO_CURRENT_USER_DATA_PREF_KEY];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // presentar dashboard
            [sharedApp setNewRootControllerWithSB:@"Dashboard" andIdentifier:@"dashboard"];
            
            // testflight checkpoint
            [TestFlight passCheckpoint:TESTFLIGHT_NORMAL_LOGIN];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        [SVProgressHUD showErrorWithStatus:CONNECTION_ERROR_TEXT_STRING];
    }];
    [operation start];
}

+ (void)getPopularClothesFromOffset:(NSUInteger)offset
                        withSuccess:(void (^)(NSMutableArray *collection))successBlock
                            failure:(void (^)())failureBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider imageMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@maspopulares&offset=%d", [Constants URLStringWithToken], offset];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];

    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSMutableArray *prendas = [[NSMutableArray alloc] init];
        
        if(mappingResult.array.count > 0) {
            for (ImageDetail *img in mappingResult.array) {
                if ([img images]) {
                    [prendas addObject:img];
                }
            }
        }
        //NSLog(@"Done loading images");
        successBlock(prendas);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    [operation start];
}

+ (NSMutableArray *)getCategories {
    
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider categoriesMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@listcat&taxonomy=prenda", [Constants URLStringWithoutToken]];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [categories addObjectsFromArray:mappingResult.array];
        
        //NSLog(@"Done loading categories");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
    }];
    [operation start];
    return categories;
}

+ (void)getCategoriesWithSuccess:(void (^)(NSMutableArray *collection))successBlock
                     withFailure:(void (^)())failureBlock
{
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider categoriesMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@listcat&taxonomy=prenda", [Constants URLStringWithoutToken]];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [categories addObjectsFromArray:mappingResult.array];
        
        successBlock(categories);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(@"ERROR USERINFO: %@", [error userInfo]);
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        failureBlock();
    }];
    
    [operation start];
}

+ (void)getImagesOfSelectedCategory:(NSString *)categoryName
                             offset:(NSUInteger)offset
                        withSuccess:(void (^)(NSMutableArray *collection))successBlock
                            failure:(void (^)())failureBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
//    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
//                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider imageMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@getresultvitrinea&terms=%@&offset=%d&tax=prenda", [Constants URLStringWithToken], categoryName, offset];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
       
        NSMutableArray *prendas = [[NSMutableArray alloc] init];
        
        if(mappingResult.array.count > 0) {
            for (ImageDetail *img in mappingResult.array) {
                if ([img images]) {
                    [prendas addObject:img];
//                    NSLog(@"\n id: %@ \n author: %@ \n image: %@ \n image author: %@ \n email: %@ ",
//                          img.idImage, img.author, img.images, img.ruta_thumbnail, img.emailfriend);
                }
            }
        }
        //NSLog(@"Done loading category images");
        successBlock(prendas);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)createProduct:(Product *)prod
{
    // preparar la data de la imagen
    UIImage *prodImage = [prod image];
    NSData *prodImageData = UIImageJPEGRepresentation(prodImage, 0.5);
    
    RKObjectManager* tempManager=[RKObjectManager managerWithBaseURL:[NSURL URLWithString:@""]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@upload&email=%@&prenda=%@&tienda=%@&file=", [Constants URLStringWithToken], [prod userEmail], [prod categoryName], [prod storeName]];
    
    NSString *encUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    
    NSURLRequest *request =
        [tempManager.HTTPClient multipartFormRequestWithMethod:@"POST"
                                                          path:encUrlString
                                                    parameters:nil
                                     constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
            [formData appendPartWithFileData:prodImageData
                                        name:@"file"
                                    fileName:@"image123.jpg"
                                    mimeType:@"image/jpeg"];
        }];
    
//    NSLog(@"\n\nANTES DE ENVIAR - URL:    %@\n\n", [request URL]);
//    NSLog(@"\n\nANTES DE ENVIAR - REQ: %@\n\n", request);
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"\n\n2: SUCCESS - operation         : %@\n\n", operation);
//        NSLog(@"\n\n2: SUCCESS - op.request        : %@\n\n", [operation request]);
//        NSLog(@"\n\n2: SUCCESS - op.response       : %@\n\n", [operation response]);
//        NSLog(@"\n\n2: SUCCESS - op.error          : %@\n\n", [operation error]);
//        NSLog(@"\n\n2: SUCCESS - op.responsedata   : %@\n\n", [operation responseData]);
//        NSLog(@"\n\n2: SUCCESS - op.responsestring : %@\n\n", [operation responseString]);
//        NSLog(@"\n\n2: SUCCESS - returned          : %@\n\n", responseObject);
        
        //NSLog(@"Done creating new product/uploading image");
        
        [SVProgressHUD showSuccessWithStatus:@"Imagen subida!"];
        
        // testflight checkpoint
        [TestFlight passCheckpoint:TESTFLIGHT_NEW_PICTURE_ADDED];
        
        // refrescar el contador de fotos del perfil del usuario
        // refrescar la colección de fotos del perfil del usuario
        NSNotification *note = [NSNotification notificationWithName:AddedPictureNotification
                                                             object:self
                                                           userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:note];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"\n\n2: FALLO - operation         : %@\n\n", operation);
//        NSLog(@"\n\n2: FALLO - op.request        : %@\n\n", [operation request]);
//        NSLog(@"\n\n2: FALLO - op.response       : %@\n\n", [operation response]);
//        NSLog(@"\n\n2: FALLO - op.error          : %@\n\n", [operation error]);
//        NSLog(@"\n\n2: FALLO - op.responsedata   : %@\n\n", [operation responseData]);
//        NSLog(@"\n\n2: FALLO - op.responsestring : %@\n\n", [operation responseString]);
//        NSLog(@"\n\n2: FALLO - error             : %@\n\n", [error description]);
//        NSLog(@"\n\n2: FALLO - errorinfo         : %@\n\n", [error userInfo]);
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        [SVProgressHUD showErrorWithStatus:CONNECTION_ERROR_TEXT_STRING];
    }];
    
    //[operation start];
    
    [op start];
}

+ (void)getNearClothesFromLatitude:(double)latitude
                      andLongitude:(double)longitude
                            offset:(NSUInteger)offset
                       withSuccess:(void (^)(NSMutableArray *collection))successBlock
                       withFailure:(void (^)())failureBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider imageMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *urlString = [[Constants alloc] getUrlForGetNearClothesFromLatitude:latitude
                                                                 andLongitude:longitude
                                                                   withOffset:offset];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlString];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSMutableArray *prendas = [[NSMutableArray alloc] init];
        
        if(mappingResult.array.count > 0) {
            for (ImageDetail *img in mappingResult.array) {
                if ([img images]) {
                    [prendas addObject:img];
                }
            }
        }
        //NSLog(@"Done loading images");
        successBlock(prendas);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    [operation start];
}

+ (NSMutableArray *)getStoresFromCityName:(NSString *)cityName
                              withSuccess:(void (^)())successBlock
                              withFailure:(void (^)())failureBlock
{
    NSMutableArray *stores = [[NSMutableArray alloc] init];
    
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider storesMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@gettienda&ciu=%@", [Constants URLStringWithToken], cityName];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [stores addObjectsFromArray:mappingResult.array];
        
        // agregar la ciudad a cada instancia de tienda, ya que la api no lo provee
        if (stores != nil) {
            if ([stores count] > 0) {
                for (Store *st in stores) {
                    [st setCity:cityName];
                }
            }
        }
        
        //NSLog(@"Done loading stores");
        
        successBlock();
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
    
    return stores;
}

+ (void)getStoresFromLatitude:(double)latitude
                 andLongitude:(double)longitude
                  withSuccess:(void (^)(NSMutableArray *collection))successBlock
                  withFailure:(void (^)())failureBlock
{
    NSMutableArray *stores = [[NSMutableArray alloc] init];
    
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider storesMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *urlString = [[Constants alloc] getUrlForGetStoresFromLatitude:latitude
                                                            andLongitude:longitude];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlString];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [stores addObjectsFromArray:mappingResult.array];
        
        //NSLog(@"Done loading stores");
        
        successBlock(stores);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(@"ERROR USERINFO: %@", [error userInfo]);
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        failureBlock();
    }];
    
    [operation start];
}

+ (void)getStoresFromCityName:(NSString *)cityName
               andProductName:(NSString *)productName
                  withSuccess:(void (^)(NSMutableArray *collection))successBlock
                      failure:(void (^)())failureBlock
{
    NSMutableArray *stores = [[NSMutableArray alloc] init];
    
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider searchStoresByProductMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@buscarprendamapa&prenda=%@&ciudad=%@", [Constants URLStringWithToken], productName, cityName];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [stores addObjectsFromArray:mappingResult.array];
        
        // agregar la ciudad a cada instancia de tienda, ya que la api no lo provee
        if (stores != nil) {
            if ([stores count] > 0) {
                for (Store *st in stores) {
                    //NSLog(@"TIENDA: %@", st);
                    [st setCity:cityName];
                }
            }
        }
        
        //NSLog(@"Done loading stores");
        successBlock(stores);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getStoresWithCategoryName:(NSString *)categoryName
                     fromLatitude:(double)latitude
                     andLongitude:(double)longitude
                      withSuccess:(void (^)(NSMutableArray *collection))successBlock
                          failure:(void (^)())failureBlock
{
    NSMutableArray *stores = [[NSMutableArray alloc] init];
    
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider searchStoresByProductMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *urlString = [[Constants alloc] getUrlForGetStoresWithCategoryName:categoryName
                                                                fromLatitude:latitude
                                                                andLongitude:longitude];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlString];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [stores addObjectsFromArray:mappingResult.array];
        
        //NSLog(@"Done loading stores");
        
        successBlock(stores);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)createStore:(Store *)store
        withSuccess:(void (^)())successBlock
            failure:(void (^)())failureBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider storesMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:
                           @"%@ingresartienda&nom=%@&dir=%@&lat=%@&lon=%@&ciu=%@&pro=%@&reg=%@&pais=%@",
                           [Constants URLStringWithToken],
                           [store name], [store address], [store latitude], [store longitude],
                           [store city], [store province], [store region], [store country]];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //NSLog(@"\n\nANTES DE ENVIAR PARA CREAR TIENDA - URL:    %@\n\n", [request URL]);
    //NSLog(@"\n\nANTES DE ENVIAR PARA CREAR TIENDA - REQ: %@\n\n", request);
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        Store *st = [mappingResult.array objectAtIndex:0];
        if([[st status] isEqualToString:@"ok"]) {
            //NSLog(@"Done creating store");
            //NSLog(@"%@", st);
            //NSLog(@"%@", [st status]);
            successBlock();
        } else {
            //NSLog(@"Error creating store");
            //NSLog(@"%@", st);
            //NSLog(@"%@", [st status]);
            failureBlock();
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(@"ERROR USERINFO: %@", [error userInfo]);
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        failureBlock();
    }];
    
    [operation start];
}

+ (void)getStoreDetailFromStoreID:(NSUInteger)storeID
                      withSuccess:(void (^)(Store *store))successBlock
                          failure:(void (^)())failureBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider storesMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@gettienda&idtienda=%d", [Constants URLStringWithToken], storeID];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        Store *st;
        if ([mappingResult.array count] > 0) {
            st = [mappingResult.array objectAtIndex:0];
        }
        
        if (st) {
            if([st status] != nil) {
                // si recibió status entonces hay error
                [SVProgressHUD showErrorWithStatus:[st status]];
            }
            else {
                // sino devuelve la tienda
                //NSLog(@"TIENDA: %@", st);
                
                successBlock(st);
            }
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getStoreProfileCommunityPicturesFromStoreDisplayName:(NSString *)name
                                                      offset:(NSUInteger)offset
                                                 withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                                     failure:(void (^)())failureBlock;
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider imageMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@catalogocomunidad&display_name=%@&offset=%d", [Constants URLStringWithToken], name, offset];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSMutableArray *prendas = [[NSMutableArray alloc] init];
        for (ImageDetail *img in mappingResult.array) {
            if ([img images])
            {
                [prendas addObject:img];
            }
        }
        
        successBlock(prendas);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getStoreProfileCatalogPicturesFromStoreID:(NSUInteger)storeID
                                           offset:(NSUInteger)offset
                                      withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                          failure:(void (^)())failureBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider storesMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@gettienda&idtienda=%d", [Constants URLStringWithToken], storeID];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        Store *store;
        if ([mappingResult.array count] > 0) {
            store = [mappingResult.array objectAtIndex:0];
        }
        
        if (store) {
            if([store status] != nil) {
                // si recibió status entonces hay error
                [SVProgressHUD showErrorWithStatus:[store status]];
            }
            else {
                // sino continúa cargando
                //NSLog(@"EL EMAIL ES: %@", [store email]);
                
                [self getStoreProfileCatalogPicturesFromStoreEmail:[store email]
                                                            offset:offset
                                                       withSuccess:^(NSMutableArray *collection) {
                                                           successBlock(collection);
                                                       }
                                                           failure:^{
                                                               failureBlock();
                                                           }];
            }
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getStoreProfileCatalogPicturesFromStoreEmail:(NSString *)email
                                              offset:(NSUInteger)offset
                                         withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                             failure:(void (^)())failureBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider imageMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@getpostlistimage&email=%@&offset=%d", [Constants URLStringWithToken], email, offset];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSMutableArray *prendas = [[NSMutableArray alloc] init];
        for (ImageDetail *img in mappingResult.array) {
            if ([img images])
            {
                [prendas addObject:img];
            }
        }
        
        successBlock(prendas);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getStoreProfileSearchByProductPicturesFromSearchString:(NSString *)searchString
                                                    andStoreID:(NSUInteger)storeID
                                                        offset:(NSUInteger)offset
                                                   withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                                       failure:(void (^)())failureBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider imageMappingForStoreProfileSearchByProduct]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@getpostprendatienda&prenda=%@&offset=%d&tienda_id=%d", [Constants URLStringWithToken], searchString, offset, storeID];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSMutableArray *prendas = [[NSMutableArray alloc] init];
        for (ImageDetail *img in mappingResult.array) {
            if ([img images])
            {
                [prendas addObject:img];
            }
        }
        
        successBlock(prendas);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getFrontSearchClothesPicturesFromSearchType:(NSString *)searchType
                                       searchString:(NSString *)searchString
                                           latitude:(double)latitude
                                          longitude:(double)longitude
                                             offset:(NSUInteger)offset
                                        withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                            failure:(void (^)())failureBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider imageMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForFrontSearchClothesPicturesFromSearchType:searchType
                                                                         searchString:searchString
                                                                             latitude:latitude
                                                                            longitude:longitude
                                                                               offset:offset];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSMutableArray *prendas = [[NSMutableArray alloc] init];
        
        if(mappingResult.array.count > 0) {
            for (ImageDetail *img in mappingResult.array) {
                if ([img images]) {
                    [prendas addObject:img];
                    //NSLog(@"\n id: %@ \n author: %@ \n image: %@ \n image author: %@ \n email: %@ ", img.idImage, img.author, img.images, img.ruta_thumbnail, img.emailfriend);
                }
            }
        }
        //NSLog(@"Done loading category images");
        successBlock(prendas);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getFrontSearchStoresFromSearchString:(NSString *)searchString
                                      offset:(NSUInteger)offset
                                 withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                     failure:(void (^)())failureBlock
{
    NSMutableArray *stores = [[NSMutableArray alloc] init];
    
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider searchStoresMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@buscartiendas&search=%@&offset=%d", [Constants URLStringWithToken], searchString, offset];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [stores addObjectsFromArray:mappingResult.array];
        
        if (stores != nil) {
            if ([stores count] > 0) {
                for (Store *st in stores) {
                    //NSLog(@"TIENDA: %@", st);
                }
            }
        }
        
        //NSLog(@"Done loading stores");
        successBlock(stores);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getFrontSearchUsersFromSearchString:(NSString *)searchString
                                     offset:(NSUInteger)offset
                                withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                    failure:(void (^)())failureBlock
{
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider searchUserMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSString *urlString = [NSString stringWithFormat:@"%@buscarpersonas&search=%@&offset=%d", [Constants URLStringWithToken], searchString, offset];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        if ([[mappingResult array] count] > 0) {
            
            User *usr = [mappingResult.array objectAtIndex:0];
            
            if (![usr status]) {
                // si no hay status, entonces llenamos el arreglo
                [users addObjectsFromArray:mappingResult.array];
            }
        }
        
        // devolvemos el arreglo
        //NSLog(@"Done loading users");
        successBlock(users);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getProfileWithEmail:(NSString *)email
             withCompletion:(void (^)(User *profile))successBlock
                  withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider userMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *urlString = [[Constants alloc] getUrlForProfileWithEmail:email];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlString];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        successBlock([mappingResult.array objectAtIndex:0]);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        errorBlock();
    }];
    
    [operation start];
}

+ (void)getProfilePicturesFromEmail:(NSString *)email
                         withOffset:(int)offset
                     withCompletion:(void (^)(NSMutableArray *collection))successBlock
                          withError:(void (^)())errorBlock

{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider imageMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    
    NSURL *url = [[Constants alloc] getUrlForProfilePicturesFromEmail:email withOffset:(int)offset];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSMutableArray *prendas = [[NSMutableArray alloc] init];
        for (ImageDetail *img in mappingResult.array) {
            if ([img images])
            {
                [prendas addObject:img];
            }
        }
        
        successBlock(prendas);
        
        //        successBlock((NSMutableArray *)mappingResult.array);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getIWantPicturesFromEmail:(NSString *)email
                        withOffset:(int)offset
                    withCompletion:(void (^)(NSMutableArray *collection))successBlock
                         withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider imageMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    
    NSURL *url = [[Constants alloc] getUrlForIWantPicturesFromEmail:email withOffset:(int)offset];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSMutableArray *prendas = [[NSMutableArray alloc] init];
        for (ImageDetail *img in mappingResult.array) {
            if ([img images])
            {
                [prendas addObject:img];
            }
        }
        
        successBlock(prendas);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getFollowingFromEmail:(NSString *)email
                   withOffset:(int)offset
               withCompletion:(void (^)(NSMutableArray *collection))successBlock
                    withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider followMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForFollowingFromEmail:email withOffset:offset];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User *usr = [mappingResult.array objectAtIndex:0];
        
        // Reviso que no sea un status lo que devolvio la API
        if ( ![usr status] ) {
            successBlock((NSMutableArray *)[mappingResult array]);
        } else {
            successBlock([[NSMutableArray alloc] init]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getFollowersFromEmail:(NSString *)email
                   withOffset:(int)offset
               withCompletion:(void (^)(NSMutableArray *collection))successBlock
                    withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider followMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForFollowersFromEmail:email withOffset:offset];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User *usr = [mappingResult.array objectAtIndex:0];
        
        // Reviso que no sea un status lo que devolvio la API
        if ( ![usr status] ) {
            successBlock((NSMutableArray *)[mappingResult array]);
        } else {
            successBlock([[NSMutableArray alloc] init]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getSummaryFromEmail:(NSString *)email
             withCompletion:(void (^)(Summary *summary))successBlock
                  withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider summaryMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlSummaryFromEmail:email];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        successBlock((Summary *)[mappingResult.array objectAtIndex:0]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        errorBlock();
    }];
    
    [operation start];
}

+ (void)followingUserWithEmail:(NSString *)emailFriend
                         email:(NSString *)email
                withCompletion:(void (^)(BOOL following))successBlock
                     withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider followMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForFollowingFromEmail:email withOffset:0];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User *usr = [mappingResult.array objectAtIndex:0];
        
        // Reviso que no sea un status lo que devolvio la API
        if ( ![usr status] ) {
            BOOL follow = NO;
            for (User *user in [mappingResult array]) {
                // Si encuentro algun following dejo de buscar
                if ([[user email] isEqualToString:emailFriend])
                {
                    follow = YES;
                    break;
                }
            }
            
            // Si luego de revisar todos los usuario que estoy siguiendo indico estoy siguiendo o no el emailFriend
            successBlock(follow);
        } else {
            successBlock(NO);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        errorBlock();
    }];
    
    [operation start];
}

+ (void)followUserWithEmail:(NSString *)emailFriend
                      email:(NSString *)email
             withCompletion:(void (^)(BOOL successfully, NSString *errorMessage))successBlock
                  withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForFollowUserWithEmail:emailFriend email:email];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User *usr = [mappingResult.array objectAtIndex:0];
        
        // Reviso el status que devolvio la API
        if ( [[usr status] isEqualToString:STATUS_OK] ) {
            successBlock(YES, nil);
        } else {
            successBlock(NO, [usr errorMessage]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)unfollowUserWithEmail:(NSString *)emailFriend
                        email:(NSString *)email
               withCompletion:(void (^)(BOOL successfully, NSString *errorMessage))successBlock
                    withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForUnfollowUserWithEmail:emailFriend email:email];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User *usr = [mappingResult.array objectAtIndex:0];
        
        // Reviso el status que devolvio la API
        if ( [[usr status] isEqualToString:STATUS_OK] ) {
            successBlock(YES, nil);
        } else {
            successBlock(NO, [usr errorMessage]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)deletePictureWithId:(NSString *)picture_id
                      email:(NSString *)email
             withCompletion:(void (^)(BOOL successfully))successBlock
                  withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForDeletePicture:picture_id withEmail:email];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        TransferObject *tr = [mappingResult.array objectAtIndex:0];
        
        // Reviso el status que devolvio la API
        if ( [[tr status] isEqualToString:STATUS_OK] ) {
            successBlock(YES);
        } else {
            successBlock(NO);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)reportPictureWithId:(NSString *)picture_id
                     reason:(NSString *)reason
                      email:(NSString *)email
             withCompletion:(void (^)(BOOL successfully))successBlock
                  withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForReportPicture:picture_id reason:reason withEmail:email];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        // la api en ningún caso retorna información, asumimos que la respuesta fue OK
        /*
        TransferObject *tr = [mappingResult.array objectAtIndex:0];
        
        // Reviso el status que devolvio la API
        if ( [[tr status] isEqualToString:STATUS_OK] ) {
            successBlock(YES);
        } else {
            successBlock(NO);
        }
        */
        
        successBlock(YES);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
    
}

+ (void)iWantPictureWithId:(NSString *)picture_id
                     email:(NSString *)email
            withCompletion:(void (^)(BOOL successfully))successBlock
                 withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForIWant:email picture_id:picture_id];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User *usr = [mappingResult.array objectAtIndex:0];
        
        // Reviso el status que devolvio la API
        if ( [[usr status] isEqualToString:STATUS_OK] ) {
            successBlock(YES);
        } else {
            successBlock(NO);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}


+ (void)notWantPictureWithId:(NSString *)picture_id
                       email:(NSString *)email
              withCompletion:(void (^)(BOOL successfully))successBlock
                   withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForNotIWant:email picture_id:picture_id];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User *usr = [mappingResult.array objectAtIndex:0];
        
        // Reviso el status que devolvio la API
        if ( [[usr status] isEqualToString:STATUS_OK] ) {
            successBlock(YES);
        } else {
            successBlock(NO);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)userWantPictureWithId:(NSString *)picture_id
                        email:(NSString *)email
               withCompletion:(void (^)(BOOL want))successBlock
                    withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    
    NSURL *url = [[Constants alloc] getUrlForLikeWant:email picture_id:picture_id];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        TransferObject *result = [mappingResult.array objectAtIndex:0];
        
        // Reviso el flag want que devolvio la API
        
        // El usuario quiere la prenda?
        if ( ![[result want] isEqualToString:@"0"] ) {
            successBlock(YES);
        } else {
            successBlock(NO);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        errorBlock();
    }];
    
    [operation start];
}

+ (void)createComment:(NSString *)comment
           forPicture:(NSString *)picture_id
    commentAuthorName:(NSString *)commentAuthorName
   commentAuthorEmail:(NSString *)commentAuthorEmail
       withCompletion:(void (^)())successBlock
            withError:(void (^)(NSString *errorMessage))errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider commentMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForComment:comment
                                          forPicture:picture_id
                                   commentAuthorName:commentAuthorName
                                  commentAuthorEmail:commentAuthorEmail];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        Comment *comment = [[mappingResult array] objectAtIndex:0];
        
        if( ![comment status] ) {
            successBlock();
        } else {
            errorBlock([comment status]);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock([error localizedFailureReason]);
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getCommentsInto:(NSString *)picture_id
         withCompletion:(void (^)(NSMutableArray *comments))successBlock
              withError:(void (^)(NSString *errorMessage))errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider commentMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForCommentsInto:picture_id];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        successBlock((NSMutableArray *)[mappingResult array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        // NOTA: esto deberia ser temporal
        successBlock([NSMutableArray array]);
        
        
        // NOTA: Descomentar esto cuando la API comience a devolver una arreglo vacio en caso de imagenes sin comentarios en vez de null, (null no es un JSON parseable)
        // errorBlock([error localizedFailureReason]);
    }];
    
    [operation start];
}

+ (void)deleteCommentWithId:(NSString *)commentId
             withCompletion:(void (^)(BOOL successfully))successBlock
                  withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForDeleteComment:commentId];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        if ([[mappingResult array] count] > 0) {
            
            // si hay un elemento en el arreglo, llegó el resultado
            TransferObject *tr = [mappingResult.array objectAtIndex:0];
            
            // Reviso el status que devolvio la API
            if ( [[tr status] isEqualToString:@"OK"] ) {
                successBlock(YES);
            } else {
                successBlock(NO);
            }
            
        } else {
            
            // si no hay un elemento en el arreglo, no llegó el resultado
            errorBlock();
            
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getPictureDetails:(NSString *)picture_id
           withCompletion:(void (^)(Product *details))successBlock
                withError:(void (^)(NSString *errorMessage))errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider productDetailsMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForPictureDetails:picture_id];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        successBlock([[mappingResult array] objectAtIndex:0]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        // NOTA: esto deberia ser temporal
        errorBlock([error localizedFailureReason]);
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)getAnotherPictures:(NSString *)picture_id
                   inStore:(NSString *)store_name
            withCompletion:(void (^)(NSMutableArray *other_products))successBlock
                 withError:(void (^)(NSString *errorMessage))errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider otherProductMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForAnotherPictures:picture_id inStore:store_name];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        successBlock((NSMutableArray *)[mappingResult array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        // NOTA: esto deberia ser temporal
        errorBlock([error localizedFailureReason]);
    }];
    
    [operation start];
}

+ (void)updateUser:(NSString *)email
          username:(NSString *)username
              name:(NSString *)name
               url:(NSString *)user_url
               sex:(NSString *)sex
    withCompletion:(void (^)())successBlock
         withError:(void (^)(NSString *errorMessage))errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider userMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForUpdateUser:email
                                               username:username
                                                   name:name
                                                    url:user_url
                                                    sex:sex];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User * user = [[mappingResult array] objectAtIndex:0];
        if( ![user status] ) {
            successBlock();
        } else {
            errorBlock([user status]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        // NOTA: esto deberia ser temporal
        errorBlock([error localizedFailureReason]);
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)updateUser:(NSString *)email
        withAvatar:(UIImage *)avatar
    withCompletion:(void (^)())successBlock
         withError:(void (^)())errorBlock
{
    // preparar la data de la imagen
    NSData *prodImageData = UIImageJPEGRepresentation(avatar, 0.5);
    
    RKObjectManager* tempManager=[RKObjectManager managerWithBaseURL:[NSURL URLWithString:@""]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@cambiarimagen&email=%@&file=", [Constants URLStringWithToken], email];
    
    NSString *encUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    
    NSURLRequest *request = [tempManager.HTTPClient multipartFormRequestWithMethod:@"POST"
                                                                              path:encUrlString
                                                                        parameters:nil
                                                         constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                                                             [formData appendPartWithFileData:prodImageData
                                                                                         name:@"file"
                                                                                     fileName:@"image123.jpg"
                                                                                     mimeType:@"image/jpeg"];
                                                         }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        errorBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)updateUser:(NSString *)email
      withPassword:(NSString *)newpass
    withCompletion:(void (^)())successBlock
         withError:(void (^)(NSString *error))errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider userMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForUpdateUser:email withPassword:newpass];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        User * user = [[mappingResult array] objectAtIndex:0];
        if( [[user status] isEqualToString:@"ok"] ) {
            successBlock();
        } else {
            errorBlock([user status]);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        errorBlock([error localizedFailureReason]);
    }];
    
    [operation start];
}

+ (void)getUserRanking:(NSString *)email
        withCompletion:(void (^)(Ranking *ranking))successBlock
             withError:(void (^)(NSString *error))errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider rankingMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForUserRanking:email];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        successBlock([[mappingResult array] objectAtIndex:0]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        // NOTA: esto deberia ser temporal
        errorBlock([error localizedFailureReason]);
    }];
    
    [operation start];
}

+ (void)getNotificationsFromUserEmail:(NSString *)email
                               offset:(NSUInteger)offset
                          withSuccess:(void (^)(NSMutableArray *collection))successBlock
                              failure:(void (^)())failureBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider notificationMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForNotificationsFromUserEmail:email
                                                             withOffset:offset];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSMutableArray *notifications = [[NSMutableArray alloc] init];
        
        if (([[mappingResult array] count] > 0)) {
            [notifications addObjectsFromArray:[mappingResult array]];
        }
        
        successBlock(notifications);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        failureBlock();
        
        [APIProvider manageRequestFailureWithOperation:operation
                                              andError:error];
    }];
    
    [operation start];
}

+ (void)markReadNotificationWithId:(NSString *)notificationId
                    withCompletion:(void (^)(BOOL successfully))successBlock
                         withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForMarkReadNotificationWithId:notificationId];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        TransferObject *tr = [mappingResult.array objectAtIndex:0];
        
        // Reviso el status que devolvio la API
        if ( [[tr status] isEqualToString:STATUS_OK] ) {
            successBlock(YES);
        } else {
            successBlock(NO);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        errorBlock();
    }];
    
    [operation start];
}

+ (void)getUnreadNotificationsCountWithCompletion:(void (^)(int count))successBlock
                                        withError:(void (^)())errorBlock
{
    NSIndexSet *statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class]
                               forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDecriptor = [RKResponseDescriptor responseDescriptorWithMapping:[MappingProvider transferObjectMapping]
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:nil
                                                                                          keyPath:nil
                                                                                      statusCodes:statusCode];
    
    NSURL *url = [[Constants alloc] getUrlForUnreadNotificationsCount];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDecriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        if ([[mappingResult array] count] > 0) {
            
            // si hay un elemento en el arreglo, llegó el resultado
            TransferObject *tr = [mappingResult.array objectAtIndex:0];
            successBlock([tr count]);
            
        } else {
            
            // si no hay un elemento en el arreglo, no llegó el resultado
            errorBlock();
            
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
//        [APIProvider manageRequestFailureWithOperation:operation
//                                              andError:error];
        
        errorBlock();
    }];
    
    [operation start];
}

@end
