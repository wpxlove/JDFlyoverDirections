//
//  ViewController.h
//  JDFlyoverDirectionsExamples
//
//  Created by Judson Douglas on 4/19/14.
//  Copyright (c) 2014 Judson Douglas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end
