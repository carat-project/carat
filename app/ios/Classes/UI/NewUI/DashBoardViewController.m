//
//  DashBoardViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 29/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "DashBoardViewController.h"

@implementation DashBoardViewController{
    
    UILabel *_batteryLife;
    UILabel *_batteryLifeTime;
    UIButton *_myDeviceBtn;
}

- (void)loadView
{
    [super loadView];
    _batteryLife = [UILabel new];
    _batteryLifeTime = [UILabel new];
    
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, UI_SCREEN_W, UI_TOP_NAVIGATION_BAR_HEIGHT)];
    //do something like background color, title, etc you self
    UINavigationItem *navItem = [UINavigationItem alloc];
    navItem.title = @"Dashboard";
    
    UIImage *moreImage = [UIImage imageNamed:@"more_icon"];
    UIButton *more = [UIButton buttonWithType:UIButtonTypeCustom];
    more.bounds = CGRectMake( 0, 0, 17, 17);
    [more setImage:moreImage forState:UIControlStateNormal];
    [more addTarget:self action:@selector(moreIconPressed)forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithCustomView:more];

    /*
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(moreIconPressed)];
     */
    navItem.rightBarButtonItem = moreButton;
    navItem.rightBarButtonItem.customView.frame = CGRectMake(UI_SCREEN_W-50, 15, 20,20);
    
    navbar.tintColor = C_WHITE;
    [navbar pushNavigationItem:navItem animated:false];

    [self.view addSubview:navbar];
    
    UIImage *img = [UIImage imageNamed:@"chart_image"];
    CGFloat oneThirdHeight = ((UI_WINDOW_HEIGHT- UI_TOP_NAVIGATION_BAR_HEIGHT - 20)*0.33f);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.frame = CGRectMake(0,  UI_TOP_NAVIGATION_BAR_HEIGHT+20, UI_SCREEN_W, oneThirdHeight);
    NSLog(@"topImgHeight: %f CGRectGetMaxY(imageView.frame): %f", oneThirdHeight, CGRectGetMaxY(imageView.frame));
    [self.view addSubview:imageView];

    CGFloat scoreTop = UI_TOP_NAVIGATION_BAR_HEIGHT + 20 + oneThirdHeight * 0.1f;
    CGFloat scoreEdge = oneThirdHeight * 0.7f;
    CGFloat scoreLeft = (UI_SCREEN_W - scoreEdge)/2.0f;
   
    
    ScoreView *scoreView = [[ScoreView alloc] initWithFrame:CGRectMake(scoreLeft, scoreTop, scoreEdge, scoreEdge)];
    [scoreView setScore: 60];
    [scoreView setTitle: @"J-score"];
    [self.view addSubview:scoreView];
    
    CGFloat shareEdge = 60.0f;
    CGFloat shareTop = CGRectGetMaxY(imageView.frame)-shareEdge/2.0f;
    CGFloat shareLeft = UI_SCREEN_W - shareEdge - 20.0f; //20 is margin from right screen edge
    NSLog(@"shareTop: %f shareLeft: %f", shareTop, shareLeft);
    
    ShareView *shareView =[[ShareView alloc] initWithFrame:CGRectMake(shareLeft, shareTop, shareEdge, shareEdge)];
    [self.view addSubview:shareView];
    
    CGFloat centerTopBottomPad = oneThirdHeight*0.25f;
    CGFloat batterylifeLabelTop = CGRectGetMaxY(imageView.frame) + centerTopBottomPad;
    NSString *activeBatteryLifeLabelString = NSLocalizedString(@"BatteryLifeLabel", nil);
    NSLog(@"activeBatteryLifeLabelString: %@", activeBatteryLifeLabelString);
    
    [self setTextLabel:_batteryLife text:NSLocalizedString(@"BatteryLifeLabel", nil) top:batterylifeLabelTop];
    _batteryLife.textColor = C_LIGHT_GRAY;
    [self.view addSubview:_batteryLife];
    
    [self setTextLabel:_batteryLifeTime text:@"10h 23m" top:(CGRectGetMaxY(_batteryLife.frame)+5)];
    
    [self.view addSubview:_batteryLifeTime];
    
    NSString *buttonText = NSLocalizedString(@"MyDevice", nil);
    CGFloat fontSize = 20.0f;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    
    CGRect buttonFrame = [self getTextFrame:buttonText font:font top:(CGRectGetMaxY(_batteryLifeTime.frame)+10)];
    buttonFrame.size.height += 10.0f;
    buttonFrame.size.width += 30.0f;
    buttonFrame.origin.x -= 15.0f;
    _myDeviceBtn = [[UIButton alloc] initWithFrame:buttonFrame];
    
    _myDeviceBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _myDeviceBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _myDeviceBtn.backgroundColor = C_ORANGE_LIGHT;
    [_myDeviceBtn setTitle:buttonText forState:UIControlStateNormal];
    [_myDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_myDeviceBtn addTarget:self action:@selector(showMyScoreController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_myDeviceBtn];
    
    CGFloat buttonWidth = UI_SCREEN_W/4.0f;
    CGFloat buttonTop = CGRectGetMaxY(_myDeviceBtn.frame)+centerTopBottomPad;
    CGFloat buttonHeight = UI_SCREEN_H - buttonTop;
    DashboardNavigationButton* bugsButton = [[DashboardNavigationButton alloc] initWithFrame:CGRectMake(0, buttonTop, buttonWidth, buttonHeight)];
    [bugsButton setButtonImage:[UIImage imageNamed:@"bug_icon"]];
    [bugsButton setButtonExtraInfo:@"7"];
    [bugsButton setButtonTitle:NSLocalizedString(@"Bugs", nil)];

    DashboardNavigationButton* hogsButton = [[DashboardNavigationButton alloc] initWithFrame:CGRectMake(buttonWidth, buttonTop, buttonWidth, buttonHeight)];
    [hogsButton setButtonImage:[UIImage imageNamed:@"battery_icon"]];
    [hogsButton setButtonExtraInfo:@"4"];
    [hogsButton setButtonTitle:NSLocalizedString(@"Hogs", nil)];
    
    DashboardNavigationButton* statisticsButton = [[DashboardNavigationButton alloc] initWithFrame:CGRectMake(buttonWidth*2.0f, buttonTop, buttonWidth, buttonHeight)];
    [statisticsButton setButtonImage:[UIImage imageNamed:@"globe_icon"]];
    [statisticsButton setButtonExtraInfo:@"VIEW"];
    [statisticsButton setButtonTitle:NSLocalizedString(@"Statistics", nil)];
    
    DashboardNavigationButton* actionsButton = [[DashboardNavigationButton alloc] initWithFrame:CGRectMake(buttonWidth*3.0f, buttonTop, buttonWidth, buttonHeight)];
    [actionsButton setButtonImage:[UIImage imageNamed:@"action_icon"]];
    [actionsButton setButtonExtraInfo:@"4"];
    [actionsButton setButtonTitle:NSLocalizedString(@"Actions", nil)];
    
    [self.view addSubview:bugsButton];
    [self.view addSubview:hogsButton];
    [self.view addSubview:statisticsButton];
    [self.view addSubview:actionsButton];
    
    [self addCustomButtonOnNavBar];
}

- (void)addCustomButtonOnNavBar
{
    
    
}

-(void)moreIconPressed
{
    NSLog(@"moreIcon pressed");
    [self showTutorialController];
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

-(void) showTutorialController
{
    TutorialViewController *controler = [[TutorialViewController alloc]initWithNibName:@"TutorialViewController" bundle:nil];
    [self presentViewController:controler animated: YES completion:nil];
    [controler release];
}
-(void) showBugsController
{
    BugsViewController *controler = [[BugsViewController alloc]initWithNibName:@"BugsViewController" bundle:nil];
    [self presentViewController:controler animated: YES completion:nil];
    [controler release];
}
-(void) showHogsController
{
    HogsViewController *controler = [[HogsViewController alloc]initWithNibName:@"HogsViewController" bundle:nil];
    [self presentViewController:controler animated: YES completion:nil];
    [controler release];
}
-(void) showStatisticsController
{
    StatisticsViewController *controler = [[StatisticsViewController alloc]initWithNibName:@"StatisticsViewController" bundle:nil];
    [self presentViewController:controler animated: YES completion:nil];
    [controler release];
}
-(void) showActionsController
{
    ActionsViewController *controler = [[ActionsViewController alloc]initWithNibName:@"ActionsViewController" bundle:nil];
    [self presentViewController:controler animated: YES completion:nil];
    [controler release];
}
-(void) showMyScoreController
{
    MyScoreViewController *controler = [[MyScoreViewController alloc]initWithNibName:@"MyScoreViewController" bundle:nil];
    [self presentViewController:controler animated: YES completion:nil];
    [controler release];

}


- (void)dealloc {
    [_batteryLife release];
    [_batteryLifeTime release];
    [_myDeviceBtn release];

    [super dealloc];
}


@end
