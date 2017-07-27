//
//  RetailerTabBarController.h
//  EasyOrder
//
//  Created by Yu Zhou on 7/27/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RetailerTabBarController : UITabBarController

@property (strong, nonatomic) NSString *baseUrlStr;
@property (strong, nonatomic) NSString *profileImageUrlStr;
@property (strong, nonatomic) NSString *profileUserName;
@property (strong, nonatomic) UIImage *profileImage;
@property (assign, nonatomic) long long userId;

@end
