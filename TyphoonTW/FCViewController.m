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
    //newRegion.span.longitudeDelta = 0.05;
    
    [self.mapView setRegion:newRegion animated:NO];
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


@end
