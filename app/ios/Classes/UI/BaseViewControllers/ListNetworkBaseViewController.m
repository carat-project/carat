//
//  ListNetworkBaseViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 17/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ListNetworkBaseViewController.h"

@interface ListNetworkBaseViewController ()
@end

@implementation ListNetworkBaseViewController
@synthesize collapsedCell;
@synthesize expandedCell;
#pragma mark - View Life Cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    _expandedCells = [[NSMutableArray alloc]init];
    [_tableView registerNib:[UINib nibWithNibName:collapsedCell bundle:nil] forCellReuseIdentifier:collapsedCell];
    [_tableView registerNib:[UINib nibWithNibName:expandedCell bundle:nil] forCellReuseIdentifier:expandedCell];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        if ([[CommunicationManager instance] isInternetReachable] == YES && // online
            [[CoreDataManager instance] getReportUpdateStatus] == nil) // not already updating
        {
            [[CoreDataManager instance] updateLocalReportsFromServer];
            [self updateView];
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[CoreDataManager instance] getReportUpdateStatus] == nil) {
        [self.tableView.pullToRefreshView stopAnimating];
    } else {
        [self.tableView.pullToRefreshView startAnimating];
    }
    
    [[CoreDataManager instance] checkConnectivityAndSendStoredDataToServer];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sampleCountUpdated:) name:kSamplesSentCountUpdateNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSamplesSentCountUpdateNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([self tableView:self.tableView numberOfRowsInSection:0] > 0){
        NSTimeInterval howLong = [[NSDate date] timeIntervalSinceDate:[[CoreDataManager instance] getLastReportUpdateTimestamp]];
        return [Utilities formatNSTimeIntervalAsUpdatedNSString:howLong];
    }
    return @"";
}
//let sub class work its magick on these
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
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
    return cell;
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
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

#pragma mark - -HUD methods
- (void)loadDataWithHUD:(id)obj
{
    @synchronized([CoreDataManager instance]) {
        if ([[CoreDataManager instance] getReportUpdateStatus] != nil) {
            // update in progress, only update footer
            [self.tableView reloadData];
            self.tableView.pullToRefreshView.titleLabel.text = [[CoreDataManager instance] getReportUpdateStatus];
            [self.view setNeedsDisplay];
        } else {
            // *probably* no update in progress, reload table data while locking out view
            [self.tableView.pullToRefreshView stopAnimating];
        }
    }
}
#pragma mark - MBProgressHUDDelegate method
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    self.tableView.pullToRefreshView.titleLabel.text = @"";
}
-(void)sampleCountUpdated:(NSNotification*)notification{
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
    [_tableView release];
    [_expandedCells release];
    [expandedCell release];
    [collapsedCell release];
    [super dealloc];
}
@end
