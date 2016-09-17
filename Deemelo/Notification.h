//
//  Notification.h
//  Deemelo
//
//  Created by Pablo Branchi on 9/4/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property (nonatomic, strong) NSString *notificationId;
@property (nonatomic) NSUInteger type;
@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, strong) NSString *callerEmail;
@property (nonatomic, strong) NSString *callerName;
@property (nonatomic, strong) NSString *callerThumbnailURL;
@property (nonatomic) NSUInteger read;

// los próximos properties son requeridos para mapear error del apiprovider
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *desc;

@end
