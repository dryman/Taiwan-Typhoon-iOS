//
//  FCViewController.h
//  TyphoonTW
//
//  Created by Felix Chern on 12/8/22.
//  Copyright (c) 2012年 idryman@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FCViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *clManager;




@end
