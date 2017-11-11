//
//  PhotoCell.h
//  CoreDataTest
//
//  Created by Towhid Islam on 1/25/14.
//  Copyright (c) 2014 Towhid Islam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *detail;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailView;
@end
