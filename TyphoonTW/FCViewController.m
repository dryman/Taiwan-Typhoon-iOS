//
//  FCViewController.m
//  TyphoonTW
//
//  Created by Felix Chern on 12/8/22.
//  Copyright (c) 2012年 idryman@gmail.com. All rights reserved.
//

#import "FCViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface FCViewController ()

@end

@implementation FCViewController
@synthesize mapView;
@synthesize clManager;
@synthesize connection;
@synthesize connectionData;

- (CLLocationManager*)clManager{
    if (clManager==nil) {
        clManager=[[CLLocationManager alloc] init];
        clManager.delegate=self;
        clManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        clManager.distanceFilter = 500;
        [clManager startUpdatingLocation];
    }
    return clManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    MKCoordinateRegion newRegion;
    CLLocation *location = self.clManager.location;
    newRegion.center.latitude = 25.041826;
    newRegion.center.longitude = 121.614189;
    newRegion.span.latitudeDelta = 10;
    
    [self.mapView setRegion:newRegion animated:YES];
    
    connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.cwb.gov.tw/V7/prevent/typhoon/Data/PTA_NEW/js/datas/ty_infos.js"]] delegate:self startImmediately:YES];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{

    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark NSURLConnection delegate
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    connectionData = [[NSMutableData alloc] init];
}
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [connectionData appendData:data];
}
- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *ty_infos = [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding];
    connectionData = nil;
    NSError *err = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.+?\\];" options:NSRegularExpressionDotMatchesLineSeparators error:&err];
    NSRange range_of_match = [regex rangeOfFirstMatchInString:ty_infos options:NSRegularExpressionDotMatchesLineSeparators range:NSMakeRange(0, ty_infos.length)];
    NSString *json = [ty_infos substringWithRange:NSMakeRange(range_of_match.location, range_of_match.length-1)];
    NSArray* arr = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    @autoreleasepool {
        for (NSDictionary *typhoon in arr) {
            size_t length = [[typhoon valueForKey:@"fcst"] count] + [[typhoon valueForKey:@"best_track"] count];
            CLLocationCoordinate2D *line_points = (CLLocationCoordinate2D*) malloc(length*sizeof(CLLocationCoordinate2D));

            int i=0;
            for (NSDictionary *track in [typhoon valueForKey:@"best_track"]) {
                CGFloat lat = [[track valueForKey:@"lat"] floatValue];
                CGFloat lon = [[track valueForKey:@"lon"] floatValue];
                CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
                line_points[i++] = location;
                MKPointAnnotation *centerPoint = [[MKPointAnnotation alloc] init];
                centerPoint.coordinate = location;
                [self.mapView addAnnotation:centerPoint];
            }
            for (NSDictionary* fcst in [typhoon valueForKey:@"fcst"]) {
                CGFloat lat = [[fcst valueForKey:@"lat"]  floatValue];
                CGFloat lon = [[fcst valueForKey:@"lon"]  floatValue];
                CGFloat rad = [[fcst valueForKey:@"pr70"] floatValue];
                CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
                line_points[i++]=location;
                
                MKCircle *cir = [MKCircle circleWithCenterCoordinate: location
                                                              radius: rad*1000];
                [self.mapView addOverlay:cir];
                MKPointAnnotation *centerPoint = [[MKPointAnnotation alloc] init];
                centerPoint.coordinate = location;
                [self.mapView addAnnotation:centerPoint];
            }

            MKPolyline *line = [MKPolyline polylineWithCoordinates:line_points count:length];
            [self.mapView addOverlay:line];
            free(line_points);
        }
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connectionData = nil;
}

#pragma mark Map View Delegate methods
- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *view = [[MKCircleView alloc] initWithCircle:overlay];
        view.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.05];
        view.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.25];
        view.lineWidth = 3;
        return view;
    } else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *view = [[MKPolylineView alloc] initWithPolyline:overlay];
        view.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        view.lineWidth = 2;
        return view;
    }
    return nil;
}
- (MKAnnotationView*)mapView:(MKMapView *)mView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString *identifier = @"pinView";
    MKAnnotationView *annotationView = (MKAnnotationView*)[mView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView==nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        UIImage *img = [UIImage imageNamed:@"typh.png"];
        annotationView.image = img;
        annotationView.canShowCallout = NO;
    }
    return annotationView;
}

@end
