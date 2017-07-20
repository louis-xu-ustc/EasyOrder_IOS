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
    
    [self fetchUserProfile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// assume that the twitter credential is acquired
- (void)fetchUserProfile {
    
    // Create an account store
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Get twitter account
    ACAccount *twitterAccount = [[ACAccount alloc] initWithAccountType:twitterAccountType];
    NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
    twitterAccount = [accounts lastObject];
    
    // Create an NSURL instance variable as Twitter status_update end point.
    NSURL *twitterGetProfileURL = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/users/show.json"];
    NSDictionary *params = @{@"screen_name": twitterAccount.username};
    
    // Create a request
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:twitterGetProfileURL
                                               parameters:params];
    
    // Set the account to be used with the request
    [request setAccount:twitterAccount];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if(error == nil){
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:kNilOptions
                                                                   error:&error];
            
            _profileUserName = [json objectForKey:@"name"];
            
            NSString *urlString = [json objectForKey:@"profile_image_url_https"];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_normal" options:NSRegularExpressionCaseInsensitive error:&error];
            NSString *modifiedString = [regex stringByReplacingMatchesInString:urlString options:0 range:NSMakeRange(0, [urlString length]) withTemplate:@""];
            
            NSURL *url = [NSURL URLWithString:modifiedString];
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
            
            NSLog(@"%@", json);
        }
        else{
            NSLog(@"An error occurs here.");
        }
    }];
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
