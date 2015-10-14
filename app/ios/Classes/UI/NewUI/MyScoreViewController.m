//
//  MyScoreViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "MyScoreViewController.h"
#import "InfoViewController.h"

@interface MyScoreViewController ()

@end

@implementation MyScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)leftSwipe{
    NSLog(@"Left Swipe");
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
    [super dealloc];
}
- (IBAction)showJScoreExplanation:(id)sender {
    NSLog(@"showInfoView");
    [self showInfoView:@"JScore" message:@"JScoreDesc"];
}

- (IBAction)showProcessList:(id)sender {
    ProcessViewController *controler = [[ProcessViewController alloc]initWithNibName:@"ProcessViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}

- (IBAction)showMemUsedInfo:(id)sender {
    NSLog(@"showInfoView");
    [self showInfoView:@"MemoryUsed" message:@"MemoryDesc"];
}

- (IBAction)showMemActiveInfo:(id)sender {
    NSLog(@"showInfoView");
    [self showInfoView:@"MemoryActive" message:@"MemoryDesc"];
}

- (IBAction)showCPUUsageInfo:(id)sender {
    NSLog(@"showInfoView");
    [self showInfoView:@"CPUUsage" message:@"CpuUsageDesc"];
}
@end
