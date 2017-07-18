//
//  CustomerMapController.h
//  EasyOrder
//
//  Created by Yu Zhou on 7/14/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CustomerMapController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
