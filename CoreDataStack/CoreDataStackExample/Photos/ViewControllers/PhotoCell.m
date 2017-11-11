//
//  PhotoCell.m
//  CoreDataTest
//
//  Created by Towhid Islam on 1/25/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import "PhotoCell.h"
#import "PhotoGrapher.h"

@implementation PhotoCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.thumbnailView.layer.masksToBounds = YES;
    self.thumbnailView.layer.cornerRadius = 2.80f;
    self.thumbnailView.layer.borderWidth = 1.0f;
}

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

- (void)updateCell:(Photo *)photo{
    self.title.text = photo.title;
    //
    if (photo.whoTook.name != nil) {
        self.detail.text = [NSString stringWithFormat:@"taken by %@, Total taken %lu",photo.whoTook.name,(unsigned long)photo.whoTook.photos.count];
    }else{
        self.detail.text = [NSString stringWithFormat:@"at location %@",photo.location];
    }
}

@end
