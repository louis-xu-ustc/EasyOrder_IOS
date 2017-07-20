//
//  CustomerMenuCell.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/19/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerMenuCell.h"

@interface CustomerMenuCell()
{
    int count;
}

@end

@implementation CustomerMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    count = 0;
    _quantity.text = [NSString stringWithFormat:@"%d", count];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)add:(id)sender {
    count++;
    _quantity.text = [NSString stringWithFormat:@"%d", count];
}

- (IBAction)remove:(id)sender {
    if (count > 0) {
        count--;
        _quantity.text = [NSString stringWithFormat:@"%d", count];
    }
}
@end