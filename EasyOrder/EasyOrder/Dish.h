//
//  Dish.h
//  EasyOrder
//
//  Created by Yu-Lun Tsai on 18/07/2017.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Dish : NSObject

@property (strong, nonatomic) NSString *dishName;
@property (strong, nonatomic) NSString *dishDesription;
@property (assign, nonatomic) double dishPrice;
@property (assign, nonatomic) NSInteger dishNumber;
@property (assign, nonatomic) NSInteger dishId;
@property (retain, nonatomic) UIImage *dishImage;

@end
