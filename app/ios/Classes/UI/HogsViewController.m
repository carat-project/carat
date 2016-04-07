//
//  HogsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "HogsViewController.h"

@interface HogsViewController ()
@end

@implementation HogsViewController

#pragma mark - View Life Cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    _contentTitle.text = NSLocalizedString(@"NothingToReport",nil);
    _content.text = NSLocalizedString(@"EmptyViewDesc",nil);
    // Do any additional setup after loading the view from its nib.
    [self setHogBugReport:[[CoreDataManager instance] getHogs:NO withoutHidden:YES]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setHogBugReport:[[CoreDataManager instance] getHogs:NO withoutHidden:YES]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)updateView {
    [self reloadReport];
    if (self.report != nil) {
        [self.tableView reloadData];
    }
    [self.view setNeedsDisplay];
}

- (void)reloadReport {
    HogBugReport * hogs = [[CoreDataManager instance] getHogs:NO withoutHidden:YES];
    if (hogs != nil) {
        [self setHogBugReport:hogs];
    }
}

-(void)sampleCountUpdated:(NSNotification*)notification{
    if(self.tableView)
        [self.tableView reloadData];
}

- (void)dealloc {
    [_content release];
    [_contentTitle release];
    [super dealloc];
}
@end
