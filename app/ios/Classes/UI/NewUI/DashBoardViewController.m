//
//  DashBoardViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 29/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "DashBoardViewController.h"

@implementation DashBoardViewController

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
    CGFloat topImgHeight = (int)((UI_WINDOW_HEIGHT- UI_TOP_NAVIGATION_BAR_HEIGHT)*0.3f);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.frame = CGRectMake(0,  UI_TOP_NAVIGATION_BAR_HEIGHT, UI_SCREEN_W, topImgHeight);
    [self.view addSubview:imageView];

    CGFloat scoreTop = UI_TOP_NAVIGATION_BAR_HEIGHT + topImgHeight * 0.1f;
    CGFloat scoreEdge = topImgHeight * 0.75f;
    CGFloat scoreBottom   = scoreTop + scoreEdge;
    CGFloat scoreLeft = (UI_SCREEN_W - scoreEdge)/2.0f;
    CGFloat scoreRight = scoreLeft + scoreEdge;
   
    
    ScoreView *scoreView = [[ScoreView alloc] initWithFrame:CGRectMake(scoreLeft, scoreTop, scoreEdge, scoreEdge)];
    [scoreView setScore: 60];
    [scoreView setTitle: @"J-score"];
    [self.view addSubview:scoreView];
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
