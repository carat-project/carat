//
//  MoreViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 12/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "MoreViewController.h"
#import "Preprocessor.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _navigationBar.title = [NSLocalizedString(@"Settings", nil) uppercaseString];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _versionLabel.text = [NSString stringWithFormat:@"%@ v%@", NSLocalizedString(@"AboutTittle", nil), version];
    BOOL selected = [[Globals instance] getBoolForKey:kUseWifiOnly];
    [_wifiSwitch setOn:selected];
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
    BOOL useWifiOnly = switchControl.on;
    [[Globals instance] saveBool:useWifiOnly forKey:kUseWifiOnly];
    NSLog( @"The wifi-only switch is %@", switchControl.on ? @"ON" : @"OFF" );

}

- (IBAction)hideAppsClicked:(id)sender {
    NSLog(@"hideAppsClicked");
    HideAppsViewController *controller = [[HideAppsViewController alloc]initWithNibName:@"HideAppsViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)feedBackClicked:(id)sender {
    UIActionSheet *choiceDialog = [[UIActionSheet alloc] initWithTitle:@"Give feedback" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                   @"Rate us in App Store",
                                   @"Problem with app, please specify",
                                   @"No J-Score after 7 days of use",
                                   @"Other, please specify", nil];
    choiceDialog.tag = 1;
    [choiceDialog showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)dialog clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(dialog.tag == 1){
        if(buttonIndex == [dialog cancelButtonIndex]){
            return;
        } else if(buttonIndex == 0){
            [self openStorePage];
        } else {
            [self sendFeedback:[dialog buttonTitleAtIndex:buttonIndex] index:buttonIndex];
        }
    }
}

-(void)openStorePage {
    NSString *storeUrl = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%d"
                          "&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8", APP_STORE_ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:storeUrl]];
}

- (void) sendFeedback:(NSString *)feedback index:(NSInteger)index{
    // Device info
    UIDevice *h =[[[UIDevice alloc] init] autorelease];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *versionShort = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    /* create mail subject */
    NSString *subject = [NSString stringWithFormat:@"[Carat][iOS] Feedback from %@ (%@), v%@", [h modelName], [UIDevice currentDevice].systemVersion, versionShort];
    
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
    
    NSString *pleaseSpecify = @"";
    if(index == 1 || index == 3){
        pleaseSpecify = @"\n\nPlease enter your feedback here";
    }
    NSString *messageBody = [NSString stringWithFormat:
                             @"Carat %@\n Carat ID: %s\n Feedback: %@\n JScore: %@\n OS Version: %@\n Device Model: %@\n Memory Used: %@\n Memory Active: %@%@", version, [[[Globals instance] getUUID] UTF8String], feedback, JscoreStr, [UIDevice currentDevice].systemVersion,[h modelName], memoryUsed, memoryActive, pleaseSpecify];
    
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
    TutorialViewController *controller = [[TutorialViewController alloc]initWithNibName:@"TutorialViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)aboutClicked:(id)sender {
    AboutViewController *controller = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
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
    [_navigationBar release];
    [_wifiSwitch release];
    [super dealloc];
}
@end
