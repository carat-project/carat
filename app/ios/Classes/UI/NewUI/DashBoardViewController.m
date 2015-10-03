//
//  DashBoardViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 29/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "DashBoardViewController.h"

@implementation DashBoardViewController{
    
    UILabel *_batteryLife;
    UILabel *_batteryLifeTime;
    UIImageView *_myDeviceBtn;
}

- (void)loadView
{
    [super loadView];

    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, UI_SCREEN_W, UI_TOP_NAVIGATION_BAR_HEIGHT)];
    //do something like background color, title, etc you self
    UINavigationItem *navItem = [UINavigationItem alloc];
    navItem.title = @"Dashboard";

    [navbar pushNavigationItem:navItem animated:false];

    [self.view addSubview:navbar];
    
    UIImage *img = [UIImage imageNamed:@"chart_image"];
    CGFloat oneThirdHeight = ((UI_WINDOW_HEIGHT- UI_TOP_NAVIGATION_BAR_HEIGHT)*0.33f);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.frame = CGRectMake(0,  UI_TOP_NAVIGATION_BAR_HEIGHT, UI_SCREEN_W, oneThirdHeight);
    NSLog(@"topImgHeight: %f CGRectGetMaxY(imageView.frame): %f", oneThirdHeight, CGRectGetMaxY(imageView.frame));
    [self.view addSubview:imageView];

    CGFloat scoreTop = UI_TOP_NAVIGATION_BAR_HEIGHT + oneThirdHeight * 0.1f;
    CGFloat scoreEdge = oneThirdHeight * 0.7f;
    CGFloat scoreLeft = (UI_SCREEN_W - scoreEdge)/2.0f;
   
    
    ScoreView *scoreView = [[ScoreView alloc] initWithFrame:CGRectMake(scoreLeft, scoreTop, scoreEdge, scoreEdge)];
    [scoreView setScore: 60];
    [scoreView setTitle: @"J-score"];
    [self.view addSubview:scoreView];
    
    CGFloat shareEdge = 60.0f;
    CGFloat shareTop = CGRectGetMaxY(imageView.frame)-shareEdge/2.0f;
    CGFloat shareLeft = UI_SCREEN_W - shareEdge - 20.0f; //20 is margin from right screen edge
    NSLog(@"shareTop: %f shareLeft: %f", shareTop, shareLeft);
    
    ShareView *shareView =[[ShareView alloc] initWithFrame:CGRectMake(shareLeft, shareTop, shareEdge, shareEdge)];
    [self.view addSubview:shareView];
    
    CGFloat centerTopBottomPad = oneThirdHeight*0.15f;
    CGFloat batterylifeLabelTop = CGRectGetMaxY(imageView.frame) + centerTopBottomPad;
    NSString *activeBatteryLifeLabelString = LANG(@"BatteryLifeLabel");
    NSLog(@"activeBatteryLifeLabelString: %@", activeBatteryLifeLabelString);
}


#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

@end
