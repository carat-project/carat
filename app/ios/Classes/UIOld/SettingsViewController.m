//
//  SettingsViewController.m
//  Carat
//
//  Created by Muhammad Haris on 06/02/15.
//  Authors Muhammad Haris, Eemil Lagerspetz
//  Copyright (c) 2015 University of Helsinki. All rights reserved.
//

#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "CaratConstants.h"
#import "Socialize/Socialize.h"
#import "Utilities.h"
#import "CoreDataManager.h"
#import "UIDeviceHardware.h"
#import "Flurry.h"
#import <MessageUI/MessageUI.h>

typedef NS_ENUM(NSUInteger, SettingsCellID) {
    kSettingsCellWifiSwitch,
    kSettingsCellFeeback,
    kSettingsCellShare,
    globalStats,
    kSettingsCellAbout,
    numberOfSettings
};

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Settings";
        self.tabBarItem.image = [UIImage imageNamed:@"settings"];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) canShare {
    // A system version of 7.0 or greater is required to use Socialize.
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        return YES;
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numberOfSettings;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.title;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *hView = [[[UIView alloc] initWithFrame: CGRectZero] autorelease];
    hView.backgroundColor = [UIColor clearColor];
    
    UILabel *hLabel=[[[UILabel alloc] initWithFrame: CGRectMake(10, 30, tableView.bounds.size.width, 20)] autorelease];
    
    hLabel.backgroundColor = [UIColor clearColor];
    hLabel.shadowColor = [UIColor whiteColor];
    hLabel.shadowOffset = CGSizeMake(0.5,1);
    hLabel.textColor = [UIColor blackColor];
    hLabel.font = [UIFont boldSystemFontOfSize:15];
    hLabel.text = self.title;
    
    [hView addSubview:hLabel];
    
    return hView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"SettingsItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.textColor = [tableView separatorColor];
    switch (indexPath.row) {
        case kSettingsCellWifiSwitch:
            cell.textLabel.text = @"Use Wifi Only";
            //add a switch
            UISwitch *wifiSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
            wifiSwitch.onTintColor = [tableView separatorColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryView = wifiSwitch;
            [wifiSwitch setOn:isUsingWifiOnly animated:NO];
            [wifiSwitch addTarget:self action:@selector(wifiSwitchToggled:) forControlEvents:UIControlEventValueChanged];
            
            break;
        case globalStats:
            cell.textLabel.text = @"Carat Global Statistics";
            break;
        case kSettingsCellShare:
            if ([self canShare])
                cell.textLabel.text = @"Share Carat";
            else{
                cell.textLabel.text = @"iOS 7.0 Required for Sharing";
            }
            break;
        case kSettingsCellFeeback:
            cell.textLabel.text = @"Feedback";
            break;
        case kSettingsCellAbout:
            cell.textLabel.text = @"About";
            break;
        default:
            break;
    }
    
    return cell;
}

// loads the selected detail view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case kSettingsCellShare:
            if ([self canShare])
                [self shareHandler];
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iOS 7.0 required"
                                                                message:@"iOS 7.0 or greater is required for sharing."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                NSLog(@"Trying to share with ioS < 7.0.");
                
                }
            
            break;
        case globalStats:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://carat.cs.helsinki.fi/statistics"]];
            break;
        case kSettingsCellFeeback:
            [self _reportFeedback];
            break;
        case kSettingsCellAbout:
            [self _presentAboutViewController];
            break;
        default:
            break;
    }
    
}

- (void) wifiSwitchToggled:(id)sender {
    UISwitch* switchControl = sender;
    BOOL useWifiOnly = switchControl.on ? YES: NO;
    [[NSUserDefaults standardUserDefaults] setBool:useWifiOnly forKey:kUseWifiOnly];
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
}

-(void) _presentAboutViewController{
    AboutViewController *aboutView = [[[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil] autorelease];
    [self.navigationController pushViewController:aboutView animated:YES];
}

-(void) _reportFeedback{
    
    
    // Device info
    UIDeviceHardware *h =[[[UIDeviceHardware alloc] init] autorelease];
    
    /* create mail subject */
    NSString *subject = [NSString stringWithFormat:@"[Carat IOS] Feedback from (%@) (%@)", [UIDevice currentDevice].systemVersion,[h platformString]];
    
    /* define email address */
    NSString *mail = [NSString stringWithFormat:@"Carat Team <carat@cs.helsinki.fi>"];
    
    NSDictionary *memoryInfo = [Utilities getMemoryInfo];
    
    NSString* memoryUsed = @"Not available";
    NSString* memoryActive = @"Not available";
    
    if (memoryInfo) {
        float frac_used = [memoryInfo[kMemoryUsed] floatValue];
        float frac_active = [memoryInfo[kMemoryActive] floatValue];
        memoryUsed = [NSString stringWithFormat:@"%.02f%%",frac_used*100];
        memoryActive = [NSString stringWithFormat:@"%.02f%%",frac_active*100];
    }
    
    float Jscore = (MIN( MAX([[CoreDataManager instance] getJScore], -1.0), 1.0)*100);
    NSString *JscoreStr = @"N/A";
    if(Jscore > 0)
        JscoreStr = [NSString stringWithFormat:@"%.0f", Jscore];
    
    
    NSString *messageBody = [NSString stringWithFormat:
                             @"Carat ID: %s\n JScore: %@\n OS Version: %@\n Device Model: %@\n Memory Used: %@\n Memory Active: %@", [[[Globals instance] getUUID] UTF8String], JscoreStr, [UIDevice currentDevice].systemVersion,[h platformString], memoryUsed, memoryActive];
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *kmail = [[MFMailComposeViewController alloc] init];
        kmail.mailComposeDelegate = self;
        [kmail setSubject:subject];
        [kmail setMessageBody:messageBody isHTML:NO];
        [kmail setToRecipients:@[mail]];
        
        [self presentViewController:kmail animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This device cannot send email"
                                                        message:@"Please set up email on your phone to send feedback."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        NSLog(@"This device cannot send email");
    }
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

#pragma mark - sharing

- (void)shareHandler {
    [self showShareDialog];
    
    [Flurry logEvent:@"selectedSpreadTheWord"];
}

- (void)showShareDialog {
    id<SZEntity> entity = [SZEntity entityWithKey:@"http://carat.cs.helsinki.fi" name:@"Carat"];
    
    SZShareOptions *options = [SZShareUtils userShareOptions];
    
    // http://developers.facebook.com/docs/reference/api/link/
    
    options.willAttemptPostingToSocialNetworkBlock = ^(SZSocialNetwork network, SZSocialNetworkPostData *postData) {
        
        if (network == SZSocialNetworkFacebook) {
            [postData.params setObject:[[@"My J-Score is " stringByAppendingString:[[NSNumber numberWithInt:(int)(MIN( MAX([[CoreDataManager instance] getJScore], -1.0), 1.0)*100)] stringValue]] stringByAppendingString:@". Find out yours and improve your battery life!"] forKey:@"message"];
            [postData.params setObject:@"http://carat.cs.helsinki.fi" forKey:@"link"];
            [postData.params setObject:@"Carat: Collaborative Energy Diagnosis" forKey:@"caption"];
            [postData.params setObject:@"Carat" forKey:@"name"];
            [postData.params setObject:@"Carat is a free app that tells you what is using up your battery, whether that's normal, and what you can do about it." forKey:@"description"];
            [postData.params setObject:@"http://carat.cs.helsinki.fi/img/icon144.png" forKey:@"picture"];
        } else if (network == SZSocialNetworkTwitter) {
            [postData.params setObject:[[@"My J-Score is " stringByAppendingString:[[NSNumber numberWithInt:(int)(MIN( MAX([[CoreDataManager instance] getJScore], -1.0), 1.0)*100)] stringValue]] stringByAppendingString:@". Find out yours and improve your battery life! http://is.gd/caratweb"] forKey:@"status"];
        }
        
    };
    
    options.willShowEmailComposerBlock = ^(SZEmailShareData *emailData) {
        emailData.subject = @"Battery Diagnosis with Carat";
        
        //        NSString *appURL = [emailData.propagationInfo objectForKey:@"http://bit.ly/xurpWS"];
        //        NSString *entityURL = [emailData.propagationInfo objectForKey:@"entity_url"];
        //        id<SZEntity> entity = emailData.share.entity;
        NSString *appName = emailData.share.application.name;
        
        emailData.messageBody = [NSString stringWithFormat:@"Check out this free app called %@ that tells you what is using up your mobile device's battery, whether that's normal, and what you can do about it: http://is.gd/caratweb\n\n\n", appName];
    };
    
    options.willShowSMSComposerBlock = ^(SZSMSShareData *smsData) {
        //        NSString *appURL = [smsData.propagationInfo objectForKey:@"application_url"];
        //        NSString *entityURL = [smsData.propagationInfo objectForKey:@"entity_url"];
        //        id<SZEntity> entity = smsData.share.entity;
        NSString *appName = smsData.share.application.name;
        
        smsData.body = [NSString stringWithFormat:@"Check out this free app called %@ that helps improve your mobile device's battery life: http://is.gd/caratweb", appName];
    };
    
    [SZShareUtils showShareDialogWithViewController:self options:options entity:entity completion:^(NSArray *shares) {
        DLog(@"Created %d shares: %@", [shares count], shares);
    } cancellation:^{
        DLog(@"Share creation cancelled");
    }];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
