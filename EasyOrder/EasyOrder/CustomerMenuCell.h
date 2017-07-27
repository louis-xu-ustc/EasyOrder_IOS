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

@property (weak, nonatomic, nullable) IBOutlet UIView *ratingViewHolder;
@property (weak, nonatomic, nullable) IBOutlet UIImageView *image;
@property (weak, nonatomic, nullable) IBOutlet UILabel *title;
@property (weak, nonatomic, nullable) IBOutlet UILabel *price;
@property (weak, nonatomic, nullable) IBOutlet UILabel *quantity;
@property (nonatomic, weak, nullable) id <CustomerMenuCellDelegate> delegate;

- (IBAction)add:(id _Nonnull )sender;
- (IBAction)remove:(id _Nonnull )sender;
- (void)setRating:(double) rate;

@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) NSInteger position;

@end

@protocol CustomerMenuCellDelegate <NSObject>

- (void)onMenuItemChange:(CustomerMenuCell *_Nonnull)cell;
- (void)onRatingChangeAt:(long)position withRate:(double)rate;

@end
