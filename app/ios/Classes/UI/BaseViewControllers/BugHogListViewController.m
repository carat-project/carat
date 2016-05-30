//
//  BugHogListViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 17/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BugHogListViewController.h"

@interface BugHogListViewController ()
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, assign) BOOL handlesBugs;
@end

@implementation BugHogListViewController
@synthesize report;
@synthesize filteredCells;


#pragma mark - View Life Cycle methods
- (void)viewDidLoad {
    _editing = false;
    expandedCell = @"BugHogExpandedTableViewCell";
    collapsedCell = @"BugHogTableViewCell";
    filteredCells = [[NSMutableArray alloc]init];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self addFooter];
}

- (void) addFooter {
    long width = self.tableView.frame.size.width;
    long height = 50;
    long buttonWidth = width;
    long buttonHeight = 30;
    
    // Create a centered button for hiding items
    CGRect buttonFrame = CGRectMake((width/2)-(buttonWidth/2),
                                    (height/2)-buttonHeight, buttonWidth, buttonHeight);
    _button = [[UIButton alloc] initWithFrame:buttonFrame];
    _button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    [_button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_button setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
    [_button setTitleColor: [UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [_button addTarget:self action:@selector(changeEditingState) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *buttonTitle = [NSLocalizedString(@"HideShowApps", nil) uppercaseString];
    [_button setTitle:buttonTitle forState:UIControlStateNormal];
    
    // Create footer view and attach button to it
    CGRect frame = CGRectMake(0, 0, width, height);
    UIView *footer = [[UIView alloc] initWithFrame:frame];
    footer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [footer addSubview:_button];
    
    self.tableView.tableFooterView = footer;
}

- (void) setBug:(BOOL)isBug{
    _handlesBugs = isBug;
}

- (void) changeEditingState {
    HogBugReport *array = nil;
    NSString *buttonTitle = @"";
    if(_editing) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditingFinished" object:nil];
        buttonTitle = [NSLocalizedString(@"HideShowApps", nil) uppercaseString];
    } else {
        buttonTitle = [NSLocalizedString(@"Done", nil) uppercaseString];
    }
    [UIView animateWithDuration:0.3f animations:^{
        [_button setAlpha:0.0f];
        [_button setTitle:buttonTitle forState:UIControlStateNormal];
        [_button setAlpha:1.0f];
    }];
    
    _editing = !_editing;
    
    // Toggle between filtered and all applications
    if(_handlesBugs) {
        array = [[CoreDataManager instance] getBugs:NO withoutHidden:!_editing];
    } else {
        array = [[CoreDataManager instance] getHogs:NO withoutHidden:!_editing];
    }

    self.tableView.allowsSelection = !_editing;
    [self.expandedCells removeAllObjects];
    [self setHogBugReport:array];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_editing) { // Just in case
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [filteredCells removeAllObjects];
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
    DLog(@"%s", __PRETTY_FUNCTION__);
    if (filteredCells != nil) {
        return [filteredCells count];
    } else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    UITableViewCell *cell = [super tableView: tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
    
    if(filteredCells == nil || [filteredCells count]==0) return cell;
    
    HogsBugs *hb = [filteredCells objectAtIndex:indexPath.row];
    BugHogTableViewCell *cellView = (BugHogTableViewCell *)cell;
    
    [self setupHideButton:hb cell:cellView indexPath:indexPath];
    
    if ([[cell reuseIdentifier] isEqualToString:expandedCell]) {
        [self setTopRowData:hb cell:cellView];
        cellView.samplesValueLabel.text = [[NSNumber numberWithDouble:[hb samples]] stringValue];
        cellView.samplesWithoutValueLabel.text = [[NSNumber numberWithDouble:[hb samplesWithout]] stringValue];
        
        
        double error = [self getErrorMinutes:hb];
        NSString *errorLabel = [Utilities doubleAsTimeNSString:error];
        if(errorLabel == nil || [errorLabel length] == 0) {
            errorLabel = NSLocalizedString(@"None", nil);
        }
        cellView.errorValueLabel.text = errorLabel;

        cellView.numerHelpTapArea.tag = indexPath.row;
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [cellView.numerHelpTapArea addGestureRecognizer:singleFingerTap];
        [singleFingerTap release];
    }
    else{
        
        [self setTopRowData:hb cell:cellView];
    }
    
    return cell;
}

- (void) setupHideButton:(HogsBugs *)hb cell:(BugHogTableViewCell *)cell indexPath:(NSIndexPath *)path {
    NSString *show = [NSLocalizedString(@"Show", nil) uppercaseString];
    UIColor *red = [UIColor colorWithRed:65.0f/255.0f green:164.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
    UIColor *green = [UIColor colorWithRed:146.0f/255.0f green:19.0f/255.0f blue:10.0f/255.0f alpha:1.0f];
    NSString *hide = [NSLocalizedString(@"Hide", nil) uppercaseString];
    [UIView performWithoutAnimation:^{
        [cell.hideButton setTitle:show forState:UIControlStateNormal];
        [cell.hideButton setTitleColor:green forState:UIControlStateNormal];
        if(![[Globals instance] isAppHidden:hb.appName]){
            [cell.hideButton setTitle:hide forState:UIControlStateNormal];
            [cell.hideButton setTitleColor:red forState:UIControlStateNormal];
        }
        cell.hideButton.tag = path.row;
        [self addHideListener: cell];
        if(_editing){
            cell.hideButton.hidden = NO;
            cell.expandBtn.hidden = YES;
        } else {
            cell.hideButton.hidden = YES;
            cell.expandBtn.hidden = NO;
        }
    }];
}

-(void) addHideListener:(BugHogTableViewCell *) cell {
    [cell.hideButton addTarget:self action:@selector(toggleHidden:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) toggleHidden:(UIButton *)sender{
    UIColor *red = [UIColor colorWithRed:65.0f/255.0f green:164.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
    UIColor *green = [UIColor colorWithRed:146.0f/255.0f green:19.0f/255.0f blue:10.0f/255.0f alpha:1.0f];
    
    NSInteger *tag = sender.tag;
    HogsBugs *hb = [filteredCells objectAtIndex:tag];
    NSString *appName = [hb appName];
    if([[Globals instance] isAppHidden:appName]) {
        [UIView animateWithDuration:0.3f animations:^{
            [sender setAlpha:0.0f];
            [sender setTitleColor:red forState:UIControlStateNormal];
            [sender setTitle:@"HIDE" forState:UIControlStateNormal];
            [sender setAlpha:1.0f];
        }];
        [[Globals instance] showApp:appName];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            [sender setAlpha:0.0f];
            [sender setTitleColor:green forState:UIControlStateNormal];
            [sender setTitle:@"SHOW" forState:UIControlStateNormal];
            [sender setAlpha:1.0f];
        }];
        [[Globals instance] hideApp:appName];
    }
}

-(double)getErrorMinutes:(HogsBugs *)hb {
    double benefit = (100/[hb expectedValueWithout] - 100/[hb expectedValue]);
    double benefit_max = (100/([hb expectedValueWithout]-[hb errorWithout]) - 100/([hb expectedValue]+[hb error]));
    return benefit_max-benefit;
}

-(void)setTopRowData:(HogsBugs *)hb cell:(BugHogTableViewCell *)cell
{
    NSString *appName = [hb appName];
    cell.nameLabel.text = appName;
    
    /*NString *imageURL = [[@"https://s3.amazonaws.com/carat.icons/"
                           stringByAppendingString:appName]
                          stringByAppendingString:@".jpg"];*/
    UIImage *defaultIcon = [UIImage imageNamed:@"def_app_icon"];
    NSString *imageURI = [[Globals instance] getStringForKey:[appName lowercaseString]];
    if(imageURI != nil && [imageURI length] > 0){
        [cell.thumbnailAppImg setImageWithURL:[NSURL URLWithString:imageURI]
                             placeholderImage:defaultIcon];
    } else {
        [cell.thumbnailAppImg setImage:defaultIcon];
    }
    
    
    double error = [self getErrorMinutes:hb];
    double benefit = (100/[hb expectedValueWithout] - 100/[hb expectedValue]);
    NSString *impValue = [NSString stringWithFormat:@"%@", [Utilities doubleAsTimeNSString:benefit]];
    NSString *errorString = [Utilities doubleAsTimeNSString:error];
    if(errorString && errorString.length > 0){
        impValue = [impValue stringByAppendingString:[NSString stringWithFormat:@"± %@", errorString]];
    }
    NSString *bodyText = NSLocalizedString(@"ExpectedImp", nil);
    NSMutableString *expImpLabelText = [[NSMutableString alloc]init];
    [expImpLabelText appendString:bodyText];
    [expImpLabelText appendString:impValue];
    cell.expImpTimeLabel.text = expImpLabelText;
    [expImpLabelText release];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    CGFloat kExpandedCellHeight = 196;
    CGFloat kNormalCellHeigh = 56;
    
    if ([self.expandedCells containsObject:indexPath] && !_editing)
    {
        NSLog(@"expanded View");
        return kExpandedCellHeight; //It's not necessary a constant, though
    }
    else
    {
        return kNormalCellHeigh; //Again not necessary a constant
    }
}

- (void) setHogBugReport:(HogBugReport *)rep
{
    report = rep;
    if (report != nil && [report hbListIsSet]) {
        int count = (int)[[report hbList] count];
        NSArray *hbList = [report hbList]; //[[ objectAtIndex:indexPath.row];
        float filterVal = [[Globals instance] getHideConsumptionLimit];
        DLog(@"%s filtred val %f", __PRETTY_FUNCTION__, filterVal);
        [filteredCells removeAllObjects];
        for(int i=0; i<count; i++)
        {
            HogsBugs *hb = hbList[i];
            double benefit = (100/[hb expectedValueWithout] - 100/[hb expectedValue]);
            if(benefit > filterVal){
                [filteredCells addObject: hb];
            }
        }
        if([filteredCells count] > 0){
            [self.tableView reloadData];
        }
        DLog(@"%s cells filtered:%d ", __PRETTY_FUNCTION__, (count - (int)[filteredCells count]));

    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self showWhatTheseNumbersMeanInfo];
}

#pragma mark - Navigation methods
- (void)showWhatTheseNumbersMeanInfo{
    DLog(@"%s", __PRETTY_FUNCTION__);
    WebInfoViewController *controler = [[WebInfoViewController alloc]initWithNibName:@"WebInfoViewController" bundle:nil];
    controler.webUrl = @"detailinfo";
    controler.titleForView =  NSLocalizedString(@"NumberHelpLabel", nil);
    [self.navigationController pushViewController:controler animated:YES];
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
    [filteredCells release];
    [super dealloc];
}
@end
