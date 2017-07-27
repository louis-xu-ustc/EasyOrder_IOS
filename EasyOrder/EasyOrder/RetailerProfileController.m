//
//  RetailerProfileController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/27/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "RetailerProfileController.h"
#import "RetailerTabBarController.h"

@interface RetailerProfileController ()

@end

@implementation RetailerProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(0, _profileImage.frame.size.height-bottomBorder.borderWidth, _profileImage.frame.size.width, 1);
    _profileImage.clipsToBounds = YES;
    [_profileImage.layer addSublayer:bottomBorder];
    
    // set profile image and name
    RetailerTabBarController *controller = (RetailerTabBarController *)self.tabBarController;
    _profileName.text = controller.profileUserName;
    _profileImage.image = controller.profileImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logout:(id)sender {
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}
@end
