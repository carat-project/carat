//
//  TutorialViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 04/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialPageContent.h"
#import "TutorialPageIndicatorView.h"
#import "WebInfoViewController.h"
#import "UIButton+BackgroundColor.h"


NSArray *pageDataContent;

@interface TutorialViewController : UIViewController{
    NSArray *consentWebView;
    id callbackDelegate;
    SEL callbackSelector;
}

@property (nonatomic, retain) id callbackDelegate;
@property (nonatomic) int pageCount;
@property (nonatomic) int pagePos;
@property (nonatomic, retain) NSArray *pageDataContent;
@property (retain, nonatomic) IBOutlet UIImageView *ImageView;
@property (retain, nonatomic) IBOutlet TutorialPageIndicatorView *pageIndicatorView;
@property (retain, nonatomic) IBOutlet UIButton *acceptButton;
@property (retain, nonatomic) IBOutlet UILabel *tutorialPageTitle;
@property (retain, nonatomic) IBOutlet UILabel *tutorialPageDescription;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil callbackTo:(id)delegate withSelector:(SEL)selector;

- (IBAction)acceptPressed;
- (IBAction)rightSwipe;
- (IBAction)leftSwipe;
- (IBAction)acceptInfoPressed;
@end
