//
//  CustomerMenuCell.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/19/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerMenuCell.h"

@interface CustomerMenuCell()

@end

@implementation CustomerMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _count = 0;
    _quantity.text = [NSString stringWithFormat:@"%d", _count];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)add:(id)sender {
    _count++;
    _quantity.text = [NSString stringWithFormat:@"%d", _count];
    [_delegate onMenuItemChange:self];
}

- (IBAction)remove:(id)sender {
    if (_count > 0) {
        _count--;
        _quantity.text = [NSString stringWithFormat:@"%d", _count];
        [_delegate onMenuItemChange:self];
    }
}
@end
