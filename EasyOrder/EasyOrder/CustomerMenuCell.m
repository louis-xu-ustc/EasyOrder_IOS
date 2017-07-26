//
//  CustomerMenuCell.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/19/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerMenuCell.h"

@interface CustomerMenuCell() {
    HCSStarRatingView *ratingView;
}

@end

@implementation CustomerMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _count = 0;
    _quantity.text = [NSString stringWithFormat:@"%ld", _count];
    
    ratingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(10, 5, 150, 15)];
    ratingView.maximumValue = 5;
    ratingView.minimumValue = 0;
    ratingView.value = 0;
    ratingView.tintColor = UIColor.orangeColor;
    [ratingView addTarget:self action:@selector(didChangeValueForKey:) forControlEvents:UIControlEventValueChanged];
    [_ratingViewHolder addSubview:ratingView];
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
@end
