//
//  Dish.h
//  EasyOrder
//
//  Created by Yu-Lun Tsai on 18/07/2017.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dish : NSObject

@property (strong, nonatomic) NSString *dishName;
@property (strong, nonatomic) NSString *dishDesription;
@property (assign, nonatomic) NSInteger dishPrice;
@property (strong, nonatomic) NSString *dishNumber;

@end
