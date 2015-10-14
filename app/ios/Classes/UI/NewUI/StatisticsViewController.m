//
//  StatisticsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "StatisticsViewController.h"

@interface StatisticsViewController ()

@end

@implementation StatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [_genIntensiveDescLabel release];
    [_androidIntensiveLabel release];
    [_genIntensiveBar release];
    [_androidIntensiveBar release];
    [_iOSIntensiveDescLabel release];
    [_iOSIntensiveBar release];
    [_allUsersIntensiveDescLabel release];
    [_allUsersIntensiveBar release];
    [_popularDeviceModelsDescLabel release];
    [_wellBehivedBar release];
    [_wellBehivedLabel release];
    [_bugBar release];
    [_bugsLabel release];
    [_hogsLabel release];
    [_hogsBar release];
    [super dealloc];
}
- (IBAction)showWellBehivedInfo:(id)sender {
    NSLog(@"showWellBehivedInfo");
     [self showInfoView:@"WellBehived" message:@"WellBehivedDesc"];
}

- (IBAction)showBugsInfo:(id)sender {
        NSLog(@"showBugsInfo");
     [self showInfoView:@"Bugs" message:@"BugsDesc"];
}

- (IBAction)showHogsInfo:(id)sender {
        NSLog(@"showHogsInfo");
     [self showInfoView:@"Hogs" message:@"HogsDesc"];
}
@end
