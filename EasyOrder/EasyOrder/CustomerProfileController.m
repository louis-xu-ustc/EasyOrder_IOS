//
//  CustomerProfileController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/14/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerProfileController.h"
#import "CustomerTabBarController.h"

@interface CustomerProfileController ()
{
    __weak IBOutlet UIImageView *_profileImageView;
    __weak IBOutlet UILabel *_profileUserName;
    
    NSArray *_orders;
}
@end

@implementation CustomerProfileController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _orders.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
    
    NSDictionary *json = [_orders objectAtIndex:indexPath.row];
    UILabel *title = [cell viewWithTag:1];
    
    title.text = [json objectForKey:@"dish"];
    
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // add a bottom border to the table view
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(0, _profileView.frame.size.height-bottomBorder.borderWidth, _profileView.frame.size.width, 1);
    _profileView.clipsToBounds = YES;
    [_profileView.layer addSublayer:bottomBorder];
    
    // set profile image and name
    CustomerTabBarController *controller = (CustomerTabBarController *)self.tabBarController;
    _profileUserName.text = controller.profileUserName;
    _profileImageView.image = controller.profileImage;
}

- (void)viewDidAppear:(BOOL)animated {
    [self fetchHistoricalOrders];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchHistoricalOrders {
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/backend/order/history/%lld",[(CustomerTabBarController*)self.tabBarController baseUrlStr], [(CustomerTabBarController*)self.tabBarController userId]]] completionHandler:^(NSData *dataResp, NSURLResponse *urlResp, NSError *error)
      {
          // handle response in the background thread
          if (dataResp.length > 0 && error == nil) {
              _orders = [NSJSONSerialization JSONObjectWithData:dataResp options:0 error:NULL];
              if(_orders.count > 0) {
                  dispatch_async(dispatch_get_main_queue(),^{
                      [_tableView reloadData];
                  });
              } //end of if
          }
          else{
              NSLog(@"Error (%li): %@", error.code, error.description);
          }
      }] resume];
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
