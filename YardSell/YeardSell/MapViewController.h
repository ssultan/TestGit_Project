//
//  MapViewController.h
//  YeardSell
//
//  Created by A. K. M. Saleh Sultan on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface MapViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate> {
    IBOutlet UILabel *latitude_lbl, *longitude_lbl;
    IBOutlet MKMapView *mapView;
    NSString *midPointAddress;
    float previousLocation;
    
    CLLocation *loc1, *loc2;
    CLLocationManager* locationManager;
    CLLocationCoordinate2D locationOfSearchItem, CurrentCertrePoint, SearchedLocation;
    CLLocationCoordinate2D currentLocation;
}

@property (nonatomic, retain)MKMapView *mapView;

- (void)recenterMap;
-(void)OnButtonPinAccessory:(id)sender;

@end
