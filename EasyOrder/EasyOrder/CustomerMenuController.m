//
//  CustomerMenuController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/14/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerMenuController.h"

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    
    // Configure the cell...
    // tag 0: image
    // tag 1: title
    // tag 2: price
    
    NSDictionary *dish = [_dishes objectAtIndex: indexPath.row];
    
    NSLog(@"DEBUG: %@", dish);
    
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://54.202.127.83%@", [dish objectForKey:@"photo"]]];

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:0];
    UILabel *title = (UILabel *)[cell viewWithTag:1];
    UILabel *price = (UILabel *)[cell viewWithTag:2];

    title.text = [dish objectForKey:@"name"];
    price.text = [NSString stringWithFormat:@"$ %@", [dish objectForKey:@"price"]];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession]
                              dataTaskWithURL:url
                              completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = image;
                    NSLog(@"(W, H): %f, %f", imageView.frame.size.width, imageView.frame.size.height);
                    NSLog(@"(X, Y): %f, %f", imageView.frame.origin.x, imageView.frame.origin.y);
                });
            }
        }
    }];
    [task resume];
    
    return cell;
}

- (void)fetchLatestMenu {
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://54.202.127.83/backend/dish/"]
            completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {
                
                // handle response in the background thread
                if (data.length > 0 && error == nil) {
                    _dishes = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    
                    for(NSDictionary *item in _dishes){
                        
                        NSLog(@"%@: %@",[item objectForKey:@"name"],[item objectForKey:@"photo"]);
                    }
                    
                    if(_dishes.count > 0) {
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self.tableView reloadData];
                        });
                    } //end of if
                }
                else if(error != nil) {
                    NSLog(@"Error (%li): %@", error.code, error.domain);
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

@end
