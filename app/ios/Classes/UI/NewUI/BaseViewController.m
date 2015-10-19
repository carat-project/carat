//
//  BaseViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 29/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BaseViewController.h"
#import "DashboardViewController.h"
#import "InfoViewController.h"

@implementation BaseViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    NSString *title = [_navigationItem title];
    NSLog(@"title: %@", title);
    NSString *locallizedTitle = [NSLocalizedString(title, nil) uppercaseString];
    NSLog(@"locallizedTitle: %@", locallizedTitle);
    [_navigationItem setTitle:locallizedTitle];
     */

    
    //[self setFontFamily:@"SanFransisco" forView:self.view andSubViews:YES];
}

-(void)setFontFamily:(NSString*)fontFamily forView:(UIView*)view andSubViews:(BOOL)isSubViews
{
    if ([view isKindOfClass:[UILabel class]])
    {
        UILabel *lbl = (UILabel *)view;
        [lbl setFont:[UIFont fontWithName:fontFamily size:[[lbl font] pointSize]]];
    }
    
    if (isSubViews)
    {
        for (UIView *sview in view.subviews)
        {
            [self setFontFamily:fontFamily forView:sview andSubViews:YES];
        }
    }
}

-(void)showInfoView:(NSString *)title message:(NSString *)message;
{
    NSLog(@"showInfoView");
    InfoViewController *controler = [[InfoViewController alloc]initWithNibName:@"InfoViewController" bundle:nil];
    controler.titleForView = title;
    controler.messageForView = message;
    [self.navigationController pushViewController:controler animated:YES];
    /*
    InfoViewController *controler = [[InfoViewController alloc]initWithNibName:@"TutorialViewController" bundle:nil];
    //controler.messageForView = title;
    //controler.titleForView =message;
    [self.navigationController pushViewController:controler animated:YES];
     */
}

- (IBAction)barItemBackPressed{
    NSLog(@"****** barItemBackPressed *******");
    [self.navigationController popViewControllerAnimated:YES];
    //DashBoardViewController *controler = [[DashBoardViewController alloc]initWithNibName:@"DashBoardViewController" bundle:nil];
    //[self presentViewController:controler animated: YES completion:nil];
    //[controler release];
}

-(IBAction)barItemMorePressed{
    NSLog(@"barItemMorePressed");
    MoreViewController *controler = [[MoreViewController alloc]initWithNibName:@"MoreViewController" bundle:nil];
    [self.navigationController pushViewController:controler animated:YES];
    
}

- (void)dealloc {
    [super dealloc];
}
@end
