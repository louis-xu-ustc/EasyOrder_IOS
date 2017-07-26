//
//  CustomerTabBarController.m
//  EasyOrder
//
//  Created by Yu-Lun Tsai on 20/07/2017.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerTabBarController.h"

#import <UserNotifications/UserNotifications.h>

@interface CustomerTabBarController ()
{
    NSTimer *_timer;
}
@end

@implementation CustomerTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _timer = nil;
    
    [self fetchUserProfileImage];
    [self requestUserNotificationAuthorization];
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

- (void)requestUserNotificationAuthorization {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:
     (UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error)
    {
        if (error) {
            NSLog(@"Error(%ld): %@", error.code, error.description);
        }
    }];
}

- (void)generateLocalNotificationWithDetail:(NSString *)detail {
    
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        //App is in foreground. Act on it.
        
        UIAlertController* alert = [UIAlertController
                                    alertControllerWithTitle:@"EasyOrder"
                                    message:detail
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        // display a banner if the application runs in the background
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"EasyOrder"
                                                              arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:detail arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        
        // 4. update application icon badge number
        content.badge = [NSNumber numberWithInteger:([UIApplication sharedApplication].applicationIconBadgeNumber+1)];
        
        // Deliver the notification in five seconds.
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                      triggerWithTimeInterval:5.f
                                                      repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest
                                          requestWithIdentifier:@"FiveSecond"
                                          content:content
                                          trigger:trigger];
        /// 3. schedule localNotification
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error)
        {
            if (error) {
                NSLog(@"Error(%ld): %@", error.code, error.description);
            }
        }];
    }
}

- (void)fetchFirstNotification {
    
    if(!_timer){
    
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/backend/notification/", _baseUrlStr]] completionHandler:^(NSData *dataResp, NSURLResponse *urlResp, NSError *error)
        {
            if (dataResp.length > 0 && error == nil) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataResp options:0 error:&error];
                
                if(error == nil) {
                    _lastNotificationTime = [[json objectForKey:@"modified_at"] intValue];
                    bool new = [[json objectForKey:@"notification"] boolValue];
                    
                    if(new){
                        NSString *detail = [json objectForKey:@"content"];
                        [self generateLocalNotificationWithDetail:detail];
                        NSLog(@"Notification: %@, %ld", detail, _lastNotificationTime);
                    }
                    else{
                        NSLog(@"No new notification");
                    }
                    [self startCheckingNotification];
                } //end of if
            }
            else{
                NSLog(@"Error (%li): %@", error.code, error.description);
            }
        }]resume];
    }
}

- (void)checkLatestNotification {
        
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/backend/notification/%ld", _baseUrlStr, _lastNotificationTime]] completionHandler:^(NSData *dataResp, NSURLResponse *urlResp, NSError *error)
    {
        if (dataResp.length > 0 && error == nil) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataResp options:0 error:&error];
            
            if(error == nil) {
                bool new = [[json objectForKey:@"notification"] boolValue];
                if(new) {
                    NSString *detail = [json objectForKey:@"content"];
                    _lastNotificationTime = [[json objectForKey:@"modified_at"] intValue];
                    [self generateLocalNotificationWithDetail:detail];
                    NSLog(@"Notification: %@, %ld", detail, _lastNotificationTime);
                }
                else{
                    NSLog(@"No new notification");
                }
            } //end of if
        }
        else {
            NSLog(@"Error (%li): %@", error.code, error.description);
        }
    }]resume];
}


// Periodic update
- (void)startCheckingNotification {
    NSLog(@"Start pulling notification");
    
    if(!_timer){
        // NSTimer can be run only on the UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            _timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(checkLatestNotification)
                                                    userInfo:nil
                                                     repeats:YES];
        });
    }
}

- (void)stopCheckingNotification {
    NSLog(@"Stop pulling notification");
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
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
