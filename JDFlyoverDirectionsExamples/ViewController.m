//
//  ViewController.m
//  JDFlyoverDirectionsExamples
//
//  Created by Judson Douglas on 4/19/14.
//  Copyright (c) 2014 Judson Douglas. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>


#define kSearsTowerLat         41.949043
#define kSearsTowerLon         -87.654258


#define kWrigleyFieldLat        41.864933
#define kWrigleyFieldLon        -87.698166




@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray *mapCameras;
    MKDirectionsResponse *directionsResponse;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapCameras = [NSMutableArray array];
	// Do any additional setup after loading the view, typically from a nib.
    CLLocationCoordinate2D searsTowerCoords = CLLocationCoordinate2DMake(kSearsTowerLat, kSearsTowerLon);
    CLLocationCoordinate2D wrigleyFieldCoords = CLLocationCoordinate2DMake(kWrigleyFieldLat, kWrigleyFieldLon);
    MKPlacemark *searsTowerPlacemark = [[MKPlacemark alloc] initWithCoordinate:searsTowerCoords addressDictionary:nil];
    MKMapItem *searsTowerItem = [[MKMapItem alloc] initWithPlacemark:searsTowerPlacemark];
    searsTowerItem.name = @"The Sear's Tower";
    MKPlacemark *wrigleyFieldPlacemark = [[MKPlacemark alloc] initWithCoordinate:wrigleyFieldCoords addressDictionary:nil];
    MKMapItem *wrigleyFieldItem = [[MKMapItem alloc] initWithPlacemark:wrigleyFieldPlacemark];
    wrigleyFieldItem.name = @"Wrigley Field";
    [self requestDirectionsFrom:searsTowerItem to:wrigleyFieldItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) mapView:(MKMapView*)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self goToNextCamera];
}

-(void)requestDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.destination = destination;
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
        if(error)
        {
          //  NSLog(@"%@", [error.userInfo objectForKey:@"NSLocalizedDescriptionKey"]);
            NSLog(@"Error in directions completion handler");
        }
        [self showDirectionsOnMap:response];
        [self flyWithPolyline:[response.routes objectAtIndex:0]];
    }];
}

-(void)showDirectionsOnMap:(MKDirectionsResponse *)response{
    
    for(MKRoute *route in response.routes)
    {
        [_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
    [_mapView  addAnnotation: response.source.placemark];
    [_mapView  addAnnotation: response.destination.placemark];
    [_mapView  showAnnotations: [_mapView annotations] animated:NO];
    
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 3.0;
    return renderer;
    
}

- (void) goToNextCamera
{
    if (mapCameras.count == 0)
    {
        return;
    }
    
    MKMapCamera* nextCamera = [mapCameras firstObject];
       [mapCameras removeObjectAtIndex:0];
       [UIView animateWithDuration:10.0
                             delay:0.0
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            self.mapView.camera = nextCamera;
                        } completion:NULL];
}

-(void)flyWithPolyline:(MKRoute *)route{
    
    mapCameras = [NSMutableArray array];
    NSUInteger pointCount = route.polyline.pointCount;
    
    MKMapPoint firstCameraCenterMapPoint = route.polyline.points[1];
    MKMapPoint secondCameraCenterMapPoint = route.polyline.points[pointCount / 2];
    MKMapPoint thirdCameraCenterMapPoint = route.polyline.points[pointCount - 1];
    
    MKMapPoint firstCameraEyeMapPoint = route.polyline.points[0];
    MKMapPoint secondCameraEyeMapPoint = route.polyline.points[(pointCount / 2) - 1];
    MKMapPoint thirdCameraEyeMapPoint = route.polyline.points[pointCount - 2];
    
    CLLocationCoordinate2D firstCameraCenterCoordinate = MKCoordinateForMapPoint(firstCameraCenterMapPoint);
    CLLocationCoordinate2D secondCameraCenterCoordinate = MKCoordinateForMapPoint(secondCameraCenterMapPoint);
    CLLocationCoordinate2D thirdCameraCenterCoordinate = MKCoordinateForMapPoint(thirdCameraCenterMapPoint);
    
    CLLocationCoordinate2D firstCameraEyeCoordinate = MKCoordinateForMapPoint(firstCameraEyeMapPoint);
    CLLocationCoordinate2D secondCameraEyeCoordinate = MKCoordinateForMapPoint(secondCameraEyeMapPoint);
    CLLocationCoordinate2D thirdCameraEyeCoordinate = MKCoordinateForMapPoint(thirdCameraEyeMapPoint);
    
    
    MKMapCamera* firstCamera = [MKMapCamera cameraLookingAtCenterCoordinate:firstCameraCenterCoordinate
                                                         fromEyeCoordinate:firstCameraEyeCoordinate
                                                               eyeAltitude:1000];
    MKMapCamera* secondCamera = [MKMapCamera cameraLookingAtCenterCoordinate:secondCameraCenterCoordinate
                                                          fromEyeCoordinate:secondCameraEyeCoordinate
                                                                eyeAltitude:15000];
    MKMapCamera* thirdCamera = [MKMapCamera cameraLookingAtCenterCoordinate:thirdCameraCenterCoordinate
                                                          fromEyeCoordinate:thirdCameraEyeCoordinate
                                                                eyeAltitude:1000];
    
    [mapCameras addObject:firstCamera];
    [mapCameras addObject:secondCamera];
    [mapCameras addObject:thirdCamera];
    
    [self goToNextCamera];
}

@end
