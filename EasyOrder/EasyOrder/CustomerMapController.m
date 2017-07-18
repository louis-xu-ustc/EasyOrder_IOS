//
//  CustomerMapController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/14/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerMapController.h"

@interface CustomerMapController ()
{
    MKPointAnnotation *_retailerPin;
    NSTimer *_timer;
}
@end

@implementation CustomerMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // fetch the current location once the view is loaded
    [self fetchCurrentLocation];
    
    // add a top border to the table view
    CALayer *topBorder = [CALayer layer];
    topBorder.borderColor = [UIColor darkGrayColor].CGColor;
    topBorder.borderWidth = 1;
    topBorder.frame = CGRectMake(0, 0, _tableView.frame.size.width, 1);
    
    _tableView.clipsToBounds = YES;
    [_tableView.layer addSublayer:topBorder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"map view appears");
    [self startBackgroundTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"map view disappears");
    [self stopBackgroundTimer];
}

// Periodic update
- (void)startBackgroundTimer {
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                              target:self
                                            selector:@selector(fetchCurrentLocation)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)stopBackgroundTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)fetchCurrentLocation {
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://54.202.127.83/backend/current_location/"]
            completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {
                
                // handle response in the background thread
                if (data.length > 0 && error == nil) {
                    
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[dict objectForKey:@"latitude"] doubleValue], [[dict objectForKey:@"longitude"] doubleValue]);
                    
                    NSLog(@"Position: (%f, %f)", coordinate.latitude, coordinate.longitude);
                    
                    [self updateRetailerAnnotationAtCoordinate:coordinate];
                }
                else if(error != nil) {
                    NSLog(@"Error (%li): %@", error.code, error.domain);
                }
                
            }] resume];
    
}

- (void)fetchPickupLocations {

}

- (void)updateRetailerAnnotationAtCoordinate: (CLLocationCoordinate2D) coordinate {
    
    if(_retailerPin == nil){
        _retailerPin = [[MKPointAnnotation alloc] init];
        _retailerPin.title = @"Retailer";
        MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
        MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
        [_mapView setRegion:region];
    }
    else{
        [_mapView deselectAnnotation:_retailerPin animated:YES];
    }
    _retailerPin.coordinate = coordinate;
    
    [_mapView addAnnotation:_retailerPin];
    [_mapView selectAnnotation:_retailerPin animated:YES];
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
