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
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.frame = CGRectMake(0,  UI_TOP_NAVIGATION_BAR_HEIGHT, UI_SCREEN_W, (int)((UI_WINDOW_HEIGHT- UI_TOP_NAVIGATION_BAR_HEIGHT)*0.3f));
    [self.view addSubview:imageView];

    ScoreView *scoreView = [[ScoreView alloc] initWithFrame:self.view.bounds];
    [scoreView setScore: 60];
    [self.view addSubview:m_webView];
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
