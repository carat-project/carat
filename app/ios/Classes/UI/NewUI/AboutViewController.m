//
//  AboutViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 12/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

static NSString * expandedCell = @"AboutExpandedTableViewCell";
static NSString * collapsedCell = @"AboutCollapsedTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self creteData];
    NSLog(@"viewDidLoad tabledata count: %d", [_tableData count]);
    NSLog(@"viewDidLoad tableView ref: %@", _tableView);
    _expandedCells = [[NSMutableArray alloc]init];
    [_tableView registerNib:[UINib nibWithNibName:collapsedCell bundle:nil] forCellReuseIdentifier:collapsedCell];
    [_tableView registerNib:[UINib nibWithNibName:expandedCell bundle:nil] forCellReuseIdentifier:expandedCell];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (NSArray *)tableData
{
    if (!_tableData)
    {
        [self creteData];
    }
    return _tableData;
}

-(void) creteData{
    
    AboutListItemData* d1 = [AboutListItemData new];
    d1.title = NSLocalizedString(@"AboutTittle", nil);
    d1.subTitle = NSLocalizedString(@"AboutSub", nil);
    d1.message = NSLocalizedString(@"AboutMessage", nil);
    
    AboutListItemData* d2 = [AboutListItemData new];
    d2.title = NSLocalizedString(@"Actions", nil);
    d2.subTitle = NSLocalizedString(@"ActionsSub", nil);
    d2.message = NSLocalizedString(@"ActionsMessage", nil);
    
    AboutListItemData* d3 = [AboutListItemData new];
    d3.title = NSLocalizedString(@"Bugs", nil);
    d3.subTitle = NSLocalizedString(@"BugsSub", nil);
    d3.message = NSLocalizedString(@"BugsDesc", nil);
    
    AboutListItemData* d4 = [AboutListItemData new];
    d4.title = NSLocalizedString(@"Hogs", nil);
    d4.subTitle = NSLocalizedString(@"HogsSub", nil);
    d4.message = NSLocalizedString(@"HogsDesc", nil);
    
    AboutListItemData* d5 = [AboutListItemData new];
    d5.title = NSLocalizedString(@"CollectData", nil);
    d5.subTitle = NSLocalizedString(@"CollectDataSub", nil);
    d5.message = NSLocalizedString(@"CollectDataMessage", nil);
    
    AboutListItemData* d6 = [AboutListItemData new];
    d6.title = NSLocalizedString(@"ActiveBatteryLife", nil);
    d6.subTitle = NSLocalizedString(@"ActiveBatteryLifeSub", nil);
    d6.message = NSLocalizedString(@"ActiveBatteryLifeMessage", nil);
    
    _tableData = [[NSArray alloc] initWithObjects:d1, d2, d3, d4, d5, d6, nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"tabledata count: %d", [_tableData count]);
    return [_tableData count];
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
    
    AboutListItemData *rowData = [_tableData objectAtIndex:indexPath.row];
    if ([[cell reuseIdentifier] isEqualToString:expandedCell]) {
        AboutExpandedTableViewCell *expandedCell = (AboutExpandedTableViewCell *)cell;
        expandedCell.title.text = rowData.title;
        expandedCell.subTitle.text = rowData.subTitle;
        if([rowData.title isEqualToString: NSLocalizedString(@"Bugs", nil)]){
            expandedCell.subTitle.textColor = C_ORANGE;
        }
        else if([rowData.title isEqualToString: NSLocalizedString(@"Hogs", nil)]){
            expandedCell.subTitle.textColor = C_ORANGE;
        }
        else{
            expandedCell.subTitle.textColor = C_LIGHT_GRAY;
        }
        expandedCell.message.text = rowData.message;
    }
    else{
        AboutCollapsedTableViewCell *collapsedCell = (AboutCollapsedTableViewCell *)cell;
        collapsedCell.title.text = rowData.title;
        collapsedCell.subTitle.text = rowData.subTitle;
        if([rowData.title isEqualToString: NSLocalizedString(@"Bugs", nil)]){
            collapsedCell.subTitle.textColor = C_ORANGE;
        }
        else if([rowData.title isEqualToString: NSLocalizedString(@"Hogs", nil)]){
            collapsedCell.subTitle.textColor = C_ORANGE;
        }
        else{
            collapsedCell.subTitle.textColor = C_LIGHT_GRAY;
        }

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
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat kExpandedCellHeight = 196;
    CGFloat kNormalCellHeigh = 56;
    
    if ([self.expandedCells containsObject:indexPath])
    {
        AboutListItemData *rowData = [_tableData objectAtIndex:indexPath.row];
        CGFloat expandedTextHeight = 56.0f + [self getTextHeight:rowData.message] + 14.0f;//margins 7 +7
        NSLog(@"expandedTextHeight: %f", expandedTextHeight);
        
        return expandedTextHeight; //It's not necessary a constant, though
    }
    else
    {
        return kNormalCellHeigh; //Again not necessary a constant
    }
}


-(CGFloat)getTextHeight:(NSString *)text
{
    UIFont *font = [UIFont systemFontOfSize:12];//[UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    
    CGRect frame = [self getTextFrame:text font:font top:0];
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
