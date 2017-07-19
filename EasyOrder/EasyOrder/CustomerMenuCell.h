//
//  CustomerMenuCell.h
//  EasyOrder
//
//  Created by Yu Zhou on 7/19/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *quantity;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

@end
