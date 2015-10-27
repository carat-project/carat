//
//  MoreViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 12/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _versionLabel.text = [NSString stringWithFormat:@"%@ v%@", NSLocalizedString(@"AboutTittle", nil), version];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)wifiOnlySwitcherValueChanged:(id)sender {
    UISwitch* switchControl = sender;
    BOOL useWifiOnly = switchControl.on ? YES: NO;
    [[NSUserDefaults standardUserDefaults] setBool:useWifiOnly forKey:kUseWifiOnly];
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );

}

- (IBAction)hideAppsClicked:(id)sender {
    NSLog(@"hideAppsClicked");
    HideAppsViewController *controler = [[HideAppsViewController alloc]initWithNibName:@"HideAppsViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}

- (IBAction)feedBackClicked:(id)sender {    
    NSString *subject = [NSString stringWithFormat:@"[Carat IOS] Feedback from (device) (os)"];
    
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
    
    // Device info
    UIDeviceHardware *h =[[[UIDeviceHardware alloc] init] autorelease];
    
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
    [Flurry logEvent:NSLocalizedString(@"selectedGiveFeedback", nil)];
}

- (IBAction)tutorialClicked:(id)sender {
    TutorialViewController *controler = [[TutorialViewController alloc]initWithNibName:@"TutorialViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}

- (IBAction)aboutClicked:(id)sender {
    AboutViewController *controler = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
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


- (void)dealloc {
    [_versionLabel release];
    [super dealloc];
}
@end
