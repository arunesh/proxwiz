/*
 File: ALAppDelegate.m
 Abstract: Main entry point for the application. Displays the main menu and notifies the user when region state transitions occur.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import "ALAppDelegate.h"
#import "ALMenuViewController.h"
#import "ALDefaults.h"


@implementation ALAppDelegate
{
  ALMenuViewController *_menuViewController;
  UINavigationController *_rootViewController;
  CLLocationManager *_locationManager;
  NSMutableArray *_rangedRegions;
  CBPeripheralManager *_peripheralManager;
  NSUUID *_uuid;
  NSNumber *_major;
  NSNumber *_minor;
  NSNumber *_power;
  CLBeaconRegion *_regionToAdvertise;
  CLBeaconRegion *_regionToMonitor;
  CBCentralManager *_centralManager;

}


- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
  // A user can transition in or out of a region while the application is not running.
  // When this happens CoreLocation will launch the application momentarily, call this delegate method
  // and we will let the user know via a local notification.
  UILocalNotification *notification = [[UILocalNotification alloc] init];
  
  if(state == CLRegionStateInside)
  {
    notification.alertBody = [NSString stringWithFormat:@"You're inside the region %@", region.identifier];
    //Start Advertising
    //NSDictionary *peripheralData = [_regionToAdvertise peripheralDataWithMeasuredPower:_power];
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"180D"];
    NSDictionary *advertisment = @{CBAdvertisementDataServiceUUIDsKey : @[serviceUUID],
                                      CBAdvertisementDataLocalNameKey : @"ABC",
                                  };
    [self startAdvertising:advertisment];
    // Start ranging when the view appears.
    [_rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      CLBeaconRegion *region = obj;
      [_locationManager startRangingBeaconsInRegion:region];
    }];
  }
  else if(state == CLRegionStateOutside)
  {
    notification.alertBody = [NSString stringWithFormat:@"You're outside the region %@", region.identifier];
  }
  else
  {
    return;
  }
  // If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
  // If its not, iOS will display the notification to the user.
  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)startAdvertising:(NSDictionary *)advertisementData {
  [_peripheralManager stopAdvertising];
  [_peripheralManager startAdvertising:advertisementData];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
  // CoreLocatio n will call this delegate method at 1 Hz with updated range information.
  // Beacons will be categorized and displayed by proximity.
  UILocalNotification *notification = [[UILocalNotification alloc] init];
  NSMutableString *messageToDisplay = [[NSMutableString alloc] init];
  for (CLBeacon *beacon in beacons) {
    [messageToDisplay appendString:beacon.description];
    [messageToDisplay appendString:@"\n"];
    if ([beacon.major integerValue] == 100) {
      //Start Advertising
      //NSDictionary *peripheralData = [_regionToAdvertise peripheralDataWithMeasuredPower:_power];
      //[self startAdvertising:peripheralData];
    }
  }
  // If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
  // If its not, iOS will display the notification to the user.
  if ([beacons count] > 0) {
    notification.alertBody = [NSString stringWithFormat:@"Beacon: %@", messageToDisplay];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
  }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // This location manager will be used to notify the user of region state transitions.
  _locationManager = [[CLLocationManager alloc] init];
  _locationManager.delegate = self;
  
  
  _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  
  _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
  _uuid = [ALDefaults sharedDefaults].defaultProximityUUID;
  _power = [ALDefaults sharedDefaults].defaultPower;
  NSString *deviceType = [UIDevice currentDevice].model;
  if([deviceType isEqualToString:@"iPhone"]){
    _major = [NSNumber numberWithInt:1];
    _minor = [NSNumber numberWithInt:2];
  } else {
    _major = [NSNumber numberWithInt:100];
    _minor = [NSNumber numberWithInt:200];
  }

  _regionToAdvertise = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid major:[_major shortValue] minor:[_minor shortValue] identifier:@"com.proximitywiz.AirLocate"];
  _regionToMonitor = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.proximitywiz.AirLocate"];

  _rangedRegions = [NSMutableArray array];
  [[ALDefaults sharedDefaults].supportedProximityUUIDs enumerateObjectsUsingBlock:^(id uuidObj, NSUInteger uuidIdx, BOOL *uuidStop) {
    NSUUID *uuid = (NSUUID *)uuidObj;
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
    [_rangedRegions addObject:region];
  }];

  
  
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  // Display the main menu.
  _menuViewController = [[ALMenuViewController alloc] initWithStyle:UITableViewStylePlain];
  _rootViewController = [[UINavigationController alloc] initWithRootViewController:_menuViewController];
  
  self.window.rootViewController = _rootViewController;
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];

  //Start Advertising
  NSDictionary *peripheralData = [_regionToAdvertise peripheralDataWithMeasuredPower:_power];
  [self startAdvertising:peripheralData];
  

  
  //Start Monitoring for Region
  for (CLRegion *monitoredRegion in _locationManager.monitoredRegions) {
    [_locationManager stopMonitoringForRegion:monitoredRegion];
  }
  [_locationManager startMonitoringForRegion:_regionToMonitor];
  
  return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
  // If the application is in the foreground, we will notify the user of the region's state via an alert.
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
  NSLog(@"app did enter background");
  //[_peripheralManager stopAdvertising];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  NSLog(@"app will enter foreground");
  [_peripheralManager stopAdvertising];
  //Start Advertising
  NSDictionary *peripheralData = [_regionToAdvertise peripheralDataWithMeasuredPower:_power];
  [self startAdvertising:peripheralData];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
  
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
  if (error) {
    NSLog(@"didStartAdvertising: Error: %@", error);
    return;
  }
  NSLog(@"didStartAdvertising");
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
  if (central.state == CBCentralManagerStatePoweredOn) {
    //Start Scanning
    [_centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:YES]}];
  }
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
  NSLog(@"Discovered:%@", aPeripheral.description);
  UILocalNotification *notification = [[UILocalNotification alloc] init];
  notification.alertBody = [NSString stringWithFormat:@"Discovered: RSSI:%@, advData:%@, per:%@", RSSI, advertisementData.description, aPeripheral.description];
  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}


@end
