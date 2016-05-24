//
//  BugsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BugsViewController.h"

@interface BugsViewController ()
@end


@implementation BugsViewController

#pragma mark - View Life Cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    _contentTitle.text = NSLocalizedString(@"NothingToReport",nil);
    _content.text = NSLocalizedString(@"EmptyViewDesc",nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingFinished:)
                                                 name:@"EditingFinished" object:nil];
    
    // Do any additional setup after loading the view from its nib.
    [self setBug:YES];
    [self setHogBugReport:[[CoreDataManager instance] getBugs:NO withoutHidden:YES]];

}

- (void) updateExtraAction {
    NSArray *hidden = [[Globals instance] getHiddenApps];
    HogBugReport *all = [[CoreDataManager instance] getBugs:NO withoutHidden:NO];
    
    if(hidden != nil && [hidden count] != 0 && all != nil && [all.hbList count] != 0){
        [_extraAction setHidden:NO];
        [_extraAction setTitle:[NSLocalizedString(@"ShowHiddenApps", nil) uppercaseString] forState:UIControlStateNormal];
        [_extraAction addTarget:self action:@selector(showHiddenApps:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) editingFinished:(NSNotification *)notification {
    [self updateExtraAction];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setHogBugReport:[[CoreDataManager instance] getBugs:NO withoutHidden:YES]];
}

- (IBAction)showHiddenApps:(id)sender {
    [super changeEditingState];
}

- (void)updateView {
    [self reloadReport];
    if (self.report != nil) {
        [self.tableView reloadData];
    }
    [self.view setNeedsDisplay];
}

- (void)reloadReport {
    HogBugReport * bugs = [[CoreDataManager instance] getBugs:NO withoutHidden:YES];
    if (bugs != nil) {
        [self setHogBugReport:bugs];
    }
}

-(void)sampleCountUpdated:(NSNotification*)notification{
    if(self.tableView)
        [self.tableView reloadData];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_contentTitle release];
    [_content release];
    [_extraAction release];
    [super dealloc];
}
@end
