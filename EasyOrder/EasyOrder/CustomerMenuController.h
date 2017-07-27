//
//  CustomerMenuController.h
//  EasyOrder
//
//  Created by Yu Zhou on 7/14/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerMenuCell.h"
#import "Dish.h"
#import "CustomerCartController.h"

@interface CustomerMenuController : UITableViewController <CustomerMenuCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *rowIndexDishMap;

- (IBAction)cart:(id)sender;

@end
