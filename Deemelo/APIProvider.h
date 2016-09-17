//
//  APIProvider.h
//  Deemelo
//
//  Created by Cesar Ortiz on 17-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "MappingProvider.h"
#import "User.h"
#import "ImageDetail.h" 
#import "Constants.h"
#import "AppDelegate.h"
#import "Categories.h"
#import "Product.h"
#import "Store.h"
#import "Summary.h"
#import "TransferObject.h"
#import "Comment.h"
#import "Ranking.h"
#import "Notification.h"

@interface APIProvider : NSObject

// Validar token
+ (void)validateToken:(NSString *)token
       withCompletion:(void (^)())successBlock
            withError:(void (^)())errorBlock;

+ (void)registerUser:(NSString*)username email:(NSString*)email password:(NSString*)password;

+ (void)loginWithFB:(NSString*)email names:(NSString*)names link:(NSString*)link img:(NSString*)img gender:(NSString*)gender desc:(NSString*)desc user_id:(NSString*)user_id;

+ (void)loginAppWithUsername:(NSString*)username andPasword:(NSString*)password;

+ (void)getPopularClothesFromOffset:(NSUInteger)offset
                        withSuccess:(void (^)(NSMutableArray *collection))successBlock
                            failure:(void (^)())failureBlock;

+ (NSMutableArray *)getCategories;

+ (void)getCategoriesWithSuccess:(void (^)(NSMutableArray *collection))successBlock
                     withFailure:(void (^)())failureBlock;

+ (void)getImagesOfSelectedCategory:(NSString *)categoryName
                             offset:(NSUInteger)offset
                        withSuccess:(void (^)(NSMutableArray *collection))successBlock
                            failure:(void (^)())failureBlock;

+ (void)createProduct:(Product *)prod;

+ (void)getNearClothesFromLatitude:(double)latitude
                      andLongitude:(double)longitude
                            offset:(NSUInteger)offset
                       withSuccess:(void (^)(NSMutableArray *collection))successBlock
                       withFailure:(void (^)())failureBlock;

// OMG IT'S DEPRECATED, USE getStoresFromLatitude:andLongitude:withSuccess:withFailure: INSTEAD, YOU DUMBASS
+ (NSMutableArray *)getStoresFromCityName:(NSString *)cityName
                              withSuccess:(void (^)())successBlock
                              withFailure:(void (^)())failureBlock;

+ (void)getStoresFromLatitude:(double)latitude
                 andLongitude:(double)longitude
                  withSuccess:(void (^)(NSMutableArray *collection))successBlock
                  withFailure:(void (^)())failureBlock;

// OMG IT'S DEPRECATED, USE getStoresWithCategoryName:fromLatitude:andLongitude:withSuccess:failure: INSTEAD, YOU DUMBASS
+ (void)getStoresFromCityName:(NSString *)cityName
               andProductName:(NSString *)productName
                  withSuccess:(void (^)(NSMutableArray *collection))successBlock
                      failure:(void (^)())failureBlock;

+ (void)getStoresWithCategoryName:(NSString *)categoryName
                     fromLatitude:(double)latitude
                     andLongitude:(double)longitude
                  withSuccess:(void (^)(NSMutableArray *collection))successBlock
                      failure:(void (^)())failureBlock;

+ (void)createStore:(Store *)store
        withSuccess:(void (^)())successBlock
            failure:(void (^)())failureBlock;

+ (void)getStoreDetailFromStoreID:(NSUInteger)storeID
                      withSuccess:(void (^)(Store *store))successBlock
                          failure:(void (^)())failureBlock;

+ (void)getStoreProfileCommunityPicturesFromStoreDisplayName:(NSString *)name
                                                      offset:(NSUInteger)offset
                                                 withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                                     failure:(void (^)())failureBlock;

+ (void)getStoreProfileCatalogPicturesFromStoreID:(NSUInteger)storeID
                                           offset:(NSUInteger)offset
                                      withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                          failure:(void (^)())failureBlock;

+ (void)getStoreProfileCatalogPicturesFromStoreEmail:(NSString *)email
                                              offset:(NSUInteger)offset
                                         withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                             failure:(void (^)())failureBlock;

+ (void)getStoreProfileSearchByProductPicturesFromSearchString:(NSString *)searchString
                                                    andStoreID:(NSUInteger)storeID
                                                        offset:(NSUInteger)offset
                                                   withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                                       failure:(void (^)())failureBlock;

+ (void)getFrontSearchClothesPicturesFromSearchType:(NSString *)searchType
                                       searchString:(NSString *)searchString
                                           latitude:(double)latitude
                                          longitude:(double)longitude
                                             offset:(NSUInteger)offset
                                        withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                            failure:(void (^)())failureBlock;

+ (void)getFrontSearchStoresFromSearchString:(NSString *)searchString
                                      offset:(NSUInteger)offset
                                 withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                     failure:(void (^)())failureBlock;

+ (void)getFrontSearchUsersFromSearchString:(NSString *)searchString
                                     offset:(NSUInteger)offset
                                withSuccess:(void (^)(NSMutableArray *collection))successBlock
                                    failure:(void (^)())failureBlock;

// Conector para obtener los datos de un usuario (Perfil de usuario)
+ (void)getProfileWithEmail:(NSString *)email
             withCompletion:(void (^)(User *profile))successBlock
                  withError:(void (^)())errorBlock;

// Conector para obtener las prendas de un usuario (Mis Fotos)
+ (void)getProfilePicturesFromEmail:(NSString *)email
                         withOffset:(int)offset
                     withCompletion:(void (^)(NSMutableArray *collection))successBlock
                          withError:(void (^)())errorBlock;

// Conector para obtener las prendas que quiere un usuario (Lo Quiero)
+ (void)getIWantPicturesFromEmail:(NSString *)email
                        withOffset:(int)offset
                    withCompletion:(void (^)(NSMutableArray *collection))successBlock
                         withError:(void (^)())errorBlock;

// Conector para obtener una lista con los usuarios siguen de un usuario deteminado (Quien me sigue)
+ (void)getFollowingFromEmail:(NSString *)email
                   withOffset:(int)offset
               withCompletion:(void (^)(NSMutableArray *collection))successBlock
                    withError:(void (^)())errorBlock;

// Conector para obtener una lista con usuarios que un determinado usuario esta siguiendo (A quien sigo)
+ (void)getFollowersFromEmail:(NSString *)email
                   withOffset:(int)offset
               withCompletion:(void (^)(NSMutableArray *collection))successBlock
                    withError:(void (^)())errorBlock;

// Conector para obtener el resumen de un usuario, un numero para cada categoria del perfil del usuario (imagenes, lo quiero, siguiendo, seguidores y otros)
+ (void)getSummaryFromEmail:(NSString *)email
             withCompletion:(void (^)(Summary *summary))successBlock
                  withError:(void (^)())errorBlock;


// Conector para saber si sigo a un usuario en particular
+ (void)followingUserWithEmail:(NSString *)emailFriend
                         email:(NSString *)email
                withCompletion:(void (^)(BOOL following))successBlock
                     withError:(void (^)())errorBlock;


// Conector para seguir un usuario con un email en particular
+ (void)followUserWithEmail:(NSString *)emailFriend
                      email:(NSString *)email
             withCompletion:(void (^)(BOOL successfully, NSString *errorMessage))successBlock
                  withError:(void (^)())errorBlock;

// Conector para dejar de seguir un usuario con un email en particular
+ (void)unfollowUserWithEmail:(NSString *)emailFriend
                        email:(NSString *)email
               withCompletion:(void (^)(BOOL successfully, NSString *errorMessage))successBlock
                    withError:(void (^)())errorBlock;

// Conector para borrar una prenda
+ (void)deletePictureWithId:(NSString *)picture_id
                      email:(NSString *)email
             withCompletion:(void (^)(BOOL successfully))successBlock
                  withError:(void (^)())errorBlock;

// Conector para denunciar una imagen
+ (void)reportPictureWithId:(NSString *)picture_id
                     reason:(NSString *)reason
                      email:(NSString *)email
             withCompletion:(void (^)(BOOL successfully))successBlock
                  withError:(void (^)())errorBlock;

// Conector para indicar que quiero una prenda
+ (void)iWantPictureWithId:(NSString *)picture_id
                     email:(NSString *)email
            withCompletion:(void (^)(BOOL successfully))successBlock
                 withError:(void (^)())errorBlock;

// Conector para indicar que ya no quiero una prenda
+ (void)notWantPictureWithId:(NSString *)picture_id
                       email:(NSString *)email
              withCompletion:(void (^)(BOOL successfully))successBlock
                   withError:(void (^)())errorBlock;

// Conector para saber si un usuario quiere o no una determinada prenda
+ (void)userWantPictureWithId:(NSString *)picture_id
                        email:(NSString *)email
               withCompletion:(void (^)(BOOL want))successBlock
                    withError:(void (^)())errorBlock;

// Conector crear un nuevo comentario en una determinada prenda
+ (void)createComment:(NSString *)comment
           forPicture:(NSString *)picture_id
    commentAuthorName:(NSString *)commentAuthorName
   commentAuthorEmail:(NSString *)commentAuthorEmail
       withCompletion:(void (^)())successBlock
            withError:(void (^)(NSString *errorMessage))errorBlock;

// Conector para obtener una lista con los comentarios en una prenda
+ (void)getCommentsInto:(NSString *)picture_id
         withCompletion:(void (^)(NSMutableArray *comments))successBlock
              withError:(void (^)(NSString *errorMessage))errorBlock;

// Conector para borrar un comentario
+ (void)deleteCommentWithId:(NSString *)commentId
             withCompletion:(void (^)(BOOL successfully))successBlock
                  withError:(void (^)())errorBlock;

// Url para obtener el detalle de una prenda
+ (void)getPictureDetails:(NSString *)picture_id
           withCompletion:(void (^)(Product *details))successBlock
                withError:(void (^)(NSString *errorMessage))errorBlock;

// Url para obtener un listado con otros productos en una tienda
+ (void)getAnotherPictures:(NSString *)picture_id
                   inStore:(NSString *)store_name
            withCompletion:(void (^)(NSMutableArray *other_products))successBlock
                 withError:(void (^)(NSString *errorMessage))errorBlock;

// Url para actualizar los datos de un usuario
+ (void)updateUser:(NSString *)email
          username:(NSString *)username
              name:(NSString *)name
               url:(NSString *)url
               sex:(NSString *)sex
    withCompletion:(void (^)())successBlock
         withError:(void (^)(NSString *errorMessage))errorBlock;

// Para actualizar el avatar de un usuario
+ (void)updateUser:(NSString *)email
        withAvatar:(UIImage *)avatar
    withCompletion:(void (^)())successBlock
         withError:(void (^)())errorBlock;

// Para actualizar la contraseña del usuario
+ (void)updateUser:(NSString *)email
      withPassword:(NSString *)newpass
    withCompletion:(void (^)())successBlock
         withError:(void (^)(NSString *error))errorBlock;

// Url para obtener el ranking de un usuario
// @param   email       Correo del usuario
+ (void)getUserRanking:(NSString *)email
        withCompletion:(void (^)(Ranking *ranking))successBlock
             withError:(void (^)(NSString *error))errorBlock;

// Obtener listado de notificaciones
+ (void)getNotificationsFromUserEmail:(NSString *)email
                               offset:(NSUInteger)offset
                          withSuccess:(void (^)(NSMutableArray *collection))successBlock
                              failure:(void (^)())failureBlock;

// Marcar notificación como leída
+ (void)markReadNotificationWithId:(NSString *)notificationId
                    withCompletion:(void (^)(BOOL successfully))successBlock
                         withError:(void (^)())errorBlock;

// Obtener número de notificaciones no leídas
+ (void)getUnreadNotificationsCountWithCompletion:(void (^)(int count))successBlock
                                        withError:(void (^)())errorBlock;

@end
