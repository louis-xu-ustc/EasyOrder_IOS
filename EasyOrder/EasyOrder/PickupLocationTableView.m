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
    return _arrayLocation.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pickupLocationCell" forIndexPath:indexPath];
    
    // Configure the cell...
    id location = [_arrayLocation objectAtIndex:indexPath.row];
    UILabel *nameLabel = [cell viewWithTag:1]; // TAG 0 is the text label for location name
    UILabel *etaLabel = [cell viewWithTag:2]; // TAG 1 is the time label for ETA
    
    nameLabel.text = [location name];
    
    NSNumber *constNegativeOne = [NSNumber numberWithDouble:-1];
    if(_arrayLocation.count == _arrayETA.count){
        NSNumber *number = [_arrayETA objectAtIndex:indexPath.row];
        
        if([number isEqualToValue:constNegativeOne]){
            etaLabel.text = @"NA";
        }
        else{
            double min = [number doubleValue]/60;
            etaLabel.text = [NSString stringWithFormat:@"%.1f min", min];
        }
    }
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
