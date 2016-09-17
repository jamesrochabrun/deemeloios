//
//  User.m
//  Deemelo
//
//  Created by Cesar Ortiz on 03-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize idUser, userName, email, name, status, url, userDescription, routeThumbnail, facebook_id, token;

- (NSString *)description
{
    NSString *UserDescriptionString = [NSString stringWithFormat:@"User:\n idUser:%d\n userName:%@\n email:%@\n name:%@\n status:%@\n url:%@\n userDescription:%@\n routeThumbnail:%@\n facebook_id:%@\n token:%@", idUser, userName, email, name, status, url, userDescription, routeThumbnail, facebook_id, token];
    
    return UserDescriptionString;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:[self idUser]
                   forKey:@"idUser"];
    
    [aCoder encodeObject:[self userName]
                  forKey:@"userName"];
    
    [aCoder encodeObject:[self email]
                  forKey:@"email"];
    
    [aCoder encodeObject:[self name]
                  forKey:@"name"];
    
    [aCoder encodeObject:[self status]
                  forKey:@"status"];
    
    [aCoder encodeObject:[self url]
                  forKey:@"url"];
    
    [aCoder encodeObject:[self userDescription]
                  forKey:@"userDescription"];
    
    [aCoder encodeObject:[self routeThumbnail]
                  forKey:@"routeThumbnail"];
    
    [aCoder encodeObject:[self facebook_id]
                  forKey:@"facebook_id"];
    
    [aCoder encodeObject:[self token]
                  forKey:@"token"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setIdUser:[aDecoder decodeIntegerForKey:@"idUser"]];
        [self setUserName:[aDecoder decodeObjectForKey:@"userName"]];
        [self setEmail:[aDecoder decodeObjectForKey:@"email"]];
        [self setName:[aDecoder decodeObjectForKey:@"name"]];
        [self setStatus:[aDecoder decodeObjectForKey:@"status"]];
        [self setUrl:[aDecoder decodeObjectForKey:@"url"]];
        [self setUserDescription:[aDecoder decodeObjectForKey:@"userDescription"]];
        [self setRouteThumbnail:[aDecoder decodeObjectForKey:@"routeThumbnail"]];
        [self setFacebook_id:[aDecoder decodeObjectForKey:@"facebook_id"]];
        [self setToken:[aDecoder decodeObjectForKey:@"token"]];
    }
    return self;
}

@end
