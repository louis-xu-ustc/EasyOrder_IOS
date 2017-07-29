//
//  RetailerOrderController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/12/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "RetailerOrderController.h"

@interface RetailerOrderController () {
    NSTimer *_timer;
    NSArray *data;
}

@end

@implementation RetailerOrderController

- (void)refreshCustomers {
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:
      [NSURL URLWithString:@"http://54.202.127.83/backend/user/"]
            completionHandler:^(NSData *dataResp, NSURLResponse *urlResp, NSError *error)
      {
          // handle response in the background thread
          if (dataResp.length > 0 && error == nil) {
              data = [NSJSONSerialization JSONObjectWithData:dataResp options:0 error:NULL];
              
              if(data.count > 0) {
                  dispatch_async(dispatch_get_main_queue(),^{
                      [self.tableView reloadData];
                  });
              } //end of if
          }
          else if(error) {
              NSLog(@"Error(%li): %@", error.code, error.description);
          }
      }] resume];
}

- (void)viewDidAppear:(BOOL)animated {
    [self startBackgroundTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopBackgroundTimer];
}

- (void)startBackgroundTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(refreshCustomers) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopBackgroundTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self refreshCustomers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dict = [data objectAtIndex:indexPath.row];
    UILabel *name = [cell viewWithTag:1];
    UILabel *statusLabel = [cell viewWithTag:2];
    name.text = [dict objectForKey:@"name"];
    bool status = [[dict objectForKey:@"paid"] boolValue];
    if (status) {
        statusLabel.text = @"Paid";
        statusLabel.textColor = UIColor.greenColor;
    } else {
        statusLabel.text = @"Not Paid";
        statusLabel.textColor = UIColor.redColor;
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)poke:(id)sender {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:@"http://54.202.127.83/backend/notification/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"PUT"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"You haven't paid for your orders. Please pay." forKey:@"content"];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    [request setHTTPBody:data];
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Info" message:@"All customers are poked." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [dialog addAction:action];
            [self presentViewController:dialog animated:YES completion:nil];
        });
    }];
    [task resume];
}
@end
