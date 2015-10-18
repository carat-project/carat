//
//  BugsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BugsViewController.h"

#import "Utilities.h"
#import "SVPullToRefresh.h"
#import "CaratConstants.h"

@interface BugsViewController ()
@end


@implementation BugsViewController
@synthesize report;

static NSString * expandedCell = @"BugHogExpandedTableViewCell";
static NSString * collapsedCell = @"BugHogTableViewCell";

#pragma mark - View Life Cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"viewDidLoad tableView ref: %@", _tableView);
    _expandedCells = [[NSMutableArray alloc]init];
    [_tableView registerNib:[UINib nibWithNibName:collapsedCell bundle:nil] forCellReuseIdentifier:collapsedCell];
    [_tableView registerNib:[UINib nibWithNibName:expandedCell bundle:nil] forCellReuseIdentifier:expandedCell];
    
    [self setReport:[[CoreDataManager instance] getBugs:NO withoutHidden:YES]];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        if ([[CommunicationManager instance] isInternetReachable] == YES && // online
            [[CoreDataManager instance] getReportUpdateStatus] == nil) // not already updating
        {
            [[CoreDataManager instance] updateLocalReportsFromServer];
            [self updateView];
        }
    }];
    
    [self updateView];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[CoreDataManager instance] getReportUpdateStatus] == nil) {
        [self.tableView.pullToRefreshView stopAnimating];
    } else {
        [self.tableView.pullToRefreshView startAnimating];
    }
    
    [self setReport:[[CoreDataManager instance] getBugs:NO withoutHidden:YES]];
    
    [[CoreDataManager instance] checkConnectivityAndSendStoredDataToServer];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sampleCountUpdated:) name:kSamplesSentCountUpdateNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDataWithHUD:)
                                                 name:NSLocalizedString(@"CCDMReportUpdateStatusNotification", nil)
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSLocalizedString(@"CCDMReportUpdateStatusNotification", nil) object:nil];
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
    HogBugReport * bugs = [[CoreDataManager instance] getBugs:NO withoutHidden:YES];
    if (bugs != nil) {
        [self setReport:bugs];
    }
}

-(void)sampleCountUpdated:(NSNotification*)notification{
    
    if(self.tableView)
        [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (report != nil && [report hbListIsSet]) {
        return [[report hbList] count];
    } else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = nil;
    if ([self.expandedCells containsObject:indexPath])
    {
        cellIdentifier = expandedCell;
    }
    else{
        cellIdentifier = collapsedCell;
    }

    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //BugHogListItemData *rowData = [_tableData objectAtIndex:indexPath.row];
    HogsBugs *hb = [[report hbList] objectAtIndex:indexPath.row];
    if ([[cell reuseIdentifier] isEqualToString:expandedCell]) {
        BugHogExpandedTableViewCell *expandedCell = (BugHogExpandedTableViewCell *)cell;
       
        [self setTopRowData:hb cell:expandedCell];
        
        expandedCell.samplesValueLabel.text = [[NSNumber numberWithDouble:[hb samples]] stringValue];
        expandedCell.samplesWithoutValueLabel.text = [[NSNumber numberWithDouble:[hb samplesWithout]] stringValue];
        expandedCell.errorValueLabel.text = [[NSNumber numberWithDouble:[hb error]] stringValue];
    }
    else{
        BugHogTableViewCell *collapsedCell = (BugHogTableViewCell *)cell;
        [self setTopRowData:hb cell:collapsedCell];
    }
    
    return cell;
}

-(void)setTopRowData:(HogsBugs *)hb cell:(BugHogTableViewCell *)cell
{
    NSString *appName = [hb appName];
    cell.nameLabel.text = appName;
    
    NSString *imageURL = [[@"https://s3.amazonaws.com/carat.icons/"
                           stringByAppendingString:appName]
                          stringByAppendingString:@".jpg"];
    [cell.thumbnailAppImg setImageWithURL:[NSURL URLWithString:imageURL]
                                 placeholderImage:[UIImage imageNamed:@"icon57.png"]];
    
    
    double benefit = (100/[hb expectedValueWithout] - 100/[hb expectedValue]);
    double benefit_max = (100/([hb expectedValueWithout]-[hb errorWithout]) - 100/([hb expectedValue]+[hb error]));
    double error = benefit_max-benefit;
    NSString *impValue =  [NSString stringWithFormat:@"%@ ± %@", [Utilities doubleAsTimeNSString:benefit], [Utilities doubleAsTimeNSString:error]];
    NSString *bodyText = NSLocalizedString(@"ExpectedImp", nil);
    NSMutableString *expImpLabelText = [[NSMutableString alloc]init];
    [expImpLabelText appendString:bodyText];
    [expImpLabelText appendString:impValue];
    cell.expImpTimeLabel.text = expImpLabelText;
    [expImpLabelText release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    
    if ([self.expandedCells containsObject:indexPath])
    {
        [self.expandedCells removeObject:indexPath];
    }
    else
    {
        [self.expandedCells addObject:indexPath];
    }
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    [tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat kExpandedCellHeight = 196;
    CGFloat kNormalCellHeigh = 56;
    
    if ([self.expandedCells containsObject:indexPath])
    {
        NSLog(@"expanded View");
        return kExpandedCellHeight; //It's not necessary a constant, though
    }
    else
    {
        return kNormalCellHeigh; //Again not necessary a constant
    }
}


#pragma mark - MBProgressHUDDelegate method

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    DLog(@"%s hudWasHidden", __PRETTY_FUNCTION__);
}

- (void)loadDataWithHUD:(id)obj
{
    if ([[CoreDataManager instance] getReportUpdateStatus] != nil) {
        // update in progress, only update footer
        [self.tableView reloadData];
        [self.view setNeedsDisplay];
    } else {
        // *probably* no update in progress, reload table data while locking out view
        [self.tableView.pullToRefreshView stopAnimating];
    }
}



- (void)dealloc {
    [_tableView release];
    [_expandedCells release];
    [report release];
    [super dealloc];
}
@end
