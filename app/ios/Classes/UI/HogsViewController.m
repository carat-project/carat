//
//  HogsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "Preprocessor.h"
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
    _navBarTitle.title = [NSLocalizedString(@"Apps", nil) uppercaseString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingFinished:)
                                                 name:@"EditingFinished" object:nil];
    
    // Process list is unavailable starting from iOS 9.3.3 so we want to
    // show a warning on the bottom of the view stating that apps are no
    // longer updating, but data is still being collected for settings.
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.3.3")){
        _bottomWarning.hidden = false;
    } else {
        _bottomWarning.hidden = true;
        _warningHeight.constant = 0;
    }
    [self updateExtraAction];
    [self setBug:NO];
    [self setHogBugReport:[self getHogBugReport]];
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
    [self setHogBugReport:[self getHogBugReport]];
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
    HogBugReport *all = [self getHogBugReport];
    if (all != nil) {
        [self setHogBugReport:all];
    }
}

- (HogBugReport *)getHogBugReport {
    HogBugReport *bugs = [[CoreDataManager instance] getBugs:NO withoutHidden:YES];
    HogBugReport *hogs = [[CoreDataManager instance] getHogs:NO withoutHidden:YES];
    NSMutableArray *hbList = [NSMutableArray array];
    for(HogsBugs* bug in bugs.hbList){
        bug.samplesWithout = 1;
        [hbList addObject:bug];
    }
    for(HogsBugs* hog in hogs.hbList){
        hog.samplesWithout = 0;
        [hbList addObject:hog];
    }
    
    HogBugReport *all = [HogBugReport new];
    all.hbList = hbList;
    return all;
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
    [_navBarTitle release];
    [_bottomWarning release];
    [_warningHeight release];
    [super dealloc];
}
@end
