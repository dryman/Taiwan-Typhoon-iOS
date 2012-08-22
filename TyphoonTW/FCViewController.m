//
//  FCViewController.m
//  TyphoonTW
//
//  Created by Felix Chern on 12/8/22.
//  Copyright (c) 2012年 idryman@gmail.com. All rights reserved.
//

#import "FCViewController.h"

@interface FCViewController ()

@end

@implementation FCViewController
@synthesize mapView;
@synthesize clManager;

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
    
    NSURL *path_url = [[NSBundle mainBundle] URLForResource:@"ty_infos" withExtension:@"js"];
    NSString *ty_infos = [NSString stringWithContentsOfURL:path_url encoding:NSUTF8StringEncoding error:nil];
    NSError *err = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.+?\\];" options:NSRegularExpressionDotMatchesLineSeparators error:&err];
    NSRange range_of_match = [regex rangeOfFirstMatchInString:ty_infos options:NSRegularExpressionDotMatchesLineSeparators range:NSMakeRange(0, ty_infos.length)];
    NSString *json = [ty_infos substringWithRange:NSMakeRange(range_of_match.location, range_of_match.length-1)];
    NSArray* arr = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    NSDictionary *weather = [arr objectAtIndex:0];
    for (NSDictionary* fcst in [weather valueForKey:@"fcst"]) {
        MKCircle *cir = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake([[fcst valueForKey:@"lat"] floatValue], [[fcst valueForKey:@"lon"] floatValue]) radius:[[fcst valueForKey:@"pr70"]floatValue]*1000];
        [self.mapView addOverlay:cir];
    }
    
    [self.mapView setRegion:newRegion animated:YES];
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

#pragma mark Map View Delegate methods
- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *view = [[MKCircleView alloc] initWithCircle:overlay];
        view.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.05];
        view.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.25];
        view.lineWidth = 3;
        
        return view;
    }
    return nil;
}

@end
