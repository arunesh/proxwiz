//
//  PXBaseBeaconGenerator.h
//  ProximityLib
//
//  Created by Vivek Shrivastava on 10/13/13.
//  Copyright (c) 2013 ProximityWiz. All rights reserved.
//


@protocol PXDiscoveryDelegate <NSObject>
/* Callback functions on discovering devices */
- (void) pxBTLEDevicesInRange:(NSArray *)pxDevices;
- (void) pxBTLEDevicesOutsideRange:(NSArray *)pxDevices;
- (void) pxIBeaconStateChanged:(CLRegionState)beaconState;
- (void) pxBTLEAntennaStateChanged:(CBCentralManagerState)antennaState;
@end

@interface PXBaseBeaconGenerator : NSObject

@property(nonatomic, assign) id<PXDiscoveryDelegate> pxDelegate;
@property(nonatomic, strong) CBCentralManager *pxBTLEManager;
@property(nonatomic, strong)

@end
