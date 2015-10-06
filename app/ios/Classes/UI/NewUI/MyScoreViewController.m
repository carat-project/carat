//
//  MyScoreViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "MyScoreViewController.h"

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


- (IBAction)barItemBackPressed{
    NSLog(@"****** barItemBackPressed *******");
    DashBoardViewController *controler = [[DashBoardViewController alloc]initWithNibName:@"DashBoardViewController" bundle:nil];
    [self presentViewController:controler animated: YES completion:nil];
    [controler release];
}

-(IBAction)barItemMorePressed{
    NSLog(@"barItemMorePressed");
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

@end
