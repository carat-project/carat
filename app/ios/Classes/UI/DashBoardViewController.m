//
//  DashBoardViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 29/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "DashBoardViewController.h"

#import "Utilities.h"
#import "CoreDataManager.h"
#import "CommunicationManager.h"
#import "UIDeviceHardware.h"
#import "Globals.h"
#import "Preprocessor.h"
#import "CaratProcessCache.h"
#import "UIImageDoNotCache.h"
#import "CaratConstants.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <TwitterKit/TwitterKit.h>

@implementation DashBoardViewController{
}
BOOL isUpdateProgressVisible;

#pragma mark - View Life Cycle methods
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self->MAX_LIFE = 1209600;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_shareBar setHidden:YES];
    
    isUpdateProgressVisible = false;
    
    [_bugsBtn setButtonImage:[UIImage imageNamed:@"bug_icon"]];
    [_bugsBtn setButtonTitle:NSLocalizedString(@"Bugs", nil)];
    
    [_hogsBtn setButtonImage:[UIImage imageNamed:@"battery_icon"]];
    [_hogsBtn setButtonTitle:NSLocalizedString(@"Hogs", nil)];
    
    [_statisticsBtn setButtonImage:[UIImage imageNamed:@"globe_icon"]];
    [_statisticsBtn setButtonExtraInfo:NSLocalizedString(@"ViewText", nil)];
    [_statisticsBtn setButtonTitle:NSLocalizedString(@"Statistics", nil)];
    
    [_actionsBtn setButtonImage:[UIImage imageNamed:@"action_icon"]];
    [_actionsBtn setButtonTitle:NSLocalizedString(@"Actions", nil)];
    
    [self updateCounts];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [super viewWillAppear:animated];
    [self updateView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sampleCountUpdated:) name:kSamplesSentCountUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldUpdateView:) name:kShouldRefreshViewsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(shouldUpdateView:)
        name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(shouldUpdateView:)
        name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:)
        name:@"DataUpdated" object:nil];
}

- (void)refreshView:(NSNotification *)notification {
    [self updateView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkReportsAndSamples];
    [self loadDataWithHUD:nil];
}

- (void) checkReportsAndSamples {
    if ([[CoreDataManager instance] getReportUpdateStatus] == nil) {
        // For this screen, let's put sending samples/registrations here so that we don't conflict
        // with the report syncing (need to limit memory/CPU/thread usage so that we don't get killed).
        if(![self isFresh] &&
           [[CommunicationManager instance] isInternetReachable]){
            [[CoreDataManager instance] updateLocalReportsFromServer];
        }
        [[CoreDataManager instance] checkConnectivityAndSendStoredDataToServer];
        [self setProgressUpdateViewHeight:40.0f];
    }
    else{
        [self setProgressUpdateViewHeight:0.0f];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSamplesSentCountUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DataUpdated" object:nil];
}

- (void)updateView
{
    // J-Score
    int vScore = (MIN( MAX([[CoreDataManager instance] getJScore], -1.0), 1.0)*100);
    // Expected Battery Life
    NSTimeInterval eb; // expected life in seconds
    double jev = [[[CoreDataManager instance] getJScoreInfo:YES] expectedValue];
    if(jev <= 0) jev = [[[CoreDataManager instance] getModelInfo:YES] expectedValue];
    if (jev > 0) eb = MIN(MAX_LIFE,100/jev);
    else eb = 0;
    NSString *vBatteryLife = [[Utilities doubleAsTimeNSString:eb] stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //Last updated
    [self sampleCountUpdated:nil];
    [self.scoreView setScore:vScore];
    self.batteryLastLabel.text = vBatteryLife;
    if(self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0f
                                target:self
                                selector:@selector(shouldUpdateView:)
                                userInfo:nil
                                repeats:true];
    }
    
     // Update hog, bug and action count
    [self updateCounts];
    [self.view setNeedsDisplay];
}

-(void) updateCounts {
    __block int count = [self getBugsCount];
    [_bugsBtn setButtonExtraInfo:[NSString stringWithFormat:@"%d",count]];
    
    // iOS 9+ has no hogs, so we have no count
    if(true || NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_9_0) {
        count = [self getHogsCount];
        [_hogsBtn setButtonExtraInfo:[NSString stringWithFormat:@"%d",count]];
    } else {
        [_hogsBtn setButtonExtraInfo:NSLocalizedString(@"ViewText", nil)];
    }
    
    #ifdef USE_INTERNALS
    count = 0;
    [[CaratProcessCache instance] getActionList:^(NSArray *result) {
        if(result != nil) count = [result count];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_actionsBtn setButtonExtraInfo:[NSString stringWithFormat:@"%d",count]];
        });
    }];
    return;
    #endif
    
    count = [self getActivityCount];
    [_actionsBtn setButtonExtraInfo:[NSString stringWithFormat:@"%d",count]];
}

-(void) shouldUpdateView:(NSNotification*)notification{
    DLog(@"%s Refreshing dashboard..", __PRETTY_FUNCTION__);
    if([self isViewLoaded]) {
        if (![self isFresh]
            && [[CoreDataManager instance] getReportUpdateStatus] == nil
            && [[CommunicationManager instance] isInternetReachable]) {
                [[CoreDataManager instance] updateLocalReportsFromServer];
        }
        [[CoreDataManager instance] checkConnectivityAndSendStoredDataToServer];
        [self updateView];
    }
}

-(void)sampleCountUpdated:(NSNotification*)notification{
    // Last Updated
    NSTimeInterval howLong = [[NSDate date] timeIntervalSinceDate:[[CoreDataManager instance] getLastReportUpdateTimestamp]];
    self.updateLabel.text = [Utilities formatNSTimeIntervalAsUpdatedNSString:howLong];
    [self.updateLabel setNeedsDisplay];
}

//override to get handle progress bard
- (void) updateNetworkStatus:(NSNotification *) notice
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *dict = [notice userInfo];
    BOOL isInternetActive = [dict[kIsInternetActive] boolValue];
    
    if (isInternetActive || [[CommunicationManager instance] isInternetReachable]) {
        DLog(@"Checking if update needed with new reachability status...");
        if (![self isFresh] && // need to update
            [[CoreDataManager instance] getReportUpdateStatus] == nil) // not already updating
        {
            DLog(@"Update possible; initiating.");
            [[CoreDataManager instance] updateLocalReportsFromServer];
            [self setProgressUpdateViewHeight:40.0f];
            
        }
    }
}

- (void) setProgressUpdateViewHeight:(CGFloat) height
{
    if(isUpdateProgressVisible && height == 0){
        isUpdateProgressVisible = false;
    }
    else if(!isUpdateProgressVisible && height > 0){
        isUpdateProgressVisible = true;
    }
    else {
        return;
    }
    if(height == 0){
        [self.progressUpdateView.label setHidden:YES];
        [self.progressUpdateView.actIndicator stopAnimating];
        [self.progressUpdateView.actIndicator setHidden:YES];
    }
    else{
        [self.progressUpdateView.label setHidden:NO];
        [self.progressUpdateView.actIndicator startAnimating];
        [self.progressUpdateView.actIndicator setHidden:NO];
    }
    [self.progressUpdateView setConstraintConstant:height forAttribute:NSLayoutAttributeHeight];
    [self.progressUpdateView.label setNeedsDisplay];
    [self.progressUpdateView.actIndicator setNeedsDisplay];
    [self.progressUpdateView setNeedsDisplay];
}


#pragma mark - -HUD methods
- (void)loadDataWithHUD:(id)obj
{
    @synchronized([CoreDataManager instance]) {
    //DLog(@"[CoreDataManager instance] getReportUpdateStatus] = %@", [[CoreDataManager instance] getReportUpdateStatus]);
        if([[CoreDataManager instance] getReportUpdateStatus] == nil){
            [self sampleCountUpdated:nil];
            [self setProgressUpdateViewHeight:0.0f];
        }
        else{
            //self.updateLabel.text = [[CoreDataManager instance] getReportUpdateStatus];
            //[self.updateLabel setNeedsDisplay];
            [self setProgressUpdateViewHeight:40.0f];
            self.progressUpdateView.label.text = [[CoreDataManager instance] getReportUpdateStatus];
        }
    }
}

#pragma mark - MBProgressHUDDelegate method
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [self sampleCountUpdated:nil];
}

#pragma mark - Controller specific helpfull UI mehtods
-(void)setTextLabel:(UILabel*) label text:(NSString *)text top:(CGFloat)top
{
     CGFloat fontSize = 20.0f;
     UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    
    label.frame = [self getTextFrame:text font:font top:top];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.numberOfLines = 0;
    label.font = font;
    label.text = text;
  }

-(CGRect)getTextFrame:(NSString *)text font:(UIFont *) font top:(CGFloat)top
{
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(UI_SCREEN_W, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    CGRect textRect = CGRectMake((UI_SCREEN_W / 2.0) - textSize.size.width/2.0, top, textSize.size.width, textSize.size.height);
    return textRect;
}

- (NSString *) getJScoreString
{
    NSNumber *jScore = [NSNumber numberWithInt:(int)(MIN( MAX([[CoreDataManager instance] getJScore], -1.0), 1.0)*100)];
    return [NSString stringWithFormat:NSLocalizedString(@"JScoreShareMessage", nil), [jScore stringValue]];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)showShareBar:(id)sender {
    [_shareBar setHidden:NO];
    [_shareBtn setHidden:YES];
}

- (IBAction)closeShareBar:(id)sender {
    [_shareBar setHidden:YES];
    [_shareBtn setHidden:NO];
}

- (int)getBugsCount
{
    int count = 0;
    HogBugReport *rep = [[CoreDataManager instance] getBugs:NO withoutHidden:YES];
    if (rep != nil && [rep hbListIsSet]) {
        count = (int)[[rep hbList] count];
    }
    return count;
}

- (int)getHogsCount
{
    int count = 0;
    HogBugReport *rep = [[CoreDataManager instance] getHogs:NO withoutHidden:YES];
    if (rep != nil && [rep hbListIsSet]) {
        count = (int)[[rep hbList] count];
    }
    return count;
}

- (int)getActivityCount
{
    NSMutableArray *myList = [[CoreDataManager instance] getHogsActionList:YES withoutHidden:YES actText:NSLocalizedString(@"ActionKill", nil) actType:ActionTypeKillApp];
    
    DLog(@"Loading Hogs");
    // get Bugs, add to array
    NSMutableArray *bugsActionList = [[CoreDataManager instance] getBugsActionList:YES withoutHidden:YES actText:NSLocalizedString(@"ActionRestart", nil) actType:ActionTypeRestartApp];
    [myList addObjectsFromArray:bugsActionList];
    DLog(@"Loading Bugs");
    
    // get OS
    ActionObject *tmpAction = [[CoreDataManager instance] createActionObjectFromDetailScreenReport:NSLocalizedString(@"ActionUpgradeOS", nil) actType:ActionTypeUpgradeOS];
    if(tmpAction != nil){
        [myList addObject:tmpAction];
        [tmpAction release];
    }
    DLog(@"Loading OS");
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
    return (int)myList.count;
}
#pragma mark - Navigation methods
- (IBAction)showScoreInfo:(id)sender {
    [self showInfoView:@"JScore" message:@"JScoreDesc"];
    [Flurry logEvent:NSLocalizedString(@"selectedJScoreInfo", nil)];
}

- (IBAction)showMyDevice:(id)sender {
    MyScoreViewController *controler = [[MyScoreViewController alloc]initWithNibName:@"MyScoreViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
    [Flurry logEvent:NSLocalizedString(@"selectedMyDeviceView", nil)];
}

- (IBAction)showBugs:(id)sender {
    NSLog(@"bugsTapped");
    BugsViewController *controler = [[BugsViewController alloc]initWithNibName:@"BugsViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
    [Flurry logEvent:NSLocalizedString(@"selectedBugsView", nil)];
}

- (IBAction)showHogs:(id)sender {
    
    // Check if we are running on iOS 9.0+, if so, show statistics instead
    if(true || floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_9_0){
        HogsViewController *controller = [[HogsViewController alloc] initWithNibName:@"HogsViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
        [Flurry logEvent:NSLocalizedString(@"selectedHogsView", nil)];
    } else {
        HogStatisticsViewController *controller = [[HogStatisticsViewController alloc] initWithNibName:@"HogStatisticsViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
        [Flurry logEvent:NSLocalizedString(@"selectedHogStatisticsView", nil)];
    }
}

- (IBAction)showStatistics:(id)sender {
    StatisticsViewController *controler = [[StatisticsViewController alloc]initWithNibName:@"StatisticsViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
    [Flurry logEvent:NSLocalizedString(@"selectedStatisticsView", nil)];
}
- (IBAction)showActions:(id)sender {
    ActionsViewController *controler = [[ActionsViewController alloc]initWithNibName:@"ActionsViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
    [Flurry logEvent:NSLocalizedString(@"selectedActionsView", nil)];
}

#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary *)results {
    NSLog(@"FB Share: =%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB Error: =%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB Cancel: =%@\n",[sharer debugDescription]);
}

- (IBAction)showFacebook:(id)sender {
    int roundedJscore =(int)(MIN( MAX([[CoreDataManager instance] getJScore], -1.0), 1.0)*100);
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"http://carat.cs.helsinki.fi"];
    content.contentTitle = [[@"My J-Score is "
                            stringByAppendingString:[@(roundedJscore) stringValue]]
                            stringByAppendingString:@". Find out yours and improve your battery life!"];
    content.imageURL = [NSURL URLWithString:@"http://carat.cs.helsinki.fi/img/icon144.png"];
    content.contentDescription = @"Carat is a free app that tells you what is using up your battery, whether that's normal, and what you can do about it.";
    [FBSDKShareDialog showFromViewController:self
                                withContent:content
                                delegate:self];
    [Flurry logEvent:NSLocalizedString(@"selectedShareFacebook", nil)];
}

- (IBAction)showTwitter:(id)sender {
    int roundedJscore =(int)(MIN( MAX([[CoreDataManager instance] getJScore], -1.0), 1.0)*100);
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    [composer setText:[[@"My J-Score is "
                        stringByAppendingString:[@(roundedJscore) stringValue]]
                        stringByAppendingString:@". Find out yours and improve your battery life! http://is.gd/caratweb"]];
    UIImage *test = [UIImage imageNamed:@"Icon144.png"];
    NSLog(@"TEST IS =%@", test);
    [composer setImage:[UIImage imageNamed:@"Icon144.png"]];
    
    // Called from a UIViewController
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Twitter Share: CANCELLED");
        }
        else {
            NSLog(@"Twitter Share: COMPLETED");
        }
    }];
    [Flurry logEvent:NSLocalizedString(@"selectedShareTwitter", nil)];
}


- (IBAction)showEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:NSLocalizedString(@"EmailMessageTittle", nil)];
        
        NSMutableString *messageBody = [[NSMutableString alloc]init];
        [messageBody appendString:[self getJScoreString]];
        [messageBody appendString:@"\n\n"];
        [messageBody appendString:[NSString stringWithFormat:NSLocalizedString(@"CaratEmailSalesPitch", nil), NSLocalizedString(@"Carat", nil)]];
        [mail setMessageBody:messageBody isHTML:NO];
        
        //[self.navigationController pushViewController:mail animated:YES];
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
    [Flurry logEvent:NSLocalizedString(@"selectedShareEmail", nil)];
}

- (void)dealloc {
    [_scoreView release];
    [_updateLabel release];
    [_batteryLastLabel release];
    [_bugsBtn release];
    [_hogsBtn release];
    [_statisticsBtn release];
    [_actionsBtn release];
    [_shareBtn release];
    [_shareBar release];
    [_shareBar release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_progressUpdateView release];
    [_settingsBtn release];
    [super dealloc];
}
@end
