//
//  BugHogListViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 17/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BugHogListViewController.h"

@interface BugHogListViewController ()

@end

@implementation BugHogListViewController
@synthesize report;
#pragma mark - View Life Cycle methods
- (void)viewDidLoad {
    expandedCell = @"BugHogExpandedTableViewCell";
    collapsedCell = @"BugHogTableViewCell";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
}
#pragma mark - UITableViewDelegate and UITableViewDataSource methods
//override superclasses
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (report != nil && [report hbListIsSet]) {
        return [[report hbList] count];
    } else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView: tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
    
    HogsBugs *hb = [[report hbList] objectAtIndex:indexPath.row];
    if ([[cell reuseIdentifier] isEqualToString:expandedCell]) {
        BugHogExpandedTableViewCell *expandedCellView = (BugHogExpandedTableViewCell *)cell;
        
        [self setTopRowData:hb cell:expandedCellView];
        
        expandedCellView.samplesValueLabel.text = [[NSNumber numberWithDouble:[hb samples]] stringValue];
        expandedCellView.samplesWithoutValueLabel.text = [[NSNumber numberWithDouble:[hb samplesWithout]] stringValue];
        expandedCellView.errorValueLabel.text = [[NSNumber numberWithDouble:[hb error]] stringValue];
    }
    else{
        BugHogTableViewCell *collapsedCellView = (BugHogTableViewCell *)cell;
        [self setTopRowData:hb cell:collapsedCellView];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
        [report release];
    [super dealloc];
}
@end
