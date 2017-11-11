//
//  PhotoCell.m
//  CoreDataTest
//
//  Created by Towhid Islam on 1/25/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
        self.title = title;
        
        UILabel *detail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.detail = detail;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.thumbnailView = imgView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
