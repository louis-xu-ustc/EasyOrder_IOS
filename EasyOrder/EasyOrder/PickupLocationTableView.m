//
//  HistoricalOrderTableView.m
//  EasyOrder
//
//  Created by Yu-Lun Tsai on 21/07/2017.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "PickupLocationTableView.h"

@implementation PickupLocationTableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pickupLocationCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *name = [_array objectAtIndex:indexPath.row];
    UILabel *nameLabel = [cell viewWithTag:0]; // TAG 0 is the text label for location name
//    UILabel *TimeLabel = [cell viewWithTag:1]; // TAG 1 is the time label for ETA
    
    nameLabel.text = name;
    return cell;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
