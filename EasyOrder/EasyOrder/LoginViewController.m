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

- (void)fetchAccessTokenAndPassToDestinationController:(id) controller {
    
    // Create an account store
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request Access to the twitter account
    [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error1){
        
        if (granted) {
            
            // Create an Account
            ACAccount *twitterAccount = [[ACAccount alloc] initWithAccountType:twitterAccountType];
            NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
            twitterAccount = [accounts lastObject];
            
            // Create an NSURL instance variable as Twitter status_update end point.
            NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
            
            // Create a request
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                              requestMethod:SLRequestMethodPOST
                                                                        URL:twitterPostURL
                                                                 parameters:nil];
            
            // Set the account to be used with the request
            [request setAccount:twitterAccount];
            
            NSURLRequest* urlRequest = [request preparedURLRequest];
            NSDictionary* httpHeaderFields = [urlRequest allHTTPHeaderFields];
            
            NSString* oAuthHeader = httpHeaderFields[@"Authorization"];
            NSArray* oAuthHeaderParams = [oAuthHeader componentsSeparatedByString:@","];
            
            NSString *accessToken = nil;
            for (NSString* param in oAuthHeaderParams) {
                if ([param rangeOfString:@"oauth_token"].length > 0) {
                    accessToken = [[[param componentsSeparatedByString:@"="] objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    
                    NSLog(@"AccessToken: %@", accessToken);
                    [controller setAccessToken:accessToken];
                    [self presentViewController:controller animated:YES completion:nil];
                    break;
                }
            }
            
        } // If permission is granted
        else {
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"HW8yulunt Alert!"
                                                                           message:@"You must grant access to your Twitter account."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        } // If permission is not granted, do some error handling ...
        
    }];// end of requestAccessToAccountsWithType: ^block
}

- (IBAction)signInAsCustomer:(id)sender {
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerTabBarController"];
    [self fetchAccessTokenAndPassToDestinationController:controller];
}

@end
