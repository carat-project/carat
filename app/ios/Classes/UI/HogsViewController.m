//
//  HogsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "HogsViewController.h"
#import "HogStatisticsViewController.h"

@interface HogsViewController ()
@end

@implementation HogsViewController

#pragma mark - View Life Cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _contentTitle.text = NSLocalizedString(@"NothingToReport",nil);
    _content.text = NSLocalizedString(@"EmptyViewDesc",nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingFinished:)
                                                 name:@"EditingFinished" object:nil];
    [self updateExtraAction];
    [self setBug:NO];
    [self setHogBugReport:[[CoreDataManager instance] getHogs:NO withoutHidden:YES]];
    
}

- (void) updateExtraAction {
    NSArray *hidden = [[Globals instance] getHiddenApps];
    HogBugReport *all = [[CoreDataManager instance] getHogs:NO withoutHidden:NO];
    [_extraButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    if(hidden != nil && [hidden count] != 0 && all != nil && [all.hbList count] != 0){
        [_extraButton setTitle:[NSLocalizedString(@"ShowHiddenApps", nil) uppercaseString] forState:UIControlStateNormal];
        [_extraButton addTarget:self action:@selector(showHiddenApps:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_extraButton setTitle:[NSLocalizedString(@"ShowStats", nil) uppercaseString] forState:UIControlStateNormal];
        [_extraButton addTarget:self action:@selector(showHogStatistics:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) editingFinished:(NSNotification *)notification {
    [self updateExtraAction];
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

-(IBAction) showHiddenApps:(id)sender {
    [super changeEditingState];
}

- (IBAction) showHogStatistics:(id)sender {
    HogStatisticsViewController *controller = [[HogStatisticsViewController alloc]initWithNibName:@"HogStatisticsViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_content release];
    [_contentTitle release];
    [_extraButton release];
    [super dealloc];
}
@end
