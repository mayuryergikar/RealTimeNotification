//
//  LocationShareModel.m
//  RealTimeNotifications
//
//  Created by mac_user on 19/09/18.
//  Copyright © 2018 Mayur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface LocationManager () <CLLocationManagerDelegate>

@end

@implementation LocationManager

+ (id)sharedManager {
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    
    return sharedMyModel;
}

#pragma mark - CLLocationManager
- (void)startMonitoringLocation {
    if (_anotherLocationManager)
        [_anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.anotherLocationManager = [[CLLocationManager alloc]init];
    _anotherLocationManager.delegate = self;
    _anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _anotherLocationManager.activityType = CLActivityTypeOtherNavigation;

    [_anotherLocationManager startMonitoringSignificantLocationChanges];
}

- (void)restartMonitoringLocation {
   
    [_anotherLocationManager stopMonitoringSignificantLocationChanges];
    [_anotherLocationManager startMonitoringSignificantLocationChanges];
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    for (int i = 0; i < locations.count; i++) {
        
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        self.myLocation = theLocation;
        self.myLocationAccuracy = theAccuracy;
    }
    
    [self callLocalNotification:_afterResume];
}

#pragma mark - Plist helper methods
- (NSString *)appState {
    UIApplication* application = [UIApplication sharedApplication];

    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";
    
    return appState;
}

- (void)callLocalNotification:(BOOL)fromResume {

    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    CLLocation *currentlatlong = [[CLLocation alloc]initWithLatitude:self.myLocation.latitude longitude:self.myLocation.longitude];
    
    NSString * destinationVal = [defaluts valueForKey:@"DISTINATIONLATLONG"];
    NSString * lat = [destinationVal componentsSeparatedByString:@","][0];
    NSString * longe = [destinationVal componentsSeparatedByString:@","][1];
    CLLocation * destinationlatlong = [[CLLocation alloc]initWithLatitude:[lat floatValue] longitude:[longe floatValue]];
    
    double distanceInKM = [currentlatlong distanceFromLocation:destinationlatlong]/100;
    if (distanceInKM < 1){
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NOTIFICATIONFIRE" object:nil];
    }
}
@end
