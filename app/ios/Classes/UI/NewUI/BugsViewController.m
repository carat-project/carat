//
//  BugsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BugsViewController.h"
#import "BugHogListItemData.h"

@interface BugsViewController ()

@end

@implementation BugsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self creteDummyData];
    NSLog(@"viewDidLoad tabledata count: %d", [_tableData count]);
    NSLog(@"viewDidLoad tableView ref: %@", _tableView);
    _expandedCells = [[NSMutableArray alloc]init];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
  
}

- (NSArray *)tableData
{
    if (!_tableData)
    {
        [self creteDummyData];
    }
    return _tableData;
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"tabledata count: %d", [_tableData count]);
    return [_tableData count];
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[BugHogTableViewCell class]])
    {
        BugHogTableViewCell *bugHogCell = (BugHogTableViewCell *)cell;
        BugHogListItemData *rowData = [_tableData objectAtIndex:indexPath.row];
        bugHogCell.nameLabel.text = rowData.title;
        bugHogCell.thumbnailAppImg.image = [UIImage imageNamed:rowData.imageName];
        bugHogCell.expImpTimeLabel.text = rowData.expImpTxt;
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView cellForRowAtIndexPath **********");
    BugHogExpandedTableViewCell *cell;
    static NSString *simpleTableIdentifier = @"BugHogExpandedTableViewCell";
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:simpleTableIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    BugHogListItemData *rowData = [_tableData objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = rowData.title;
    cell.thumbnailAppImg.image = [UIImage imageNamed:rowData.imageName];
    NSString *bodyText = NSLocalizedString(@"ExpectedImp", nil);
    NSMutableString *expImpLabelText = [[NSMutableString alloc]init];
    [expImpLabelText appendString:bodyText];
    [expImpLabelText appendString:rowData.expImpTxt];
    cell.expImpTimeLabel.text = expImpLabelText;
    [expImpLabelText release];
    
    cell.samplesValueLabel.text = rowData.samples;
    cell.samplesWithoutValueLabel.text = rowData.samplesWithout;
    cell.errorValueLabel.text = rowData.error;
   
    if ([self.expandedCells containsObject:indexPath])
    {
        [cell.expandContent setHidden:NO];
        [cell.expandBtn setImage:[UIImage imageNamed:@"collapse_btn_close"]];
    }
    else{
        [cell.expandContent setHidden:YES];
        [cell.expandBtn setImage:[UIImage imageNamed:@"collapse_bnt_open"]];
    }
    
    

    /*
    if ([self.expandedCells containsObject:indexPath])
    {
        
        static NSString *simpleTableIdentifier = @"BugHogExpandedTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:simpleTableIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        BugHogExpandedTableViewCell *expCell = (BugHogExpandedTableViewCell *) cell;
        BugHogListItemData *rowData = [_tableData objectAtIndex:indexPath.row];
        [self setTopRowData:rowData cell:expCell];
        expCell.samplesValueLabel.text = rowData.samples;
        expCell.samplesWithoutValueLabel.text = rowData.samplesWithout;
        expCell.errorValueLabel.text = rowData.error;
    }
    else
    {
        static NSString *simpleTableIdentifier = @"BugHogTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:simpleTableIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        BugHogListItemData *rowData = [_tableData objectAtIndex:indexPath.row];
        [self setTopRowData:rowData cell:cell];
       
    }
    */
    return cell;
}

-(void)setTopRowData:(BugHogListItemData *)rowData cell:(BugHogExpandedTableViewCell *)cell
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BugHogExpandedTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.expandedCells containsObject:indexPath])
    {
        [cell.expandBtn setImage: [UIImage imageNamed:@"collapse_btn_open"]];
        [cell.expandContent setHidden:YES];
        [self.expandedCells removeObject:indexPath];
        
    }
    else
    {
        [cell.expandBtn setImage: [UIImage imageNamed:@"collapse_btn_close"]];
        [cell.expandContent setHidden:NO];
        [self.expandedCells addObject:indexPath];
    }
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat kExpandedCellHeight = 190;
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
    [_tableData release];
    [_tableView release];
    [_expandedCells release];
    [super dealloc];
}
@end
