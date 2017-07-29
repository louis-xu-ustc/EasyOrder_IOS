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

    // initialize a hash map to track the index of each dish and its
    // corresponding object
    _rowIndexDishMap = [[NSMutableDictionary alloc] init];
    
    // reduce the left edge insets to adjust image to the left end
    self.tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0);
    [self fetchLatestMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dishes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // get the cell objects at the index path
    CustomerMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    
    // set the row index to the cell in order to keey track of amount and rate updates
    [cell setPosition:indexPath.row];
    
    // set the delegate to the current tableView controller, implementing a set of
    // protocol used to forward row change information
    cell.delegate = self;
    
    // Configure the cell...
    NSDictionary *dish = [_dishes objectAtIndex: indexPath.row];
    
    // fetch the image url and initiate an async NSURLSession to gether dish images
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"%@%@", [(CustomerTabBarController*)self.tabBarController baseUrlStr],[dish objectForKey:@"photo"]]];

    cell.title.text = [dish objectForKey:@"name"];
    cell.price.text = [NSString stringWithFormat:@"$ %@", [dish objectForKey:@"price"]];
    [cell setRating:[[dish objectForKey:@"rate"] doubleValue]];
    
    Dish *item = [_rowIndexDishMap objectForKey:[NSString stringWithFormat:@"%li", indexPath.row]];
    cell.quantity.text = [NSString stringWithFormat:@"%li", item.dishNumber];
    
    // before the imageView is set, it would be nil
    if (cell.imageView.image == nil) {
    
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable dataResp, NSURLResponse * _Nullable urlResp, NSError * _Nullable error)
        {
            if (dataResp) {
                UIImage *image = [UIImage imageWithData:dataResp];
                
                CGSize size = image.size;
                NSInteger side = MIN(size.width, size.height);
                CGRect rect = CGRectMake(0, 0, side, side);
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                if (image) {
                    // on can only update a tableViewCell in the main UI thread
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
    [[session dataTaskWithURL:
      [NSURL URLWithString:[NSString stringWithFormat:@"%@/backend/dish/",[(CustomerTabBarController*)self.tabBarController baseUrlStr]]]
            completionHandler:^(NSData *dataResp, NSURLResponse *urlResp, NSError *error)
    {
        // handle response in the background thread
        if (dataResp.length > 0 && error == nil) {
            _dishes = [NSJSONSerialization JSONObjectWithData:dataResp options:0 error:NULL];
            
            for(int i = 0; i < _dishes.count; i++){
                NSDictionary *item = [_dishes objectAtIndex:i];
                Dish *dish = [[Dish alloc] init];
                dish.dishId = [[item objectForKey:@"id"] intValue];
                dish.dishPrice = [[item objectForKey:@"price"] doubleValue];
                dish.dishName = [item objectForKey:@"name"];
                dish.dishNumber = 0;
                [_rowIndexDishMap setObject:dish forKey:[NSString stringWithFormat:@"%d", i]];
            }
            
            if(_dishes.count > 0) {
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
    Dish *dish = [_rowIndexDishMap objectForKey:[NSString stringWithFormat:@"%ld", cell.position]];
    dish.dishNumber = cell.count;
}

- (void)onRatingChangeAt:(long)position withRate:(double)rate {
    Dish *dish = [_rowIndexDishMap objectForKey:[NSString stringWithFormat:@"%ld", position]];
    
    CustomerTabBarController *controller = (CustomerTabBarController*)self.tabBarController;
    NSURL *putRateUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/backend/rate/%ld/", [controller baseUrlStr], dish.dishId]];
    NSDictionary *dict = @{@"user":[NSNumber numberWithLongLong:controller.userId], @"rate":[NSNumber numberWithDouble:rate]};
    
    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if(json){
        
        // send a PUT request to the server
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:putRateUrl];
        [request setHTTPMethod:@"PUT"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:json];
        
        // start a new NSURL session to upgrade dish rate
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *dataResp, NSURLResponse *urlResp, NSError *error)
        {
            // handle response in the background thread
            if (dataResp.length > 0 && !error) {
                NSDictionary *dist = [NSJSONSerialization JSONObjectWithData:dataResp options:0 error:&error];
                NSString *message = [dist objectForKey:@"message"];
                NSLog(@"Resp: %@", message);
            }
            else if(error) {
                NSLog(@"Error(%li): %@", error.code, error.description);
            }
        }] resume];
    }
}

- (IBAction)cart:(id)sender {
    
    __block NSMutableDictionary *rowIndexOrderMap = [[NSMutableDictionary alloc] init];
    int i = 0;
    for (id key in _rowIndexDishMap) {
        Dish *dish = [_rowIndexDishMap objectForKey:key];
        if (dish.dishNumber > 0) {
            [rowIndexOrderMap setObject:dish forKey:[NSString stringWithFormat:@"%d", i]];
            i++;
        }
    }
    CustomerCartController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"cartTable"];
    [controller setData:rowIndexOrderMap];
    
    CGRect rect = CGRectMake(0, 0, 330, 350);
    [controller setPreferredContentSize:rect.size];
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Order Details" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [dialog setValue:controller forKey:@"contentViewController"];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        if(rowIndexOrderMap.count > 0) {
            // Upload customer's orders.
            CustomerTabBarController *controller = (CustomerTabBarController *)self.tabBarController;
            NSURL *postOrderUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/backend/order/bunch/", [(CustomerTabBarController*)self.tabBarController baseUrlStr]]];
            
            NSMutableArray *orders = [[NSMutableArray alloc] init];
            for(Dish *dish in [rowIndexOrderMap allValues]){
                [orders addObject:@{@"dish":[NSNumber numberWithLong:dish.dishId], @"amount":[NSNumber numberWithLong:dish.dishNumber]}];
            }
            
            NSDictionary *dict = @{@"twitterID":[NSNumber numberWithLongLong:controller.userId],@"order":orders};
            
            NSError *error;
            NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
            if (json) {
                // initiate a HTTP post request
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postOrderUrl];
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:json];
                
                NSURLSession *session = [NSURLSession sharedSession];
                [[session dataTaskWithRequest:request
                            completionHandler:^(NSData *dataResp, NSURLResponse *urlResp, NSError *error)
                {
                    
                    // handle response in the background thread
                    if (dataResp.length > 0 && !error) {
                        NSDictionary *dist = [NSJSONSerialization JSONObjectWithData:dataResp options:0 error:&error];
                        NSString *message = [dist objectForKey:@"message"];
                        NSLog(@"Response: %@", message);
                        
                        [controller startCheckingNotification];
                    }
                    else if(error != nil) {
                        NSLog(@"Error(%li): %@", error.code, error.description);
                    }
                }] resume];
            }
            [self resetMenuList];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [dialog addAction:confirm];
    [dialog addAction:cancel];
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)resetMenuList {
    int i = 0;
    for (id key in _rowIndexDishMap) {
        Dish *dish = [_rowIndexDishMap objectForKey:key];
        if (dish.dishNumber != 0) {
            [dish setDishNumber:0];
            i++;
        }
    }
    
    [self.tableView reloadData];
}

@end
