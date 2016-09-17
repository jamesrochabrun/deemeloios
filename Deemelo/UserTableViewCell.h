//
//  UserTableViewCell.h
//  Deemelo
//
//  Created by Pablo Branchi on 9/2/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *avatarImageContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
