//
//  CustomBarButtonItems.m
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "CustomBarButtonItems.h"

@implementation CustomBarButtonItems

+(UIView *) titleView:(UINavigationBar*)navBar view:(UIView*)view {
    CGFloat navBarHeight = navBar.frame.size.height;
    CGFloat navBarWidth = view.superview.frame.size.width;
    //CGFloat width = 0.95 * view.frame.size.width;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, navBarWidth, navBarHeight)];
    UIImage *logo = [UIImage imageNamed:@"logo.png"];
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:logo];
    CGFloat logoX = floorf((navBarWidth - logo.size.width) / 2.0f);
    CGFloat logoY = floorf((navBarHeight - logo.size.height) / 2.0f);
    [logoImage setFrame:CGRectMake(logoX, logoY, logo.size.width, logo.size.height)];
    [logoImage setImage:logo];
    [containerView addSubview:logoImage];
    return containerView;
}

+(UIBarButtonItem *) rightBarButtonWithImageName:(NSString*)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0 , 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButton;
}

+(UIBarButtonItem *) rightBarButtonWithImageName:(NSString*)imageName andBadget:(NSString *)badget
{
    UIImageView *starImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [starImageView setFrame:CGRectMake(5 , 5, 15, 15)];
    
    UILabel *badgetLabel = [[UILabel alloc] init];
    [badgetLabel setText:badget];
    [badgetLabel setTextAlignment:NSTextAlignmentCenter];
    [badgetLabel setTextColor:[UIColor whiteColor]];
    [badgetLabel setBackgroundColor:[UIColor clearColor]];
    [badgetLabel setFrame:CGRectMake(15 , 5, 50, 15)];
    [badgetLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [badgetLabel setTextAlignment:NSTextAlignmentRight];
    
    UIView *badgetContainer = [[UIView alloc] initWithFrame:CGRectMake(0 , 0, 80, 25)];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seguir.png"]];
    [backgroundImage setFrame:CGRectMake(0 , 0, 80, 25)];
    
    [badgetContainer addSubview:backgroundImage];
    [badgetContainer addSubview:starImageView];
    [badgetContainer addSubview:badgetLabel];
    
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:badgetContainer];
    return barButton;
}

+(UIBarButtonItem *) backBarButtonWithImageName:(NSString*)imageName {
    
    UIImage *image = [UIImage imageNamed:imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0 , 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButton;
}

@end
