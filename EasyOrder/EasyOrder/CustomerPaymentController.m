//
//  CustomerPaymentController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/14/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerPaymentController.h"

#import "CustomerTabBarController.h"
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"

@interface CustomerPaymentController ()
{
    NSString *_clientToken;
    NSArray *_orders;
}
@end

@implementation CustomerPaymentController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _orders.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentCell" forIndexPath:indexPath];
    
    NSDictionary *order = [_orders objectAtIndex:indexPath.row];
    // tag 1: title, tag 2: amount
    UILabel *title = [cell viewWithTag:1];
    UILabel *amount = [cell viewWithTag:2];

    title.text = [order objectForKey:@"dish"];
    amount.text = [NSString stringWithFormat:@"%@", [order objectForKey:@"amount"]];
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self fetchClientToken];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchCurrentOrders];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchCurrentOrders {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:[NSURL URLWithString:
                               [NSString stringWithFormat:@"%@/backend/order/user/%lld",
                                [(CustomerTabBarController*)self.tabBarController baseUrlStr],
                                [(CustomerTabBarController*)self.tabBarController userId]]]
            completionHandler:^(NSData *dataResp, NSURLResponse *urlResp, NSError *error)
    {
        // handle response in the background thread
        if (dataResp.length > 0 && error == nil) {
            
            _orders = [NSJSONSerialization JSONObjectWithData:dataResp options:0 error:NULL];
            
            double sum = 0;
            for(int i = 0; i < _orders.count; i++){
                NSDictionary *order = [_orders objectAtIndex:i];
                sum += ([[order objectForKey:@"amount"] intValue]*[[order objectForKey:@"price"] doubleValue]);
            }
            
            if(_orders.count > 0) {
                dispatch_async(dispatch_get_main_queue(),^{
                    _totalPrice.text = [NSString stringWithFormat:@"$ %.2f", sum];
                    [_tableView reloadData];
                });
            } //end of if
        }
        else if(error != nil) {
            NSLog(@"Error (%li): %@", error.code, error.description);
        }
        
    }] resume];
}

- (void)fetchClientToken {
    
    // TODO: Switch this URL to your own authenticated API
    NSURL *clientTokenURL = [NSURL URLWithString:
                             [NSString stringWithFormat:@"%@/backend/payment/client_token",
                              [(CustomerTabBarController*)self.tabBarController baseUrlStr]]];
    NSMutableURLRequest *clientTokenRequest = [NSMutableURLRequest requestWithURL:clientTokenURL];
    [clientTokenRequest setValue:@"text/plain" forHTTPHeaderField:@"Accept"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:clientTokenRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // TODO: Handle errors
        if(error == nil){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if([httpResponse statusCode] == 200){
            
                _clientToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            else{
                // handle exception here
                NSLog(@"Server error while fetching client token");
            }
        }
        else {
            NSLog(@"Error(%li): %@", error.code, error.description);
        }
    }] resume];
}

- (void)showDropIn:(NSString *)clientTokenOrTokenizationKey {
    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:clientTokenOrTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"ERROR");
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
        } else {
            // Use the BTDropInResult properties to update your UI
            // result.paymentOptionType
            // result.paymentMethod
            // result.paymentIcon
            // result.paymentDescription
            
            NSString *nonce = result.paymentMethod.nonce;
            
            NSLog(@"Debug: %@", nonce);
            // process the nonce
            [self postNonceToServer:@"fake-valid-nonce"];
        }
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    [self presentViewController:dropIn animated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    
    CustomerTabBarController *controller = (CustomerTabBarController *)self.tabBarController;
    
    // Update URL with your server
    NSURL *paymentURL = [NSURL URLWithString:@"http://54.202.127.83/backend/payment/checkout/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paymentURL];
    request.HTTPBody = [[NSString stringWithFormat:@"payment_method_nonce=%@&user_id=%lli", paymentMethodNonce, controller.userId] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle success and failure
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

- (IBAction)logout:(id)sender {
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)makeAPayment:(id)sender {
    if([_clientToken length] > 0){
        [self showDropIn:_clientToken];
    }
}

@end
