//
//  Constants.h
//  Deemelo
//
//  Created by Manuel Gomez on 17-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APPLE_APPSTORE_APP_URL                                  @"http://itunes.apple.com/cl/app/deemelo/id709713945?mt=8"
#define POLICIES_URL                                            @"http://deemelo.com/politicas-de-privacidad.html"
#define PASSWORD_URL                                            @"http://deemelo.com/wp-login.php?action=lostpassword"

#define TESTFLIGHT_APP_TOKEN                                    @"39532d72-ec32-44c6-b770-5de8fce41622"
#define TESTFLIGHT_NEW_USER_SIGN_UP                             @"registra nuevo usuario"
#define TESTFLIGHT_NORMAL_LOGIN                                 @"login normal"
#define TESTFLIGHT_FACEBOOK_LOGIN                               @"login con facebook"
#define TESTFLIGHT_NEW_PICTURE_ADDED                            @"agrega nueva foto"

#define ITEM_DETAIL_DELETE_CONFIRMATION_BUTTON_TITLE            @"Eliminar"
#define ITEM_DETAIL_REPORT_CONFIRMATION_BUTTON_TITLE            @"Reportar"
#define ITEM_DETAIL_COMMENT_DELETE_CONFIRMATION_BUTTON_TITLE    @"Borrar"

#define DEEMELO_FB_TOKEN_SENT_EMAIL_ARRAY_PREF_KEY              @"DeemeloFBTokenSentEmailArrayPrefKey"
#define DEEMELO_CURRENT_USER_DATA_PREF_KEY                      @"DeemeloCurrentUserDataPrefKey"

#define IMAGEPICKER_MAX_RESOLUTION                              1280

#define PICTURE_COLLECTION_ITEM_WIDTH                           152

#define PICTURE_DETAILS_STORE_ROLE_NAME                         @"tienda"

#define FRONT_SEARCH_TYPE_POPULAR                               @"popular"
#define FRONT_SEARCH_TYPE_NEAR                                  @"cercanas"

#define PROFILE_TAB_TITLE_TYPE_PROFILEPICTURES                  @"Fotos"
#define PROFILE_TAB_TITLE_TYPE_IWANTPICTURES                    @"Lo Quiero"
#define PROFILE_TAB_TITLE_TYPE_FOLLOWING                        @"Siguiendo"
#define PROFILE_TAB_TITLE_TYPE_FOLLOWERS                        @"Seguidores"

#define CONNECTION_ERROR_TEXT_STRING                            @"Error de conexión"

@interface Constants : NSObject

//extern NSString * const serverURL;
extern NSString * const serverURL;

// Constante para manejar las notificaciones de un usuario que comienza a seguir a otro
extern NSString * const FollowUserNotification;

// Constante para manejar las notificaciones de un usuario que deja a seguir a otro
extern NSString * const UnfollowUserNotification;

// Constante para manejar las notificaciones de un usuario que indica que quiere una prenda
extern NSString * const IWantPictureNotification;

// Constante para manejar las notificaciones de un usuario que indica que ya no quiere una prenda
extern NSString * const NotWantPictureNotification;

// Constante para manejar las notificaciones de un usuario que actualiza sus datos
extern NSString * const UserUpdatedNotification;

// Constante para manejar las notificaciones de un usuario que agrega una foto
extern NSString * const AddedPictureNotification;

// Constante para manejar las notificaciones de un usuario que borra una foto
extern NSString * const DeletedPictureNotification;

// Obtiene URL sin token
+ (NSString *)URLStringWithoutToken;

// Obtiene URL con token
+ (NSString *)URLStringWithToken;

// Url para validar token
- (NSURL *)getUrlForValidateToken:(NSString *)token;

// Url para obtener las prendas del buscador de la portada según tipo de búsqueda, string de búsqueda, latitud y longitud
- (NSURL *)getUrlForFrontSearchClothesPicturesFromSearchType:(NSString *)searchType
                                                searchString:(NSString *)searchString
                                                    latitude:(double)latitude
                                                   longitude:(double)longitude
                                                      offset:(int)offset;

// Url para obtener las prendas cercanas según latitud y longitud
- (NSURL *)getUrlForGetNearClothesFromLatitude:(double)latitude
                                  andLongitude:(double)longitude
                                    withOffset:(int)offset;

// Url para obtener las tiendas cercanas según latitud y longitud
- (NSURL *)getUrlForGetStoresFromLatitude:(double)latitude
                             andLongitude:(double)longitude;

// Url para obtener las tiendas cercanas que tengan una prenda de una categoría según latitud y longitud
- (NSURL *)getUrlForGetStoresWithCategoryName:(NSString *)categoryName
                                 fromLatitude:(double)latitude
                                 andLongitude:(double)longitude;

// Url para obtener los datos de un usuario (Perfil de usuario)
- (NSURL *)getUrlForProfileWithEmail:(NSString *)email;

// Url para obtener las prendas de un usuario (Mis Fotos)
- (NSURL *)getUrlForProfilePicturesFromEmail:(NSString *)email withOffset:(int)offset;

// Url para obtener las prendas que quiere un usuario (Lo Quiero)
- (NSURL *)getUrlForIWantPicturesFromEmail:(NSString *)email withOffset:(int)offset;

// Url para obtener una lista con los usuarios siguen de un usuario deteminado (Quien me sigue)
- (NSURL *)getUrlForFollowingFromEmail:(NSString *)email withOffset:(int)offset;

// Url para obtener una lista con usuarios que un determinado usuario esta siguiendo (A quien sigo)
- (NSURL *)getUrlForFollowersFromEmail:(NSString *)email withOffset:(int)offset;

// Url para obtener el resumen de un usuario, un numero para cada categoria del perfil del usuario (imagenes, lo quiero, siguiendo, seguidores y otros)
- (NSURL *)getUrlSummaryFromEmail:(NSString *)email;

// Url para seguir un usuario
- (NSURL *)getUrlForFollowUserWithEmail:(NSString *)emailFriend email:(NSString *)email;

// Url para dejar de seguir un usuario
- (NSURL *)getUrlForUnfollowUserWithEmail:(NSString *)getUrlForUnfollowUserWithEmail email:(NSString *)email;

// Url para borrar una prenda
- (NSURL *)getUrlForDeletePicture:(NSString *)picture_id
                        withEmail:(NSString *)email;

// Url para denunciar una imagen
- (NSURL *)getUrlForReportPicture:(NSString *)picture_id
                           reason:(NSString *)reason
                        withEmail:(NSString *)email;

// Url para indicar que quiero una prenda
- (NSURL *)getUrlForIWant:(NSString *)email picture_id:(NSString *)picture_id;

// Url para indicar que ya no quiero una prenda
- (NSURL *)getUrlForNotIWant:(NSString *)email picture_id:(NSString *)picture_id;

// Url para saber si un usuario quiere o no una prenda
- (NSURL *)getUrlForLikeWant:(NSString *)email picture_id:(NSString *)picture_id;

// Url para agregar una nuevo comentario a una prenda
// @param   comment             Contenido del mensaje que se quiere agregar.
// @param   picture_id          Id de la prenda/imagen a la que se ingresar el comentario.
// @param   commentAuthorName   Nombre del usuario que quiere agregar el comentario.
// @param   commentAuthorEmail  Email del usuario que quiere agregar el comentario.
//
// Que se quiere agregar | Donde se quiere agregar | Quien lo quiere agregar
- (NSURL *)getUrlForComment:(NSString *)comment
                 forPicture:(NSString *)picture_id
          commentAuthorName:(NSString *)commentAuthorName
         commentAuthorEmail:(NSString *)commentAuthorEmail;

// Url para obtener una lista con los comentarios en una prenda
- (NSURL *)getUrlForCommentsInto:(NSString *)picture_id;

// Url para borrar un comentario
- (NSURL *)getUrlForDeleteComment:(NSString *)commentId;

// Url para obtener el detalle de una prenda
- (NSURL *)getUrlForPictureDetails:(NSString *)picture_id;


// Url para obtener un listado con otros productos en una tienda
// @param   picture_id      Id del producto/imagen/post, esto es para excluir este de la lista de resultados que entrega la API
// @param   store_name      Nombre de la tienda
- (NSURL *)getUrlForAnotherPictures:(NSString *)picture_id inStore:(NSString *)store_name;


// Url para actualizar los datos de una usuairo
// @param   email       Correo actual eletronico del usuario
// @param   username    Nuevo nombre de Usuario o Nickname
// @param   nombre      Nuevo nombre
// @param   url         Nueva url
// @param   sexo        Nuevo sexo (Masculino, Femenino)
- (NSURL *)getUrlForUpdateUser:(NSString *)email username:(NSString *)username name:(NSString *)name url:(NSString *)url sex:(NSString *)sex;

// Url para actualizar la contraseña de un usuario
// @param   email       Correo del usuario
// @param   newpass     Nueva contraseña
- (NSURL *)getUrlForUpdateUser:(NSString *)email withPassword:(NSString *)newpass;

// Url para obtener el ranking de un usuario
// @param   email       Correo del usuario
- (NSURL *)getUrlForUserRanking:(NSString *)email;

// Url para obtener las notificaciones de un usuario
- (NSURL *)getUrlForNotificationsFromUserEmail:(NSString *)email
                                    withOffset:(int)offset;

// URL para marcar notificación leída
- (NSURL *)getUrlForMarkReadNotificationWithId:(NSString *)notificationId;

// URL para obtener el número de notificaciones no leídas
- (NSURL *)getUrlForUnreadNotificationsCount;

@end
