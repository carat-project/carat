//
//  DashBoardViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 29/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "DashBoardViewController.h"

@implementation DashBoardViewController{
}

- (void)loadView
{
    [super loadView];
    [_shareBar setHidden:YES];

    [_bugsBtn setButtonImage:[UIImage imageNamed:@"bug_icon"]];
    [_bugsBtn setButtonExtraInfo:@"7"];
    [_bugsBtn setButtonTitle:NSLocalizedString(@"Bugs", nil)];
    
    [_hogsBtn setButtonImage:[UIImage imageNamed:@"battery_icon"]];
    [_hogsBtn setButtonExtraInfo:@"4"];
    [_hogsBtn setButtonTitle:NSLocalizedString(@"Hogs", nil)];

    [_statisticsBtn setButtonImage:[UIImage imageNamed:@"globe_icon"]];
    [_statisticsBtn setButtonExtraInfo:@"VIEW"];
    [_statisticsBtn setButtonTitle:NSLocalizedString(@"Statistics", nil)];
    
    [_actionsBtn setButtonImage:[UIImage imageNamed:@"action_icon"]];
    [_actionsBtn setButtonExtraInfo:@"4"];
    [_actionsBtn setButtonTitle:NSLocalizedString(@"Actions", nil)];
    

}

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

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    [super dealloc];
}


- (IBAction)shareButtonTapped:(id)sender {
}

- (IBAction)showScoreInfo:(id)sender {
    [self showInfoView:@"JScore" message:@"JScoreDesc"];
}

- (IBAction)showMyDevice:(id)sender {
    MyScoreViewController *controler = [[MyScoreViewController alloc]initWithNibName:@"MyScoreViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}

- (IBAction)showBugs:(id)sender {
    NSLog(@"bugsTapped");
    BugsViewController *controler = [[BugsViewController alloc]initWithNibName:@"BugsViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}

- (IBAction)showHogs:(id)sender {
    HogsViewController *controler = [[HogsViewController alloc]initWithNibName:@"HogsViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}

- (IBAction)showStatistics:(id)sender {
    StatisticsViewController *controler = [[StatisticsViewController alloc]initWithNibName:@"StatisticsViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}
- (IBAction)showActions:(id)sender {
    ActionsViewController *controler = [[ActionsViewController alloc]initWithNibName:@"ActionsViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
}
- (IBAction)showFacebook:(id)sender {
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
    
    /*
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        fbSLComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbSLComposeViewController addImage:someImage];
        [fbSLComposeViewController setInitialText:@"Some Text"];
        [self presentViewController:fbSLComposeViewController animated:YES completion:nil];
        
        fbSLComposeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"facebook: CANCELLED");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"facebook: SHARED");
                    break;
            }
        };
    }
    else {
        UIAlertView *fbError = [[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"Sorry, we're unable to find a Facebook account on your device.\nPlease setup an account in your devices settings and try again." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [fbError show];
    }
    */
}

- (IBAction)showTwitter:(id)sender {
}


- (IBAction)showEmail:(id)sender {
}

- (IBAction)showShareBar:(id)sender {
    [_shareBar setHidden:NO];
    [_shareBtn setHidden:YES];
}

- (IBAction)closeShareBar:(id)sender {
    [_shareBar setHidden:YES];
    [_shareBtn setHidden:NO];
}
@end
