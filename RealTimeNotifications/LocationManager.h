//
//  LocationShareModel.h
//  RealTimeNotifications
//
//  Created by mac_user on 19/09/18.
//  Copyright © 2018 Mayur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

@property (nonatomic) CLLocationManager * anotherLocationManager;
@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;
@property (nonatomic) BOOL afterResume;

+ (id)sharedManager;
- (void)startMonitoringLocation;
- (void)restartMonitoringLocation;

@end
