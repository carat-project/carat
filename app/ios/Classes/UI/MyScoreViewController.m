//
//  MyScoreViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "MyScoreViewController.h"
#import "InfoViewController.h"

#import "Utilities.h"
#import "Flurry.h"
#import "CoreDataManager.h"
#import "CommunicationManager.h"
#import "UIDeviceHardware.h"
#import "Globals.h"
#import "UIImageDoNotCache.h"
#import "CaratConstants.h"
#import "DeviceInformation.h"

@interface MyScoreViewController ()

@end

@implementation MyScoreViewController
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
    _navbarTitle.title = [NSLocalizedString(@"MyDevice", nil) uppercaseString];
    isUpdateProgressVisible = false;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [super viewWillAppear:animated];
    // This should happen automatically
    // [self updateView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sampleCountUpdated:) name:kSamplesSentCountUpdateNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[CoreDataManager instance] getReportUpdateStatus] == nil) {
        // For this screen, let's put sending samples/registrations here so that we don't conflict
        // with the report syncing (need to limit memory/CPU/thread usage so that we don't get killed).
        [[CoreDataManager instance] checkConnectivityAndSendStoredDataToServer];
        [self setProgressUpdateViewHeight:40.0f];
    }
    else{
        [self setProgressUpdateViewHeight:0.0f];
    }
    
    [self loadDataWithHUD:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSamplesSentCountUpdateNotification object:nil];
}

- (void)updateView
{
    // J-Score
    int vScore = (MIN( MAX([[CoreDataManager instance] getJScore], -1.0), 1.0)*100);
    // Expected Battery Life
    NSTimeInterval eb; // expected life in seconds
    double jev = [[[CoreDataManager instance] getJScoreInfo:YES] expectedValue];
    if (jev > 0) eb = MIN(MAX_LIFE,100/jev);
    else eb = MAX_LIFE;
    NSString *vBatteryLife = [[Utilities doubleAsTimeNSString:eb] stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // UUID
    NSString *vUUID = [[Globals instance] getUUID];
    //Device Info
    UIDeviceHardware *h =[[UIDeviceHardware alloc] init];
    NSString* vPlatform = [h platformString];
    NSString* vOSVersion = [UIDevice currentDevice].systemVersion;
    //Memory Info
    float memUsed = 0;
    float memActive = 0;
    NSDictionary *memoryInfo = [Utilities getMemoryInfo];
    if (memoryInfo) {
        memUsed = [memoryInfo[kMemoryUsed] floatValue]*100;
        memActive = [memoryInfo[kMemoryActive] floatValue]*100;
    }
    // Cpu Usage
    float cpuUsage = [DeviceInformation getCpuUsage]*100;
    
    [self.jScore setScore:vScore];
    self.caratIDValue.text = vUUID;
    self.batteryLifeTimeValue.text = vBatteryLife;
    self.osVersionValue.text = vOSVersion;
    self.deviceModelValue.text = vPlatform;
    self.memoryUsedBar.largerMeasureValue = memUsed;
    self.memoryActiveBar.largerMeasureValue = memActive;
    self.cpuUsageBar.largerMeasureValue = cpuUsage;
    DLog(@"memUsed: %f, memActive: %f", memUsed, memActive);
    // Last Updated
    [self sampleCountUpdated:nil];
    
    // Change since last week
    //    [[self sinceLastWeekString] makeObjectsPerformSelector:@selector(setText:) withObject:[[[[CoreDataManager instance] getChangeSinceLastWeek] objectAtIndex:0] stringByAppendingString:[@" (" stringByAppendingString:[[[[CoreDataManager instance] getChangeSinceLastWeek] objectAtIndex:1] stringByAppendingString:@"%)"]]]];
    //OS
    double vOS = MIN(MAX([[[CoreDataManager instance] getOSInfo:YES] score],0.0),1.0);
    //MODEL
    double vModel = [[[CoreDataManager instance] getModelInfo:YES] score];
    //APPS
    double vApps = [[[CoreDataManager instance] getSimilarAppsInfo:YES] score];
    DLog(@"uuid: %s, jscore: %d, os: %f, model: %f, apps: %f", [vUUID UTF8String], vScore, vOS, vModel, vApps);
    [self.view setNeedsDisplay];
}

-(void)sampleCountUpdated:(NSNotification*)notification{
    // Last Updated
    //[self.progressBar stopAnimating];
    NSTimeInterval howLong = [[NSDate date] timeIntervalSinceDate:[[CoreDataManager instance] getLastReportUpdateTimestamp]];
    self.lastUpdatedLabel.text = [Utilities formatNSTimeIntervalAsUpdatedNSString:howLong];
    [self.lastUpdatedLabel setNeedsDisplay];
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

#pragma mark - -HUD methods
- (void)loadDataWithHUD:(id)obj
{
    @synchronized([CoreDataManager instance]) {
        if([[CoreDataManager instance] getReportUpdateStatus] == nil){
            [self sampleCountUpdated:nil];
            [self setProgressUpdateViewHeight:0.0f];
        }
        else{
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

- (NSString *)getSameOSDetail:(id)sender
{
    DetailScreenReport *dsr = [[CoreDataManager instance] getOSInfo:YES];
    if (dsr == nil || ![dsr expectedValueIsSet] || [dsr expectedValue] <= 0 || ![dsr errorIsSet] || [dsr error] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nothing to Report!"
                                                        message:@"Please check back later; we should have results for your device soon."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        double expectedValueWithout = [[[CoreDataManager instance] getOSInfo:NO] expectedValue];
        
        NSInteger benefit = (int) (100/expectedValueWithout - 100/[dsr expectedValue]);
        NSInteger benefit_max = (int) (100/(expectedValueWithout-[dsr errorWithout]) - 100/([dsr expectedValue]+[dsr error]));
        NSInteger error = (int) (benefit_max-benefit);
        
        NSString *errorTxt = [NSString stringWithFormat:@"%@ ± %@", [Utilities doubleAsTimeNSString:benefit], [Utilities doubleAsTimeNSString:error]];
        NSString *samplesWithoutTxt = [[NSNumber numberWithDouble:[dsr samplesWithout]] stringValue];
        NSString *samplesTxt = [[NSNumber numberWithDouble:[dsr samples]] stringValue];
        
        NSMutableString *returnString = [[NSMutableString alloc]init];
        [returnString appendString:NSLocalizedString(@"Same Operating System", nil)];
        [returnString appendString:@"\n\n"];
        [returnString appendString:errorTxt];
        [returnString appendString:@"\nSamples:"];
        [returnString appendString:samplesTxt];
        [returnString appendString:@"\nSamplesWithout"];
        [returnString appendString:samplesWithoutTxt];
        return returnString;
        
    }
    return @"";
}

#pragma mark - Navigation methods
- (IBAction)showJScoreExplanation:(id)sender {
    NSLog(@"showInfoView");
    [self showInfoView:@"JScore" message:@"JScoreDesc"];
    [Flurry logEvent:NSLocalizedString(@"selectedJScoreInfo", nil)];
}

- (IBAction)showProcessList:(id)sender {
    ProcessViewController *controler = [[ProcessViewController alloc]initWithNibName:@"ProcessViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
    [Flurry logEvent:NSLocalizedString(@"selectedProcessList", nil)]; //
}

- (IBAction)showMemUsedInfo:(id)sender {
    NSLog(@"showInfoView");
    [self showInfoView:@"MemoryUsed" message:@"MemoryDesc"];
    [Flurry logEvent:NSLocalizedString(@"selectedMemoryInfo", nil)];
}

- (IBAction)showMemActiveInfo:(id)sender {
    NSLog(@"showInfoView");
    [self showInfoView:@"MemoryActive" message:@"MemoryDesc"];
    [Flurry logEvent:NSLocalizedString(@"selectedMemoryInfo", nil)];
}

- (IBAction)showCPUUsageInfo:(id)sender {
    NSLog(@"showInfoView");
    [self showInfoView:@"CPUUsage" message:@"CpuUsageDesc"];
    [Flurry logEvent:NSLocalizedString(@"selectedProcessList", nil)];
}

- (void)dealloc {
    [_jScore release];
    [_caratIDValue release];
    [_osVersionValue release];
    [_deviceModelValue release];
    [_batteryLifeTimeValue release];
    [_memoryUsedBar release];
    [_memoryActiveBar release];
    [_cpuUsageBar release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_lastUpdatedLabel release];
    [_progressUpdateView release];
    [_navbarTitle release];
    [super dealloc];
}
@end
