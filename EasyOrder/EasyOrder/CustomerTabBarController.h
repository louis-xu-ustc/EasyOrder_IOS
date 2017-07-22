//
//  CustomerTabBarController.h
//  EasyOrder
//
//  Created by Yu-Lun Tsai on 20/07/2017.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerTabBarController : UITabBarController

@property (strong, nonatomic) NSString *profileUserName;
@property (strong, nonatomic) UIImage *profileImage;
@property (assign, nonatomic) long long userId;

@end
