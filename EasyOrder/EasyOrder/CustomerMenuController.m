//
//  CustomerMenuController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/14/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerMenuController.h"
#import "CustomerTabBarController.h"

@interface CustomerMenuController ()
{
    NSArray *_dishes;
}
@end

@implementation CustomerMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _data = [[NSMutableDictionary alloc] init];
    self.tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0);
    [self fetchLatestMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dishes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    [cell setPosition:indexPath.row];
    cell.delegate = self;
    
    // Configure the cell...
    
    NSDictionary *dish = [_dishes objectAtIndex: indexPath.row];
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"%@%@", [(CustomerTabBarController*)self.tabBarController baseUrlStr],[dish objectForKey:@"photo"]]];


    cell.title.text = [dish objectForKey:@"name"];
    cell.price.text = [NSString stringWithFormat:@"$ %@", [dish objectForKey:@"price"]];
    
    if (cell.imageView.image == nil) {
    
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        cell.imageView.image = image;
                        [cell setNeedsLayout];
                    });
                }
            }
        }];
        [task resume];
    }
    
    return cell;
}

- (void)fetchLatestMenu {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/backend/dish/",
                                                    [(CustomerTabBarController*)self.tabBarController baseUrlStr]]]
            completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {
                
                // handle response in the background thread
                if (data.length > 0 && error == nil) {
                    _dishes = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    
                    for(int i = 0; i < _dishes.count; i++){
                        NSDictionary *item = [_dishes objectAtIndex:i];
                        Dish *dish = [[Dish alloc] init];
                        dish.dishId = [[item objectForKey:@"id"] intValue];
                        dish.dishPrice = [[item objectForKey:@"price"] doubleValue];
                        dish.dishName = [item objectForKey:@"name"];
                        dish.dishNumber = 0;
                        [_data setObject:dish forKey:[NSString stringWithFormat:@"%d", i]];
                    }
                    
                    if(_dishes.count > 0) {
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self.tableView reloadData];
                        });
                    } //end of if
                }
                else if(error != nil) {
                    NSLog(@"Error (%li): %@", error.code, error.description);
                }
                
            }] resume];
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

- (void)onMenuItemChange:(CustomerMenuCell *)cell {
    Dish *dish = [_data objectForKey:[NSString stringWithFormat:@"%li", cell.position]];
    dish.dishNumber = cell.count;
}

- (IBAction)logout:(id)sender {
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cart:(id)sender {
    
    __block NSMutableDictionary *inputData = [[NSMutableDictionary alloc] init];
    int i = 0;
    for (id key in _data) {
        Dish *dish = [_data objectForKey:key];
        if (dish.dishNumber > 0) {
            [inputData setObject:dish forKey:[NSString stringWithFormat:@"%d", i]];
            i++;
        }
    }
    CustomerCartController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"cartTable"];
    [controller setData:inputData];
    
    CGRect rect = CGRectMake(0, 0, 330, 350);
    [controller setPreferredContentSize:rect.size];
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Order Details" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [dialog setValue:controller forKey:@"contentViewController"];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if(inputData.count > 0){
            
            // Upload data.
            CustomerTabBarController *controller = (CustomerTabBarController *)self.tabBarController;
            NSURL *postOrderUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/backend/order/bunch/", [(CustomerTabBarController*)self.tabBarController baseUrlStr]]];
            NSMutableArray *orders = [[NSMutableArray alloc] init];
            
            for(Dish *dish in [inputData allValues]){
                [orders addObject:@{@"dish":[NSNumber numberWithLong:dish.dishId], @"amount":[NSNumber numberWithLong:dish.dishNumber]}];
            }
            
            NSDictionary *dictionary = @{@"twitterID":[NSNumber numberWithLongLong:controller.userId],@"order":orders};
            NSError *error = [NSError alloc];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
            if (jsonData) {
                // process the data
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postOrderUrl];
            
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
                
                [request setHTTPBody: jsonData];
                
                NSURLSession *session = [NSURLSession sharedSession];
                [[session dataTaskWithRequest:request
                            completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error)
                {
                    
                    // handle response in the background thread
                    if (data.length > 0 && error == nil) {
                        
                        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) resp;
                        NSLog(@"HTTP status code: %ld", httpResp.statusCode);
                        NSDictionary *dist = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                        NSString *message = [dist objectForKey:@"message"];
                        NSLog(@"Response: %@", message);
                    }
                    else if(error != nil) {
                        NSLog(@"Error (%li): %@", error.code, error.domain);
                    }
                }] resume];
            }
        }
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [dialog addAction:confirm];
    [dialog addAction:cancel];
    [self presentViewController:dialog animated:YES completion:nil];
}

@end
