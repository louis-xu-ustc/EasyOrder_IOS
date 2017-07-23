//
//  CustomerMenuCell.h
//  EasyOrder
//
//  Created by Yu Zhou on 7/19/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HCSStarRatingView.h>

@protocol CustomerMenuCellDelegate;

@interface CustomerMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *ratingViewHolder;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (nonatomic, weak, nullable) id <CustomerMenuCellDelegate> delegate;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) NSInteger position;

@end

@protocol CustomerMenuCellDelegate <NSObject>

- (void)onMenuItemChange:(CustomerMenuCell *)cell;

@end
