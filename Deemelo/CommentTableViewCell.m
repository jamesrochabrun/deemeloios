//
//  CommentTableViewCell.m
//  Deemelo
//
//  Created by Pablo Branchi on 8/30/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "AppDelegate.h"

@implementation CommentTableViewCell

@synthesize controller, tableView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // formatear la imagen
    [self formatCommentTextView];
    
    // formatear el contenedor del avatar
    [self formatAvatarImageContainerView];
}

- (void)formatCommentTextView
{
    self.commentTextView.layer.cornerRadius = 12.0f;
//    self.commentTextView.layer.borderColor = [[UIColor colorWithRed:109/255 green:103/255 blue:98/255 alpha:0.1] CGColor];
//    self.commentTextView.layer.borderWidth = 1.0f;
    
    self.commentTextView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.commentTextView.layer.shadowRadius = 2.0f;
    self.commentTextView.layer.shadowOffset = CGSizeMake(-1.0f, 1.0f);
    self.commentTextView.layer.shadowOpacity = 0.2f;
}

- (void)formatAvatarImageContainerView
{
    self.avatarImageContainerView.layer.borderColor = [[UIColor colorWithRed:109/255 green:103/255 blue:98/255 alpha:0.1] CGColor];
    self.avatarImageContainerView.layer.borderWidth = 1.0f;
    
    self.avatarImageContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.avatarImageContainerView.layer.shadowRadius = 2.0f;
    self.avatarImageContainerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.avatarImageContainerView.layer.shadowOpacity = 0.2f;
}

- (IBAction)deleteCommentButtonPressed:(id)sender
{
    NSString *selector = NSStringFromSelector(_cmd);
    
    selector = [selector stringByAppendingString:@"atIndexPath:"];
    
    SEL newSelector = NSSelectorFromString(selector);
    
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:self];
    
    if (indexPath) {
        if ([[self controller] respondsToSelector:newSelector]) {
            [[self controller] performSelector:newSelector
                                    withObject:sender
                                    withObject:indexPath];
        }
    }
}

@end
