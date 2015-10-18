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
    // Do any additional setup after loading the view from its nib.
    [self setReport:[[CoreDataManager instance] getHogs:NO withoutHidden:YES]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setReport:[[CoreDataManager instance] getHogs:NO withoutHidden:YES]];
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
        [self setReport:hogs];
    }
}

-(void)sampleCountUpdated:(NSNotification*)notification{
    
    if(self.tableView)
        [self.tableView reloadData];
}

/*
-(void) creteDummyData{
    
    BugHogListItemData* d1 = [BugHogListItemData new];
    d1.imageName = @"Icon-Small-50";
    d1.title = @"Facebook";
    d1.expImpTxt = @"1h 42m";
    d1.samples = @"263";
    d1.error = @"49";
    d1.samplesWithout = @"2125454";
    
    BugHogListItemData* d2 = [BugHogListItemData new];
    d2.imageName = @"Icon-Small-50";
    d2.title = @"Instagram";
    d2.expImpTxt = @"1h 22m";
    d2.samples = @"120";
    d2.error = @"23";
    d2.samplesWithout = @"2125";
    
    BugHogListItemData* d3 = [BugHogListItemData new];
    d3.imageName = @"Icon-Small-50";
    d3.title = @"Googlemaps";
    d3.expImpTxt = @"1h 22m";
    d3.samples = @"50";
    d3.error = @"13";
    d3.samplesWithout = @"621254";
    
    _tableData = [[NSArray alloc] initWithObjects:d1, d2, d3, nil];
}
*/

- (void)dealloc {
    [super dealloc];
}
@end
