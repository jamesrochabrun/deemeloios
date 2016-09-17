//
//  NotificationTableViewCell.h
//  Deemelo
//
//  Created by Pablo Branchi on 9/5/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *cellContainerView;
@property (nonatomic, weak) IBOutlet UIView *avatarImageContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@end
