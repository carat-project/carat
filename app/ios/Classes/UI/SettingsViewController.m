//
//  SettingsViewController.m
//  Carat
//
//  Created by Jonatan C Hamberg on 22/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "SettingsViewController.h"
#import "DeviceInformation.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface SettingsViewController () <CBCentralManagerDelegate>
@property (nonatomic) CBCentralManager *bluetoothManager;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bluetoothManager = [[CBCentralManager alloc]
        initWithDelegate:self
        queue:nil
        options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
        forKey:CBCentralManagerOptionShowPowerAlertKey]];
    
    [_mobileNetworkType setText:[DeviceInformation getMobileNetworkType]];
    [_batteryState setText: [DeviceInformation getBatteryState]];
    [_cpuUsage setText: [NSString stringWithFormat:@"%2.2f %%", [DeviceInformation getCpuUsage]*100]];
    [_screenBrightness setText: [NSString stringWithFormat:@"%2.2f", [DeviceInformation getScreenBrightness]*100]];
    [_locationEnabled setText: [NSString stringWithFormat:@"%s",[DeviceInformation getLocationEnabled] ? "ON" : "OFF"]];
    [self updateBluetoothLabel];
}

- (void) updateBluetoothLabel {
    [_bluetoothEnabled setText: [NSString stringWithFormat: @"%s", _bluetoothManager.state == CBCentralManagerStatePoweredOn ? "ON" : "OFF"]];
}

#pragma mark - CBCentralManagerDelegate

// Listen to bluetooth state since it is initially unknown
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self updateBluetoothLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_mobileNetworkType release];
    [_batteryState release];
    [_screenBrightness release];
    [_locationEnabled release];
    [_bluetoothEnabled release];
    [_bluetoothManager release];
    [super dealloc];
}
@end
