//
//  CustomerPaymentController.h
//  EasyOrder
//
//  Created by Yu Zhou on 7/14/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerPaymentController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;

- (IBAction)makeAPayment:(id)sender;

@end
