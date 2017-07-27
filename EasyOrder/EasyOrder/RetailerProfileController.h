//
//  RetailerProfileController.h
//  EasyOrder
//
//  Created by Yu Zhou on 7/27/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RetailerProfileController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

- (IBAction)logout:(id)sender;

@end
