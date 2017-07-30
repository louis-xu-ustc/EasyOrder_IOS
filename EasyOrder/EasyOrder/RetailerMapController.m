//
//  RetailerMapController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/12/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "RetailerMapController.h"

@interface RetailerMapController () {
    NSArray *_buffer;
    bool _pickupLocationLoaded;
}

@end

@implementation RetailerMapController

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedLoc = [_candidates objectAtIndex:row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 300;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _candidates.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[_candidates objectAtIndex:row] thoroughfare];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    CLPlacemark *placemark = [_candidates objectAtIndex:row];
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] init];
    }
    label.text = [NSString stringWithFormat:@"%@ %@, %@ %@", placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode];
    return label;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPointAnnotation *point = (MKPointAnnotation *)annotation;
    NSString *type = point.accessibilityLabel;
    if ([type isEqualToString:@"user"]) {
        MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSLocaleIdentifier];
        view.pinColor = MKPinAnnotationColorPurple;
        view.animatesDrop = YES;
        view.canShowCallout = YES;
        return view;
    } else {
        MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSLocaleIdentifier];
        view.pinColor = MKPinAnnotationColorRed;
        view.animatesDrop = YES;
        view.canShowCallout = YES;
        return view;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.location = [locations lastObject];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:@"http://54.202.127.83/backend/current_location/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"PUT"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSNumber numberWithDouble:self.location.coordinate.latitude] forKey:@"latitude"];
    [params setValue:[NSNumber numberWithDouble:self.location.coordinate.longitude] forKey:@"longitude"];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    [request setHTTPBody:data];
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    }];
    [task resume];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        [_locationManager stopUpdatingLocation];
    }
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager requestLocation];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.mapView.region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        [_candidates removeAllObjects];
        for (MKMapItem *item in response.mapItems) {
            [_candidates addObject:item.placemark];
        }
        _selectedLoc = [_candidates objectAtIndex:0];
        [_searchBar endEditing:YES];
        _searchBar.text = nil;
        [self displayCandidates];
    }];
}

- (void)displayCandidates {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please choose the location" message:@"\n\n\n\n\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(10.0, 50.0, 250.0, 150.0)];
    [alert.view addSubview:picker];
    picker.dataSource = self;
    picker.delegate = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURL *url = [NSURL URLWithString:@"http://54.202.127.83/backend/pickup_locations/"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPMethod:@"POST"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:[NSNumber numberWithDouble:_selectedLoc.location.coordinate.latitude] forKey:@"latitude"];
        [params setValue:[NSNumber numberWithDouble:_selectedLoc.location.coordinate.longitude] forKey:@"longitude"];
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        [request setHTTPBody:data];
        NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        }];
        [task resume];
        [self displayMap];
        [self fetchPickupLocations];
        [self registerGeofencing:_selectedLoc];
        if (_location == nil) {
            _location = [_locationManager location];
        }
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(_selectedLoc.location.coordinate.latitude, _selectedLoc.location.coordinate.longitude);
        CLCircularRegion *bridge = [[CLCircularRegion alloc] initWithCenter:center radius:1000.0 identifier:@"bridgeFirst"];
        if ([bridge containsCoordinate:self.location.coordinate]) {
            [self sendGeofencingInfo:@"Your order is coming soon. Please prepare to pick it up."];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)registerGeofencing:(CLPlacemark *)loc {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(loc.location.coordinate.latitude, loc.location.coordinate.longitude);
    CLRegion *bridge = [[CLCircularRegion alloc] initWithCenter:center radius:1000.0 identifier:@"bridge"];
    [self.locationManager startMonitoringForRegion:bridge];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self sendGeofencingInfo:@"Your order is coming soon. Please prepare to pick it up."];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self sendGeofencingInfo:@"Your order is leaving your region. Please wait for more time."];
}

- (void)sendGeofencingInfo:(NSString *)message {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:@"http://54.202.127.83/backend/notification/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"PUT"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:message forKey:@"content"];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    [request setHTTPBody:data];
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    }];
    [task resume];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    
}

- (void)displayMap {
    [_mapView removeAnnotations:_mapView.annotations];
    CLLocationCoordinate2D current = CLLocationCoordinate2DMake(_location.coordinate.latitude, _location.coordinate.longitude);
    MKPointAnnotation *currentPin = [[MKPointAnnotation alloc] init];
    currentPin.coordinate = current;
    currentPin.accessibilityLabel = @"user";
    CLLocation *selectedLocation = _selectedLoc.location;
    CLLocationCoordinate2D selected = CLLocationCoordinate2DMake(selectedLocation.coordinate.latitude, selectedLocation.coordinate.longitude);
    MKPointAnnotation *selectedPin = [[MKPointAnnotation alloc] init];
    selectedPin.coordinate = selected;
    [_mapView addAnnotation:currentPin];
    [_mapView addAnnotation:selectedPin];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((_location.coordinate.latitude + selected.latitude) / 2.0, (_location.coordinate.longitude + selected.longitude) / 2.0);
    _mapView.region = MKCoordinateRegionMakeWithDistance(center, [_location distanceFromLocation:selectedLocation] + 0.05f, [_location distanceFromLocation:selectedLocation] + 0.05f);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!CLLocationManager.locationServicesEnabled) {
        return;
    } else {
        if (!_locationManager) {
            _locationManager = [[CLLocationManager alloc] init];
        }
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 500;
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        self.location = [[CLLocation alloc] init];
        if (!_geocoder) {
            _geocoder = [[CLGeocoder alloc] init];
        }
        _candidates = [NSMutableArray array];
        _locationManager.delegate = self;
        _searchBar.delegate = self;
        _mapView.delegate = self;
        _tableView.dataSource = _tableView;
        _tableView.delegate = _tableView;
        _pickupLocationLoaded = NO;
        [self fetchPickupLocations];
        [_locationManager startUpdatingLocation];
    }
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
                    __block NSInteger i = max - 1;
                    __block NSDictionary *json;
                    
                    __block __weak void (^weak_apply)(NSArray* placemarks, NSError* error);
                    void (^apply)(NSArray* placemarks, NSError* error);
                    
                    weak_apply = apply = ^(NSArray* placemarks, NSError* error){
                        
                        if(error == nil && placemarks.count > 0){
                            [pickupLocation addObject:[placemarks lastObject]];
                        }
                        else if(error){
                            NSLog(@"Error(%ld): %@", [error code], [error description]);
                        }
                        
                        i--;
                        if((max - i) <= 3 && i >= 0){
                            json = [_buffer objectAtIndex:i];
                            CLLocation *location = [[CLLocation alloc]
                                                    initWithLatitude:[[json objectForKey:@"latitude"] doubleValue]
                                                    longitude:[[json objectForKey:@"longitude"] doubleValue]];
                            [_geocoder reverseGeocodeLocation:location completionHandler:weak_apply];
                        }
                        else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_tableView setArrayLocation:[[NSArray alloc]initWithArray:pickupLocation]];
                                _pickupLocationLoaded = YES;
                                [_tableView reloadData];
                            });
                            NSLog(@"Complete geocoding");
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
