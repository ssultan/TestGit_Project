//
//  MapViewController.m
//  YeardSell
//
//  Created by A. K. M. Saleh Sultan on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "DisplayMap.h"
#import "MapDetailsView.h"
#import "JSON.h"


@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle: @"Map View"];
    }
    return self;
}


- (void)recenterMap {
	
	if([mapView.annotations count] == 0)
        return;
    
	NSArray *coordinates = [self.mapView valueForKeyPath:@"annotations.coordinate"];
	
	CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
	CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
	
    
	for(NSValue *value in coordinates) {
		CLLocationCoordinate2D coord = {0.0f, 0.0f};
		[value getValue:&coord];
		if(coord.longitude > maxCoord.longitude) {
			maxCoord.longitude = coord.longitude;
		}
		if(coord.latitude > maxCoord.latitude) {
			maxCoord.latitude = coord.latitude;
		}
		if(coord.longitude < minCoord.longitude) {
			minCoord.longitude = coord.longitude;
		}
		if(coord.latitude < minCoord.latitude) {
			minCoord.latitude = coord.latitude;
		}
	}
	
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	region.center.longitude = (minCoord.longitude + maxCoord.longitude) / 2.0;
	region.center.latitude = (minCoord.latitude + maxCoord.latitude) / 2.0;
	region.span.longitudeDelta = maxCoord.longitude - minCoord.longitude+1;
	region.span.latitudeDelta = maxCoord.latitude - minCoord.latitude+1;
	[self.mapView setRegion:region animated:YES];  
}



- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    
    
    //NSLog(@"Location Lat:%f and Long: %f", location.latitude, location.longitude);
    region.span = span;
    region.center = location;
    [self.mapView setRegion:region animated:YES];
}





- (void)UpdateLocation {
    CurrentCertrePoint = [mapView centerCoordinate];    
    latitude_lbl.text = [NSString stringWithFormat:@"%f° N",CurrentCertrePoint.latitude];
    longitude_lbl.text = [NSString stringWithFormat:@"%f° W",CurrentCertrePoint.longitude];
    
    loc1 = [[CLLocation alloc] initWithLatitude:CurrentCertrePoint.longitude longitude:CurrentCertrePoint.longitude];
     
     CLLocationDistance dist = [loc1 distanceFromLocation:loc2];
     //NSString* strDistance = [NSString stringWithFormat:@"Distance: %.2f Mile",dist*(0.00062)];
    NSLog(@"Distance: %f", dist);
    float distance = dist * (0.00062);
    
    if (distance != previousLocation || dist == -1.000000) {
        NSString *req = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", CurrentCertrePoint.latitude, CurrentCertrePoint.longitude];
        NSLog(@"Request: %@", req);
        NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
        
        NSError *error;
        SBJSON *json = [SBJSON new] ;
        NSDictionary *feed = [json objectWithString:result error:&error];
        //NSLog(@"Feed Location : %@", feed);
        
        if ([[feed objectForKey:@"status"] isEqualToString:@"OK"]) {
            NSArray *array = (NSArray *)[feed objectForKey:@"results"];
            midPointAddress = [[array objectAtIndex:0]objectForKey:@"formatted_address"];
            
            NSLog(@"Midpoint Addrss: %@", midPointAddress);
            DisplayMap *ano = [[DisplayMap alloc] init]; 
            ano.title = @"Current Midpoint";
            ano.subtitle = midPointAddress;
            
            
            MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } }; 
            region.span.longitudeDelta = 0.01f;
            region.span.latitudeDelta = 0.01f;
            region.center.latitude = CurrentCertrePoint.latitude ;
            region.center.longitude = CurrentCertrePoint.longitude;
            ano.coordinate = region.center;
            [mapView addAnnotation:ano];
        }
        
        previousLocation = distance;
        loc2 = loc1;
    }
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    //Set map view
	[mapView setMapType:MKMapTypeStandard];
	[mapView setZoomEnabled:YES];
	[mapView setScrollEnabled:YES];
    mapView.delegate = self;
    
    
    
    self.navigationItem.rightBarButtonItem.enabled = TRUE;
    [mapView removeAnnotations:mapView.annotations];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; //kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    
    [self UpdateLocation];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector: @selector(UpdateLocation) userInfo:nil repeats:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark
#pragma mark location and Map 

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	
	currentLocation = newLocation.coordinate;
	NSLog(@"Latitude : %f and Longitude : %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    locationOfSearchItem.latitude = newLocation.coordinate.latitude;
    locationOfSearchItem.longitude = newLocation.coordinate.longitude;
	[locationManager stopUpdatingLocation];
    
    
    DisplayMap *ano = [[DisplayMap alloc] init]; 
    ano.title = @"Current Location";
    ano.subtitle = midPointAddress; 
    
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } }; 
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    region.center.latitude = locationOfSearchItem.latitude ;
    region.center.longitude = locationOfSearchItem.longitude;
    ano.coordinate = region.center;
    region.center = locationOfSearchItem;
    [mapView addAnnotation:ano];
    
    [self recenterMap];
}

- (void)locationManager: (CLLocationManager *)manager
	   didFailWithError: (NSError *)error {
	
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    
    //annView.pinColor = MKPinAnnotationColorPurple;
    annView.pinColor = MKPinAnnotationColorGreen;
    //annView.image = [UIImage imageNamed:@"yblank.png"];
    annView.annotation = annotation;
    annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    //annView.calloutOffset = CGPointMake(-5, 5);
    
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self action:@selector(OnButtonPinAccessory:) forControlEvents:UIControlEventTouchUpInside];
    annView.rightCalloutAccessoryView = rightButton;
    
    return annView;
}


-(void)OnButtonPinAccessory:(id)sender {
	//UIButton* btnAccessory = (UIButton*)sender;
	MapDetailsView *mapDetailsView = [[MapDetailsView alloc]initWithNibName:@"MapDetailsView" bundle:nil];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]init];
    back.title = @"Back";
    self.navigationItem.backBarButtonItem = back;
	[self.navigationController pushViewController:mapDetailsView animated:YES];
}



-(UIImage *)imageWithImage:(UIImage *)images CovertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [images drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return destImage;
}

/*
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    
    UIImage *image = [UIImage imageNamed:@"yblank.png"];
    image = [self imageWithImage:image CovertToSize:CGSizeMake(32.0f, 32.0f)];
    annotationView.image = image;
    annotationView.annotation = annotation;
    
    return annotationView;
}
 */


/*
- (NSMutableArray *) geoCodeUsingAddress:(NSString *)address
{
    storeArray = [[NSMutableArray alloc]init];
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
	
	NSError *error;
	SBJSON *json = [SBJSON new] ;
	NSDictionary *feed = [json objectWithString:result error:&error];
    NSLog(@"Feed Location : %@", result);
    
    
	NSString* strStatus = [NSString stringWithFormat:@"%@", ([feed objectForKey:@"status"] ? [feed objectForKey:@"status"] : @"")];
    
	if([strStatus isEqualToString:@"OK"]) {
		NSArray *items = (NSArray *) [feed objectForKey:@"results"];
        
        for (NSInteger i=0; i<[items count]; i++) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            
            NSDictionary* dictMain = [items objectAtIndex:i];
            NSDictionary *geometry = [dictMain valueForKey:@"geometry"];
            NSString *placeName = [NSString stringWithFormat:@"%@", [dictMain valueForKey:@"formatted_address"]];
            
            [dictionary setObject:placeName forKey:@"formatted_address"];
            
            NSDictionary *location = [geometry valueForKey:@"location"];
            NSString *strLat = [location valueForKey:@"lat"];
            NSString *strLon = [location valueForKey:@"lng"];
            
            [dictionary setObject:strLat forKey:@"Latitude"];
            [dictionary setObject:strLon forKey:@"Longitude"];
            
            [storeArray addObject:[dictionary copy]];
        }
	}
	
    return storeArray;
}
*/





@end
