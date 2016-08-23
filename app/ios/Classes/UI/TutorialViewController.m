//
//  TutorialViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 04/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "TutorialViewController.h"
#import "DashBoardViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController
@synthesize callbackDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil callbackTo:(id)delegate withSelector:(SEL)selector
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setCallbackDelegate:delegate];
        self->callbackSelector = selector;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTutorialData];
    _pagePos = 0;
    _pageCount = _pageDataContent.count;
    [_pageIndicatorView setPageCount:_pageCount];
    [self setPage:_pagePos];
    
    [_acceptButton setBackgroundColor:C_LIGHT_GRAY forState:UIControlStateNormal];
    //[_acceptButton setEnabled:[[Globals instance] hasUserConsented]];//
    [_acceptButton setEnabled:YES];
    _acceptButton.layer.cornerRadius = 5; // this value vary as per your desire
    _acceptButton.clipsToBounds = YES;
    NSLog(@"******TutorialViewController viewDidLoad******");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)acceptPressed{
    NSLog(@"****** acceptPressed *******");
    if (_pagePos == 3){
        [[Globals instance] userHasConsented];
        if(callbackDelegate != nil){
            [[Globals instance] userHasConsented];
            [self.callbackDelegate performSelector:self->callbackSelector];
            [Flurry logEvent:NSLocalizedString(@"selectedEulaConsentForm", nil)];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        if(_pagePos+1 < _pageCount){
            [self setPage:(_pagePos+1)];
        }
    }
}

-(IBAction)rightSwipe{
     NSLog(@"Right Swipe");
    if(_pagePos -1 >= 0){
        [self setPage:(_pagePos-1)];
    }
}

-(IBAction)leftSwipe{
    NSLog(@"Left Swipe");
    if(_pagePos+1 < _pageCount){
        [self setPage:(_pagePos+1)];
    }
}

- (void)createTutorialData
{
    NSLog(@"****** createTutorialData ********");
    TutorialPageContent *main = [TutorialPageContent new];
    TutorialPageContent *bugs = [TutorialPageContent new];
    TutorialPageContent *hogs = [TutorialPageContent new];
    TutorialPageContent *eula = [TutorialPageContent new];

    main.title = NSLocalizedString(@"MainTitle", nil);
    bugs.title = NSLocalizedString(@"Personal", nil);
    hogs.title = NSLocalizedString(@"Apps", nil);
    eula.title = NSLocalizedString(@"Eula", nil);
    
    main.text = NSLocalizedString(@"MainDesc", nil);
    bugs.text = NSLocalizedString(@"PersonalDesc", nil);
    hogs.text = NSLocalizedString(@"HogsDesc", nil);
    eula.text = NSLocalizedString(@"EulaShortDesc", nil);
    
    main.imageName = @"tutorial_01";
    bugs.imageName = @"tutorial_02";
    hogs.imageName = @"tutorial_03";
    eula.imageName = @"tutorial_04";
    
    
    _pageDataContent = [[NSArray alloc] initWithObjects:main, bugs, hogs, eula, nil];

     NSLog(@"****** Check created data title ******** %@", ((TutorialPageContent*)_pageDataContent[1]).title);
    
}

-(void)setPage:(int) pageNumber
{
     NSLog(@"****** setPage pageNumber: ******** %d", pageNumber);
    _pagePos = pageNumber;
    TutorialPageContent* pageCont = _pageDataContent[pageNumber];
     NSLog(@"****** setPage title ******** %@", pageCont.title);
    _eulaButton.hidden = true;
    if(pageNumber == 3){
        //[_acceptButton setEnabled:YES];
        [_acceptButton setBackgroundColor:C_LIGHT_GRAY forState:UIControlStateDisabled];
        [_acceptButton setBackgroundColor:C_ORANGE forState:UIControlStateNormal];
        _eulaButton.hidden = false;
    }
    [_ImageView setImage:[UIImage imageNamed:pageCont.imageName]];
    [_tutorialPageTitle setText:pageCont.title];
    [_tutorialPageDescription setText:pageCont.text];
    [_pageIndicatorView setPagePositionAs:pageNumber];
}

- (IBAction)acceptInfoPressed
{
    WebInfoViewController *controller = [[WebInfoViewController alloc]initWithNibName:@"WebInfoViewController" bundle:nil];
    controller.webUrl = @"consent";
    controller.titleForView =  NSLocalizedString(@"EulaPrivacyPolicy", nil);
    [self.navigationController pushViewController:controller animated:true];
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
    [_ImageView release];
    [_pageIndicatorView release];
    [_acceptButton release];
    [_tutorialPageTitle release];
    [_tutorialPageDescription release];
    [_pageDataContent release];
    [_eulaButton release];
    [super dealloc];
}

@end
