//
//  HistoricalOrderTableView.h
//  EasyOrder
//
//  Created by Yu-Lun Tsai on 21/07/2017.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoricalOrderTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *array;

@end
