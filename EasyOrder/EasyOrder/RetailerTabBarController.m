//
//  RetailerTabBarController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/27/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "RetailerTabBarController.h"

@interface RetailerTabBarController ()

@end

@implementation RetailerTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchUserProfileImage];
}

- (void)fetchUserProfileImage {
    
    NSURL *url = [NSURL URLWithString:_profileImageUrlStr];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _profileImage = image;
                });
            }
        }
    }];
    [task resume];
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

@end
