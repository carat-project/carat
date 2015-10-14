//
//  MoreViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 12/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

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

- (IBAction)wifiOnlySwitcherValueChanged:(id)sender {
}

- (IBAction)hideAppsClicked:(id)sender {
    NSLog(@"hideAppsClicked");
    HideAppsViewController *controler = [[HideAppsViewController alloc]initWithNibName:@"HideAppsViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}

- (IBAction)feedBackClicked:(id)sender {
}

- (IBAction)tutorialClicked:(id)sender {
    TutorialViewController *controler = [[TutorialViewController alloc]initWithNibName:@"TutorialViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}

- (IBAction)aboutClicked:(id)sender {
    AboutViewController *controler = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}

- (void)dealloc {
    [super dealloc];
}
@end
