//
//  CustomerMenuCell.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/19/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerMenuCell.h"

@interface CustomerMenuCell() {
    HCSStarRatingView *_ratingView;
}

@end

@implementation CustomerMenuCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
    _count = 0;
    _quantity.text = [NSString stringWithFormat:@"%ld", _count];
    
    _ratingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(0, 0, 150, 15)];
    _ratingView.maximumValue = 5;
    _ratingView.minimumValue = 0;
    _ratingView.value = 0;
    _ratingView.allowsHalfStars = YES;
    _ratingView.tintColor = UIColor.orangeColor;
    [_ratingView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
    [_ratingViewHolder addSubview:_ratingView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)add:(id)sender {
    _count++;
    _quantity.text = [NSString stringWithFormat:@"%ld", _count];
    [_delegate onMenuItemChange:self];
}

- (IBAction)remove:(id)sender {
    if (_count > 0) {
        _count--;
        _quantity.text = [NSString stringWithFormat:@"%ld", _count];
        [_delegate onMenuItemChange:self];
    }
}

- (IBAction)didChangeValue:(HCSStarRatingView *)sender {
    NSLog(@"Changed rating to %.1f", sender.value);
    [_delegate onRatingChangeAt:self.position withRate:sender.value];
}

- (void)setRating:(double) rate{
    _ratingView.value = rate;
    [_ratingView setNeedsLayout];
}

@end
