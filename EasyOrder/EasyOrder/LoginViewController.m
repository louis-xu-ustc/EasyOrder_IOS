//
//  ViewController.m
//  EasyOrder
//
//  Created by Yu-Lun Tsai on 05/07/2017.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "LoginViewController.h"

#import "CustomerTabBarController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchCredentialAndPassToDestinationController:(NSString *)identifier {
    
    // Create an account store
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request Access to the twitter account
    [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error1){
        
        if (granted) {
            
            // Create an Account
            ACAccount *twitter = [[ACAccount alloc] initWithAccountType:twitterAccountType];
            NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
            twitter = [accounts lastObject];
            
            // Create an NSURL instance variable as Twitter status_update end point.
            NSURL *twitterGetProfileURL = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/users/show.json"];
            NSDictionary *params = @{@"screen_name": twitter.username};
            
            // Create a request
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodGET
                                                              URL:twitterGetProfileURL
                                                       parameters:params];
            
            // Set the account to be used with the request
            [request setAccount:twitter];
            [request performRequestWithHandler:^(NSData *dataResp, NSHTTPURLResponse *urlResp, NSError *error) {
                
                if(error == nil){
                    
                    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataResp options:kNilOptions error:&error];
                    
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_normal" options:NSRegularExpressionCaseInsensitive error:&error];
                    
                    NSString *profileNameStr = [dict objectForKey:@"name"];
                    NSString *userIdStr = [dict objectForKey:@"id_str"];
                    NSString *rawImageUrlStr = [dict objectForKey:@"profile_image_url_https"];
                    NSString *profileImageUrlStr = [regex stringByReplacingMatchesInString:rawImageUrlStr options:0 range:NSMakeRange(0, [rawImageUrlStr length]) withTemplate:@""];
                    NSLog(@"UserInfo: %@, %@, %@", profileNameStr, userIdStr, profileImageUrlStr);
                    
                    // create an user on server with twitter credentials, authentication can be done in the future
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
                    
                    dict = [NSDictionary dictionaryWithContentsOfFile:path];
                    NSString *baseUrlStr = [dict objectForKey:@"EasyOrder Base URL"];
                    NSURL *registerUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/backend/user/",baseUrlStr]];
                    
                    dict = @{@"twitterID":[NSNumber numberWithLongLong:[userIdStr longLongValue]], @"name":profileNameStr};
                    NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
                    if (json) {
                        // process the data
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:registerUrl];
                        
                        [request setHTTPMethod:@"POST"];
                        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                        [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
                        [request setHTTPBody: json];
                        
                        NSURLSession *session = [NSURLSession sharedSession];
                        [[session dataTaskWithRequest:request
                                    completionHandler:^(NSData *dataResp2, NSURLResponse *urlResp2, NSError *error)
                          {
                              // handle response in the background thread
                              if (dataResp2.length > 0 && error == nil) {
                                  
                                  NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) urlResp2;
                                  NSDictionary *dist = [NSJSONSerialization JSONObjectWithData:dataResp2 options:0 error:&error];
                                  NSString *message = [dist objectForKey:@"message"];
                                  NSLog(@"Response: %@", message);
                                  
                                  // registration and authentication success
                                  if(httpResp.statusCode == 200 || httpResp.statusCode == 201){
                                      UITabBarController *controller = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
                                      if ([identifier isEqualToString:@"CustomerTabBarController"]) {
                                          [(CustomerTabBarController *)controller setBaseUrlStr:baseUrlStr];
                                          [(CustomerTabBarController *)controller setProfileImageUrlStr:profileImageUrlStr];
                                          [(CustomerTabBarController *)controller setProfileUserName:profileNameStr];
                                          [(CustomerTabBarController *)controller setUserId:[userIdStr longLongValue]];
                                      }
                                      [self showViewController:controller sender:self];
                                  }
                              }
                              else if(error) {
                                  NSLog(@"Error(%li): %@", error.code, error.description);
                              }
                          }] resume];
                    }
                }
                else{
                    NSLog(@"Error(%li): %@", error.code, error.description);
                }
            }];
            
        } // If permission is granted
        else {
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"EasyOrder Alert!"
                                                                           message:@"You must grant access to your Twitter account."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        } // If permission is not granted, do some error handling ...
        
    }];// end of requestAccessToAccountsWithType: ^block
}

- (IBAction)signInAsCustomer:(id)sender {
    [self fetchCredentialAndPassToDestinationController:@"CustomerTabBarController"];
}

- (IBAction)signInAsRetailer:(id)sender {
    [self fetchCredentialAndPassToDestinationController:@"RetailerTabBarController"];
}

@end
