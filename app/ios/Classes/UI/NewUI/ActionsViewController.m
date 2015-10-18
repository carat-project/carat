//
//  ActionsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ActionsViewController.h"

@interface ActionsViewController ()

@end

@implementation ActionsViewController
@synthesize actionList;
@synthesize tableViewCellsList;

#pragma mark - View Life Cycle methods
- (void)viewDidLoad {
    expandedCell = @"ActionItemExpandedTableViewCell"; //TODO change
    collapsedCell = @"ActionItemCollapsedTableViewCell";
    [super viewDidLoad];
    tableViewCellsList = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//overrides super completely (super updateView is empty function)
- (void)updateView {
    NSMutableArray *myList = [[[NSMutableArray alloc] init] autorelease];
    
    ActionObject *tmpAction;
    
    DLog(@"Loading Hogs");
    // get Hogs, filter negative actionBenefits, fill mutable array
    NSArray *tmp = [[CoreDataManager instance] getHogs:YES withoutHidden:YES].hbList;
    if (tmp != nil) {
        for (HogsBugs *hb in tmp) {
            if ([hb appName] != nil &&
                [hb expectedValue] > 0 &&
                [hb expectedValueWithout] > 0 &&
                [hb error] > 0 &&
                [hb errorWithout] > 0) {
                
                NSInteger benefit = (int) (100/[hb expectedValueWithout] - 100/[hb expectedValue]);
                NSInteger benefit_max = (int) (100/([hb expectedValueWithout]-[hb errorWithout]) - 100/([hb expectedValue]+[hb error]));
                NSInteger error = (int) (benefit_max-benefit);
                DLog(@"Benefit is %d ± %d for hog '%@'", benefit, error, [hb appName]);
                if (benefit > 60) { // TODO need positive gap, also check for below
                    tmpAction = [[ActionObject alloc] init];
                    [tmpAction setActionText:[@"Kill " stringByAppendingString:[hb appName]]];
                    [tmpAction setActionType:ActionTypeKillApp];
                    [tmpAction setActionBenefit:benefit];
                    [tmpAction setActionError:error];
                    [myList addObject:tmpAction];
                    [tmpAction release];
                }
            }
        }
    }
    
    DLog(@"Loading Bugs");
    // get Bugs, add to array
    tmp = [[CoreDataManager instance] getBugs:YES withoutHidden:YES].hbList;
    if (tmp != nil) {
        for (HogsBugs *hb in tmp) {
            if ([hb appName] != nil &&
                [hb expectedValue] > 0 &&
                [hb expectedValueWithout] > 0 &&
                [hb error] > 0 &&
                [hb errorWithout] > 0) {
                
                NSInteger benefit = (int) (100/[hb expectedValueWithout] - 100/[hb expectedValue]);
                NSInteger benefit_max = (int) (100/([hb expectedValueWithout]-[hb errorWithout]) - 100/([hb expectedValue]+[hb error]));
                NSInteger error = (int) (benefit_max-benefit);
                DLog(@"Benefit is %d ± %d for bug '%@'", benefit, error, [hb appName]);
                if (benefit > 60) {
                    tmpAction = [[ActionObject alloc] init];
                    [tmpAction setActionText:[@"Restart " stringByAppendingString:[hb appName]]];
                    [tmpAction setActionType:ActionTypeRestartApp];
                    [tmpAction setActionBenefit:benefit];
                    [tmpAction setActionError:error];
                    [myList addObject:tmpAction];
                    [tmpAction release];
                }
            }
        }
    }
    
    DLog(@"Loading OS");
    // get OS
    DetailScreenReport *dscWith = [[[CoreDataManager instance] getOSInfo:YES] retain];
    DetailScreenReport *dscWithout = [[[CoreDataManager instance] getOSInfo:NO] retain];
    
    BOOL canUpgradeOS = [Utilities canUpgradeOS];
    
    if (dscWith != nil && dscWithout != nil) {
        if (dscWith.expectedValue > 0 &&
            dscWithout.expectedValue > 0 &&
            dscWith.error > 0 &&
            dscWithout.error > 0 &&
            canUpgradeOS) {
            NSInteger benefit = (int) (100/dscWithout.expectedValue - 100/dscWith.expectedValue);
            NSInteger benefit_max = (int) (100/(dscWithout.expectedValue - dscWithout.error) - 100/(dscWith.expectedValue + dscWith.error));
            NSInteger error = (int) (benefit_max-benefit);
            DLog(@"OS benefit is %d ± %d", benefit, error);
            if (benefit > 60) {
                tmpAction = [[ActionObject alloc] init];
                [tmpAction setActionText:@"Upgrade the Operating System"];
                [tmpAction setActionType:ActionTypeUpgradeOS];
                [tmpAction setActionBenefit:benefit];
                [tmpAction setActionError:error];
                [myList addObject:tmpAction];
                [tmpAction release];
            }
        }
    }
    
    [dscWith release];
    [dscWithout release];
    
    DLog(@"Loading Actions");
    
    // data collection action
    if ([myList count] == 0) {
        tmpAction = [[ActionObject alloc] init];
        [tmpAction setActionText:@"Help Carat Collect Data"];
        [tmpAction setActionType:ActionTypeCollectData];
        [tmpAction setActionBenefit:-1];
        [tmpAction setActionError:-1];
        [myList addObject:tmpAction];
        [tmpAction release];
    }
    
    // sharing Action
    /*tmpAction = [[ActionObject alloc] init];
     [tmpAction setActionText:@"Help Spread the Word"];
     [tmpAction setActionType:ActionTypeSpreadTheWord];
     [tmpAction setActionBenefit:-2];
     [tmpAction setActionError:-2];
     [myList addObject:tmpAction];
     [tmpAction release];
     */
    //the "key" is the *name* of the @property as a string.  So you can also sort by @"label" if you'd like
    [myList sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"actionBenefit" ascending:NO]]];
    
    [self setActionList:myList];
    [self.tableView reloadData];
    [self.view setNeedsDisplay];
}

#pragma mark - MBProgressHUDDelegate method
//show network communication states in GUI
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [super hudWasHidden:hud];
}

- (void)loadDataWithHUD:(id)obj
{
    [super loadDataWithHUD:obj];
}


#pragma mark - table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [actionList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"To improve battery life...";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView: tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
    [tableViewCellsList addObject:cell];
    
    // Set up the cell...
    ActionObject *act = [self.actionList objectAtIndex:indexPath.row];
    ActionItemCell *actCell = (ActionItemCell *)cell;
    [self setTopRowData:act cell:actCell];
    if ([[cell reuseIdentifier] isEqualToString:expandedCell]) {
        switch (act.actionType) {
            case ActionTypeKillApp:
                DLog(@"Loading Kill App instructions");
                actCell.actionDescription.text = @"";
                //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"killapp.html" relativeToURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]]];
                break;
                
            case ActionTypeRestartApp:
                DLog(@"Loading Restart App instructions");
                actCell.actionDescription.text = @"";
                //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"killapp.html" relativeToURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]]];
                break;
                
            case ActionTypeUpgradeOS:
                DLog(@"Loading Upgrade OS instructions");
                actCell.actionDescription.text = @"";
                //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"upgradeos.html" relativeToURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]]];
                break;
                
            case ActionTypeActiveBatteryLifeInfo:
                DLog(@"Loading Active Battery Life info");
                actCell.actionDescription.text = @"";
                self.navigationItem.title = @"Active Battery Life Info";
                //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"activebatterylife.html" relativeToURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]]];
                break;
                
            case ActionTypeJScoreInfo:
                DLog(@"Loading J-Score info");
                self.navigationItem.title = @"J-Score Info";
                actCell.actionDescription.text = @"";
                //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"jscoreinfo.html" relativeToURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]]];
                break;
                
            case ActionTypeMemoryInfo:
                DLog(@"Loading Memory info");
                self.navigationItem.title = @"Memory Info";
                actCell.actionDescription.text = @"";
                //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"memoryinfo.html" relativeToURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]]];
                break;
                
            case ActionTypeDetailInfo:
                DLog(@"Loading Detail info");
                self.navigationItem.title = @"Distribution Info";
                actCell.actionDescription.text = @"";
                //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"detailinfo.html" relativeToURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]]];
                break;
                
            case ActionTypeDimScreen:
                DLog(@"These instructions not yet implemented.");
                actCell.actionDescription.text = @"";
                //[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"] isDirectory:NO]]];
                break;
                
            case ActionTypeSpreadTheWord:
                DLog(@"Should not be loading InstructionView when ActionType is SpreadTheWord!");
                actCell.actionDescription.text = @"";
                //[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"] isDirectory:NO]]];
                break;
                
            case ActionTypeCollectData:
                DLog(@"Loading Data Collection info");
                actCell.actionDescription.text = @"";
                self.navigationItem.title = @"Data Collection Info";
                //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"collectdata.html" relativeToURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]]];
                break;
                
            default:
                DLog(@"Unrecognized Action Type!");
                actCell.actionDescription.text = @"";
                //[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"] isDirectory:NO]]];
                break;
        }
    }
    return cell;
}

-(void)setTopRowData:(ActionObject *)act cell:(ActionItemCell *)cell
{
    NSString *appName = act.actionText;
    cell.actionString.text = appName;
    
    //NSString *imageURL = [[@"https://s3.amazonaws.com/carat.icons/" stringByAppendingString:appName] stringByAppendingString:@".jpg"];
    //[cell.thumbnailAppImg setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"icon57.png"]];
    
    if (act.actionBenefit == -1) {
        cell.actionValue.text = @"better Carat results!";
        cell.actionType = ActionTypeCollectData;
    } else if (act.actionBenefit == -2) { // already filtered out benefits < 60 seconds
        cell.actionValue.text = @"+100 karma!";
        cell.actionType = ActionTypeSpreadTheWord;
    } else if (act.actionBenefit == -3) {
        cell.actionValue.text = @"See top Hogs and devices";
        cell.actionType = ActionTypeGlobalStats;
    }
    else {
        NSString *impValue = [NSString stringWithFormat:@"%@ ± %@", [Utilities doubleAsTimeNSString:act.actionBenefit], [Utilities doubleAsTimeNSString:act.actionError]];
        NSString *bodyText = NSLocalizedString(@"ExpectedImp", nil);
        NSMutableString *expImpLabelText = [[NSMutableString alloc]init];
        [expImpLabelText appendString:bodyText];
        [expImpLabelText appendString:impValue];
        cell.actionValue.text = expImpLabelText;
        cell.actionType = act.actionType;
        [expImpLabelText release];
        
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *tmpStatus = [[CoreDataManager instance] getReportUpdateStatus];
    if (tmpStatus == nil) {
        return [Utilities formatNSTimeIntervalAsUpdatedNSString:[[NSDate date] timeIntervalSinceDate:[[CoreDataManager instance] getLastReportUpdateTimestamp]]];
    } else {
        return tmpStatus;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //CGFloat kExpandedCellHeight = 196;
    CGFloat kNormalCellHeigh = 56;
    
    if ([self.expandedCells containsObject:indexPath])
    {
        ActionItemCell *cell = [tableViewCellsList objectAtIndex:indexPath.row];
        CGFloat expandedTextHeight = 56.0f + [self getTextHeight:cell.actionDescription] + 16.0f;//margins 8 + 8
        NSLog(@"expandedTextHeight: %f", expandedTextHeight);
        
        return expandedTextHeight; //It's not necessary a constant, though
    }
    else
    {
        return kNormalCellHeigh; //Again not necessary a constant
    }
}


-(CGFloat)getTextHeight:(UILabel *)label
{
    UIFont *font = label.font;//[UIFont systemFontOfSize:12];//[UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    
    CGRect frame = [self getTextFrame:label.text font:font top:0];
    return frame.size.height;
}

-(CGRect)getTextFrame:(NSString *)text font:(UIFont *) font top:(CGFloat)top
{
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(UI_SCREEN_W-14.0f, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    CGRect textRect = CGRectMake((UI_SCREEN_W / 2.0) - textSize.size.width/2.0, top, textSize.size.width, textSize.size.height);
    return textRect;
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
    [actionList release];
    [tableViewCellsList release];
    [super dealloc];
}
@end
