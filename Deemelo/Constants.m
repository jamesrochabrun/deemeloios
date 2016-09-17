//
//  Constants.m
//  Deemelo
//
//  Created by Manuel Gomez on 17-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "Constants.h"
#import "AppDelegate.h"

@implementation Constants

NSString * const serverURL = @"http://deemelo.com/?page_id=17";

NSString * const FollowUserNotification = @"Comienzo a seguir";
NSString * const UnfollowUserNotification = @"Dejo de seguir";

NSString * const IWantPictureNotification = @"Quiero una nueva prenda";
NSString * const NotWantPictureNotification = @"No quiero una prenda";

NSString * const UserUpdatedNotification = @"Datos de usuario actualizados";

NSString * const AddedPictureNotification = @"AddedPictureNotification";
NSString * const DeletedPictureNotification = @"DeletedPictureNotification";

+ (NSString *)URLStringWithoutToken
{
    return [NSString stringWithFormat:@"%@&op=", serverURL];
}

+ (NSString *)URLStringWithToken
{
    AppDelegate* sharedApp = [AppDelegate sharedAppdelegate];
    return [NSString stringWithFormat:@"%@&token=%@&op=", serverURL, [[sharedApp currentUser] token]];
}

- (NSURL *)getUrlForValidateToken:(NSString *)token
{
    // SAMPLE: http://deemelo.com/?page_id=17&op=contarnotificaciones&token=jcO6k3qcoeSSsrH2YyKy27jrOShenS32YHWx2CMMT3
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@contarnotificaciones&token=%@", [Constants URLStringWithoutToken], token]];
}

- (NSURL *)getUrlForFrontSearchClothesPicturesFromSearchType:(NSString *)searchType
                                                searchString:(NSString *)searchString
                                                    latitude:(double)latitude
                                                   longitude:(double)longitude
                                                      offset:(int)offset
{
    // SAMPLE: http://deemelo.com/?page_id=17&token=wb6fR5SDPIUsrslYx1KWpqj8IlfyKVFjaBueeJnWmk&op=getresultvitrinea&terms=abrigo&tax=prenda&tipo=cercanas&lat=-33.419550&lng=-70.601599&offset=0
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@getresultvitrinea&terms=%@&tax=prenda&tipo=%@&lat=%f&lng=%f&offset=%d", [Constants URLStringWithToken], searchString, searchType, latitude, longitude, offset] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForGetNearClothesFromLatitude:(double)latitude
                                  andLongitude:(double)longitude
                                    withOffset:(int)offset
{
    // SAMPLE: http://deemelo.com/?page_id=17&token=wb6fR5SDPIUsrslYx1KWpqj8IlfyKVFjaBueeJnWmk&op=prendascercanas&lat=-33.419550&lng=-70.601599&offset=0
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@prendascercanas&lat=%f&lng=%f&offset=%d", [Constants URLStringWithToken], latitude, longitude, offset] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForGetStoresFromLatitude:(double)latitude
                             andLongitude:(double)longitude
{
    // SAMPLE: http://deemelo.com/?page_id=17&token=JfyVgbexsPAduqpbqtB9YdlKVT6fML1axddyik3amH&op=gettienda&lat=-33.419550&lng=-70.601599
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@gettienda&lat=%f&lng=%f", [Constants URLStringWithToken], latitude, longitude] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForGetStoresWithCategoryName:(NSString *)categoryName
                                 fromLatitude:(double)latitude
                                 andLongitude:(double)longitude
{
    // SAMPLE: http://deemelo.com/?page_id=17&token=DkRkaWv0CYeI7dcte9r62OP7ZSU9hGAtwINpF9x02J&op=buscarprendamapa&prenda=abrigo&lat=-33.419550&lng=-70.601599
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@buscarprendamapa&prenda=%@&lat=%f&lng=%f", [Constants URLStringWithToken], categoryName, latitude, longitude] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForProfileWithEmail:(NSString *)email
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=getinfoperfil&email=test@acid.cl
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@getinfoperfil&email=%@", [Constants URLStringWithToken], email]];
}

- (NSURL *)getUrlForProfilePicturesFromEmail:(NSString *)email withOffset:(int)offset
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=getpostlistimage&email=test@acid.cl&offset=a
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@getpostlistimage&email=%@&offset=%d", [Constants URLStringWithToken], email, offset]];
}

- (NSURL *)getUrlForIWantPicturesFromEmail:(NSString *)email withOffset:(int)offset
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=getloquiero&email=test@acid.cl&offset=a
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@getloquiero&email=%@&offset=%d", [Constants URLStringWithToken], email, offset]];
}


- (NSURL *)getUrlForFollowingFromEmail:(NSString *)email withOffset:(int)offset
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=quienessigo&email=test@acid.cl&offset=a
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@quienessigo&email=%@&offset=%d", [Constants URLStringWithToken], email, offset]];
}

- (NSURL *)getUrlForFollowersFromEmail:(NSString *)email withOffset:(int)offset
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=quienesmesiguen&email=test@acid.cl&offset=a
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@quienesmesiguen&email=%@&offset=%d", [Constants URLStringWithToken], email, offset]];
}

- (NSURL *)getUrlSummaryFromEmail:(NSString *)email
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=count&email=test@acid.cl
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@count&email=%@", [Constants URLStringWithToken], email]];
}


- (NSURL *)getUrlForFollowUserWithEmail:(NSString *)emailFriend email:(NSString *)email
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=seguirfriend&u_email=test@acid.cl&emailfriend=friend@acid.cl
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@seguirfriend&u_email=%@&emailfriend=%@", [Constants URLStringWithToken], email, emailFriend]];
}

- (NSURL *)getUrlForUnfollowUserWithEmail:(NSString *)emailFriend email:(NSString *)email
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=noseguirfriend&u_email=test@acid.cl&emailfriend=friend@acid.cl
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@noseguirfriend&u_email=%@&emailfriend=%@", [Constants URLStringWithToken], email, emailFriend]];
}

- (NSURL *)getUrlForDeletePicture:(NSString *)picture_id
                        withEmail:(NSString *)email
{
    // SAMPLE: http://deemelo.com/?page_id=17&op=eliminarpost&post_id=288&email=123@123.com
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@eliminarpost&post_id=%@&email=%@", [Constants URLStringWithToken], picture_id, email]];
}

- (NSURL *)getUrlForReportPicture:(NSString *)picture_id
                           reason:(NSString *)reason
                        withEmail:(NSString *)email
{
    // SAMPLE: http://deemelo.com/?page_id=17&op=denunciarimagen&post_id=229&motivo=motivo&denunciante=123@123.com
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@denunciarimagen&post_id=%@&motivo=%@&email=%@", [Constants URLStringWithToken], picture_id, reason, email] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForIWant:(NSString *)email picture_id:(NSString *)picture_id
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=loquiero&email=test@acid.cl&post_id=1
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@loquiero&email=%@&post_id=%@", [Constants URLStringWithToken], email, picture_id]];
}


- (NSURL *)getUrlForNotIWant:(NSString *)email picture_id:(NSString *)picture_id
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=noloquiero&email=test@acid.cl&post_id=1
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@noloquiero&email=%@&post_id=%@", [Constants URLStringWithToken], email, picture_id]];
}

- (NSURL *)getUrlForLikeWant:(NSString *)email picture_id:(NSString *)picture_id
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=megustaloquiero&email=test@acid.cl&post_id=1
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@megustaloquiero&email=%@&post_id=%@", [Constants URLStringWithToken], email, picture_id]];
}

- (NSURL *)getUrlForComment:(NSString *)comment
                 forPicture:(NSString *)picture_id
          commentAuthorName:(NSString *)commentAuthorName
         commentAuthorEmail:(NSString *)commentAuthorEmail
{
    // SAMPLE: http://deemelo.com/?page_id=17&op=newcomentario&content=a&post_id=263&user=123&email=123@123.com
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@newcomentario&content=%@&post_id=%@&user=%@&email=%@", [Constants URLStringWithToken], comment, picture_id, commentAuthorName, commentAuthorEmail] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForCommentsInto:(NSString *)picture_id
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=getcomentario&post_id=1
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@getcomentario&post_id=%@", [Constants URLStringWithToken], picture_id] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForDeleteComment:(NSString *)commentId
{
    // SAMPLE: http://deemelo.com/?page_id=17&token=wb6fR5SDPIUsrslYx1KWpqj8IlfyKVFjaBueeJnWmk&op=delcomentario&comment_id=0
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@delcomentario&comment_id=%@", [Constants URLStringWithToken], commentId] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForPictureDetails:(NSString *)picture_id
{
    // SAMPLE: http://deemelo.com/?page_id=12&op=getpostimage&id=1
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@getpostimage&id=%@", [Constants URLStringWithToken], picture_id] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForAnotherPictures:(NSString *)picture_id inStore:(NSString *)store_name
{
    // SAMPLE:  http://deemelo.com/?page_id=12&op=otrosprotienda&post_id=1&tienda=AcidLabs
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@otrosprotienda&post_id=%@&tienda=%@", [Constants URLStringWithToken], picture_id, store_name] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForUpdateUser:(NSString *)email username:(NSString *)username name:(NSString *)name url:(NSString *)url sex:(NSString *)sex
{
    // SAMPLE:  http://deemelo.com/?page_id=12&op=updateperfil&email=test@acid.cl&username=acid&nombre=Acid&url=http://www.acid.cl&sexo=Masculino
    NSString *encoded_url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@updateperfil&email=%@&username=%@&nombre=%@&sexo=%@&url=%@", [Constants URLStringWithToken], email, username, name, sex, encoded_url] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForUpdateUser:(NSString *)email withPassword:(NSString *)newpass
{
    // SAMPLE:  http://deemelo.com/?page_id=12&op=updatepassword&email=test@acid.cl&newpass=123
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@updatepassword&email=%@&newpass=%@", [Constants URLStringWithToken], email, newpass] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForUserRanking:(NSString *)email
{
    // SAMPLE:  http://deemelo.com/?page_id=12&op=ranking&email=test@acid.cl
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@ranking&email=%@", [Constants URLStringWithToken], email] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
}

- (NSURL *)getUrlForNotificationsFromUserEmail:(NSString *)email
                                    withOffset:(int)offset
{
    // SAMPLE: http://deemelo.com/?page_id=17&op=getnotificaciones&email=test@acid.cl&offset=0
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@getnotificaciones&email=%@&offset=%d", [Constants URLStringWithToken], email, offset]];
}

- (NSURL *)getUrlForMarkReadNotificationWithId:(NSString *)notificationId
{
    // SAMPLE: http://deemelo.com/?page_id=17&op=marcanotificacionleida&id=29
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@marcanotificacionleida&id=%@", [Constants URLStringWithToken], notificationId]];
}

- (NSURL *)getUrlForUnreadNotificationsCount
{
    // SAMPLE: http://deemelo.com/?page_id=17&token=TuUCfZJUO8U3lNLiPZKgu3jS9lRPrIetqd9QHT1Wx6&op=contarnotificaciones
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@contarnotificaciones", [Constants URLStringWithToken]]];
}

@end
