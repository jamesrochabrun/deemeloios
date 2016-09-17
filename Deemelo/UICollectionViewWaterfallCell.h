//
//  UICollectionViewWaterfallCell.h
//  Demo
//
//  Created by Nelson on 12/11/27.
//  Copyright (c) 2012年 Nelson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ImageDetail.h"
#import "ItemDetailViewController.h"
//#import "FrontViewController.h"

@interface UICollectionViewWaterfallCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *productImageView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UIView *avatarImageContainerView;

@property (nonatomic, weak) ImageDetail *imageDetail;

- (void)formatProductImageView;
- (void)formatAvatarImageContainerView;

@end
