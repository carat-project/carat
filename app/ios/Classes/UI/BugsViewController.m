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
    // Do any additional setup after loading the view from its nib.
    [self setHogBugReport:[[CoreDataManager instance] getBugs:NO withoutHidden:YES]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setHogBugReport:[[CoreDataManager instance] getBugs:NO withoutHidden:YES]];
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
    [_contentTitle release];
    [_content release];
    [super dealloc];
}
@end
