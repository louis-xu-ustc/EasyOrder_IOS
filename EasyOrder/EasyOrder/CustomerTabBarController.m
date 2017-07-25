//
//  CustomerTabBarController.m
//  EasyOrder
//
//  Created by Yu-Lun Tsai on 20/07/2017.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerTabBarController.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface CustomerTabBarController ()

@end

@implementation CustomerTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
//    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
//    _baseUrlStr = [dict objectForKey:@"EasyOrder Base URL"];
//    NSLog(@"Base URL: %@", _baseUrlStr);
    
    [self fetchUserProfileImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// assume that the twitter credential is acquired
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
