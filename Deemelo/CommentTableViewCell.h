//
//  CommentTableViewCell.h
//  Deemelo
//
//  Created by Pablo Branchi on 8/30/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell

@property (weak, nonatomic) id controller;
@property (weak, nonatomic) UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (nonatomic, weak) IBOutlet UIView *avatarImageContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteCommentButton;

- (IBAction)deleteCommentButtonPressed:(id)sender;

@end
