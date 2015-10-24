//
//  WebInfoViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 23/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "WebInfoViewController.h"

@interface WebInfoViewController ()

@end

@implementation WebInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super.navBar.topItem setTitle:[_titleForView uppercaseString]];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:_webUrl ofType:@"html"]]];
    [_webView loadRequest:urlReq];
     NSLog(@"%s title: %@", __PRETTY_FUNCTION__, _titleForView);
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
    [_webView release];
    [super dealloc];
}
@end
