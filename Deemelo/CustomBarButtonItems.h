//
//  CustomBarButtonItems.h
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomBarButtonItems : NSObject

+(UIView *) titleView:(UINavigationBar*)navBar view:(UIView*)view;
+(UIBarButtonItem *) rightBarButtonWithImageName:(NSString*)imageName;
+(UIBarButtonItem *) rightBarButtonWithImageName:(NSString*)imageName andBadget:(NSString *)badget;
+(UIBarButtonItem *) backBarButtonWithImageName:(NSString*)imageName;

@end
