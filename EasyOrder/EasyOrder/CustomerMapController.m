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
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    MKPointAnnotation *_retailerPin;
    NSArray *_buffer;
    NSTimer *_timer;
}
@end

@implementation CustomerMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // configure dataSource and delegate of the table view
    _tableView.dataSource = _tableView;
    _tableView.delegate = _tableView;
    
    // initialize geocoder
    _geocoder = [[CLGeocoder alloc] init];
    
    // fetch the current location once the view is loaded
    [self fetchPickupLocations];
    [self fetchCurrentLocation];
    
    // add a bottom border to the table view
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(0, _titleView.frame.size.height-bottomBorder.borderWidth, _titleView.frame.size.width, 1);
    _titleView.clipsToBounds = YES;
    [_titleView.layer addSublayer:bottomBorder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self startBackgroundTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
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
                    
//                    NSLog(@"Position: (%f, %f)", coordinate.latitude, coordinate.longitude);
                    
                    [self updateRetailerAnnotationAtCoordinate:coordinate];
                }
                else if(error != nil) {
                    NSLog(@"Error (%li): %@", error.code, error.domain);
                }
                
            }] resume];
    
}

- (void)fetchPickupLocations {
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://54.202.127.83/backend/pickup_locations/"]
            completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {
                
                // handle response in the background thread
                if (data.length > 0 && error == nil) {
                    _buffer = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    
                    NSInteger max = _buffer.count;
                    __block NSMutableArray *pickupLocation = [NSMutableArray arrayWithCapacity:10];
                    __block NSInteger i = 0;
                    __block NSDictionary *json;
                    
                    __block __weak void (^weak_apply)(NSArray* placemarks, NSError* error);
                    void (^apply)(NSArray* placemarks, NSError* error);
                    
                    weak_apply = apply = ^(NSArray* placemarks, NSError* error){
                        
                        if(error == nil && placemarks.count > 0){
                            [pickupLocation addObject:[[placemarks lastObject] name]];
//                            NSLog(@"Location: %@", [[placemarks lastObject] name]);
                        }
                        else if(error){
                            NSLog(@"Somthing bad happen: %@", [error localizedFailureReason]);
                        }
                        
                        i = i+1;
                        if(i < max){
                            json = [_buffer objectAtIndex:i];
                            CLLocation *location = [[CLLocation alloc]
                                                    initWithLatitude:[[json objectForKey:@"latitude"] doubleValue]
                                                    longitude:[[json objectForKey:@"longitude"] doubleValue]];
                            [_geocoder reverseGeocodeLocation:location completionHandler:                    weak_apply];
                        }
                        else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_tableView setArray:[[NSArray alloc]initWithArray:pickupLocation]];
                                [_tableView reloadData];
                            });
//                            NSLog(@"Complete geocoding");
                        }
                    };
                    
                    json = [_buffer objectAtIndex:i];
                    CLLocation *location = [[CLLocation alloc]
                                            initWithLatitude:[[json objectForKey:@"latitude"] doubleValue]
                                            longitude:[[json objectForKey:@"longitude"] doubleValue]];
                    [_geocoder reverseGeocodeLocation:location completionHandler:apply];
                    
                }
                else if(error != nil) {
                    NSLog(@"Error (%li): %@", error.code, error.domain);
                }
                
            }] resume];
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
    [_mapView selectAnnotation:_retailerPin animated:NO];
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

@end
