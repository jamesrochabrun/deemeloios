//
//  CategoriesCell.m
//  Deemelo
//
//  Created by Manuel Gomez on 27-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "CategoriesCell.h"

@implementation CategoriesCell

@synthesize image, label;

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

@end
