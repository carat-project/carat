//
//  ProcessViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 13/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ProcessViewController.h"
#import "Preprocessor.h"
#import "CoreDataManager.h"
#import "UIImageView+WebCache.h"
#import "CaratProcessCache.h"
#ifdef USE_INTERNALS
    #import "CaratInternals.h"
#endif

@interface ProcessViewController ()

@end

@implementation ProcessViewController
@synthesize processList;


- (void)viewDidLoad {
    expandedCell = @"BugHogExpandedTableViewCell";
    collapsedCell = @"BugHogTableViewCell";
    _navigationBar.title = [NSLocalizedString(@"ProcessList", nil) uppercaseString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:)
                                         name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)refreshView:(NSNotification *)notification {
    [self updateView];
}

- (void)updateView
{
    if(floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_9_0){
        self.processList = [[UIDevice currentDevice] runningProcesses];
        [self.tableView reloadData];
        [self.view setNeedsDisplay];
    }
    #ifdef USE_INTERNALS
    else {
        [[CaratProcessCache instance] getProcessList:^(NSArray *result) {
            
            // Sort by icon available, then alphabetical order
            self.processList = [result sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSDictionary *p1 = (NSDictionary *)obj1;
                NSDictionary *p2 = (NSDictionary *)obj2;
                NSString *i1 = [p1 objectForKey:@"ProcessIcon"];
                NSString *i2 = [p2 objectForKey:@"ProcessIcon"];
                if(((i1 == nil || [i1 length] == 0) && (i2 == nil || [i2 length] == 0)) ||
                   ((i1 != nil && [i1 length] > 0) && (i2 != nil && [i2 length] > 0))){
                    NSString *n1 = [p1 objectForKey:@"ProcessName"];
                    NSString *n2 = [p2 objectForKey:@"ProcessName"];
                    return [n1 compare:n2];
                }
                if(i1 != nil && [i1 length] > 0) return NSOrderedAscending;
                else return NSOrderedDescending;
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.view setNeedsDisplay];
            });
        }];
    }
    #endif
}

#pragma mark - table methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.processList != nil) {
        return [self.processList count];
    } else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView: tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
    NSDictionary *selectedProc = [self.processList objectAtIndex:indexPath.row];
    BugHogTableViewCell *cellView = (BugHogTableViewCell *)cell;
   [self setTopRowData:selectedProc cell:cellView];
    [cellView.expandBtn setHidden:YES];
    
    return cell;
}

-(void)setTopRowData:(NSDictionary *)selectedProc cell:(BugHogTableViewCell *)cell
{
    NSString *appName = [selectedProc objectForKey:@"ProcessName"];
    cell.nameLabel.text = appName;
    
    UIImage *defaultIcon = [UIImage imageNamed:@"def_app_icon"];
    NSString *iconUri = [selectedProc objectForKey:@"ProcessIcon"];
    if(iconUri != nil){
        [cell.thumbnailAppImg setImageWithURL:[NSURL URLWithString:iconUri]
                             placeholderImage:defaultIcon];
    } else {
        [cell.thumbnailAppImg setImage:defaultIcon];
    }
    
    
    /*
    NSString *imageURL = [[@"https://s3.amazonaws.com/carat.icons/"
                           stringByAppendingString:appName]
                          stringByAppendingString:@".jpg"];
    [cell.thumbnailAppImg setImageWithURL:[NSURL URLWithString:imageURL]
                         placeholderImage:[UIImage imageNamed:@"def_app_icon"]];
    */
    
    cell.expImpTimeLabel.text = [selectedProc objectForKey:@"ProcessID"];
}

//Override super classes expandaple list item since this list doesn't seem to contain any expandaple
//data
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat kExpandedCellHeight = 196;
    CGFloat kNormalCellHeigh = 56;
    
    if ([self.expandedCells containsObject:indexPath])
    {
        return kExpandedCellHeight; //It's not necessary a constant, though
    }
    else
    {
        return kNormalCellHeigh; //Again not necessary a constant
    }
}


- (IBAction)showMessage
{
    UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                    initWithTitle:@"My First App" message:@"Hello, World!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display the Hello World Message
    [helloWorldAlert show];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [processList release];
    [_navigationBar release];
    [super dealloc];
}
@end
