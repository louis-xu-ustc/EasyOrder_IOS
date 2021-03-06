//
//  RetailerPostController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/12/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "RetailerPostController.h"

@interface RetailerPostController ()
{
    NSArray *_dishes;
}

@end

@implementation RetailerPostController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchLatestMenu];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.5;
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    _imageCache = [NSMutableDictionary dictionary];
    self.tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0);
    [self fetchLatestMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // UIGestureRecognizerBegan
    } else {
        // UIGestureRecognizerEnd
        NSDictionary *item = [_dishes objectAtIndex:indexPath.row];
        UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Delete Dish" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", [item objectForKey:@"name"]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://54.202.127.83/backend/dish/%d", [[item objectForKey:@"id"] intValue]]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setHTTPMethod:@"DELETE"];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
            [request setHTTPBody:data];
            NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                UIAlertController *done = [UIAlertController alertControllerWithTitle:@"Info" message:@"The dish has been deleted." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [done addAction:action];
                [self presentViewController:done animated:YES completion:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self fetchLatestMenu];
                });
            }];
            [task resume];
        }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        
        [dialog addAction:okAction];
        [dialog addAction:cancelAction];
        [self presentViewController:dialog animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return _dishes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dish = [_dishes objectAtIndex: indexPath.row];
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://54.202.127.83%@", [dish objectForKey:@"photo"]]];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:0];
    UILabel *title = (UILabel *)[cell viewWithTag:3];
    UILabel *price = (UILabel *)[cell viewWithTag:1];
    UILabel *quantity = (UILabel *)[cell viewWithTag:2];
    HCSStarRatingView *ratingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(0, 0, 150, 15)];
    ratingView.tintColor = UIColor.orangeColor;
    ratingView.allowsHalfStars = YES;
    ratingView.value = [[dish objectForKey:@"rate"] doubleValue];
    UIView *ratingViewHolder = (UIView *)[cell viewWithTag:5];
    [ratingViewHolder addSubview:ratingView];
    
    title.text = [dish objectForKey:@"name"];
    price.text = [NSString stringWithFormat:@"$ %@", [dish objectForKey:@"price"]];
    quantity.text = [NSString stringWithFormat:@"%d", [[dish objectForKey:@"num"] intValue]];
    UIImage *image = [_imageCache objectForKey:url];
    if (image) {
        imageView.image = image;
    } else {
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                CGSize size = image.size;
                NSInteger side = MIN(size.width, size.height);
                CGRect rect = CGRectMake(0, 0, side, side);
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_imageCache setObject:image forKey:url];
                        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
                        if ([visiblePaths containsObject:indexPath]) {
                            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        }
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
    
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://54.202.127.83/backend/order/"]
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
