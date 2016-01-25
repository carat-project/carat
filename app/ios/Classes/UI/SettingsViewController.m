//
//  SettingsViewController.m
//  Carat
//
//  Created by Jonatan C Hamberg on 22/01/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "SettingsViewController.h"
#import "DeviceInformation.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_mobileNetworkType setText:[DeviceInformation getMobileNetworkType]];
    [_batteryState setText: [DeviceInformation getBatteryState]];
    [_cpuUsage setText: [NSString stringWithFormat:@"%2.2f %%", [DeviceInformation getCpuUsage]*100]];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_mobileNetworkType release];
    [_batteryState release];
    [super dealloc];
}
@end
